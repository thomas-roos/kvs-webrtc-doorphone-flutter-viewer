const admin = require('firebase-admin');
const AWS = require('aws-sdk');

// Initialize Firebase Admin SDK
let firebaseApp;

const dynamodb = new AWS.DynamoDB.DocumentClient();
const secretsManager = new AWS.SecretsManager();

async function initializeFirebase() {
    if (!firebaseApp) {
        try {
            // Get Firebase service account from AWS Secrets Manager
            const secret = await secretsManager.getSecretValue({
                SecretId: process.env.FIREBASE_SECRET_NAME
            }).promise();
            
            const serviceAccount = JSON.parse(secret.SecretString);
            
            firebaseApp = admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                projectId: serviceAccount.project_id
            });
            
            console.log('Firebase Admin SDK initialized');
        } catch (error) {
            console.error('Failed to initialize Firebase:', error);
            throw error;
        }
    }
    return firebaseApp;
}

exports.handler = async (event) => {
    console.log('Doorbell notification event:', JSON.stringify(event, null, 2));
    
    try {
        await initializeFirebase();
        
        // Parse the IoT event
        const { deviceId, timestamp, eventId } = event;
        const eventTime = new Date(timestamp);
        
        // Get device information and user tokens
        const deviceInfo = await getDeviceInfo(deviceId);
        if (!deviceInfo) {
            console.log(`Device ${deviceId} not found in database`);
            return { statusCode: 404, body: 'Device not found' };
        }
        
        // Get FCM tokens for users who have access to this device
        const userTokens = await getUserTokensForDevice(deviceId);
        if (userTokens.length === 0) {
            console.log(`No FCM tokens found for device ${deviceId}`);
            return { statusCode: 200, body: 'No users to notify' };
        }
        
        // Create FCM message
        const fcmMessage = {
            data: {
                type: 'doorbell',
                deviceId: deviceId,
                deviceName: deviceInfo.name,
                eventId: eventId || `doorbell_${Date.now()}`,
                timestamp: eventTime.toISOString(),
                location: deviceInfo.location || 'Unknown Location'
            },
            notification: {
                title: 'Doorbell Ring',
                body: `Someone is at ${deviceInfo.name}`,
                sound: 'doorbell_sound.wav'
            },
            android: {
                priority: 'high',
                notification: {
                    channelId: 'doorphone_notifications',
                    priority: 'high',
                    defaultSound: false,
                    sound: 'doorbell_sound.wav',
                    vibrationPattern: [0, 500, 200, 500],
                    actions: [
                        {
                            action: 'unlock',
                            title: 'Unlock Door',
                            icon: 'ic_unlock'
                        },
                        {
                            action: 'view',
                            title: 'View Camera',
                            icon: 'ic_video'
                        }
                    ]
                }
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'doorbell_sound.wav',
                        category: 'DOORBELL_CATEGORY',
                        'mutable-content': 1
                    }
                }
            }
        };
        
        // Send notifications to all registered tokens
        const results = await sendNotificationsToTokens(userTokens, fcmMessage);
        
        // Log the event to DynamoDB for history
        await logDoorbellEvent(deviceId, eventId, eventTime, results);
        
        console.log(`Doorbell notifications sent for device ${deviceId}:`, results);
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Doorbell notifications sent successfully',
                deviceId: deviceId,
                notificationsSent: results.successful,
                notificationsFailed: results.failed
            })
        };
        
    } catch (error) {
        console.error('Error processing doorbell notification:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: 'Failed to process doorbell notification',
                details: error.message
            })
        };
    }
};

async function getDeviceInfo(deviceId) {
    try {
        const params = {
            TableName: process.env.DEVICES_TABLE,
            Key: { deviceId: deviceId }
        };
        
        const result = await dynamodb.get(params).promise();
        return result.Item;
    } catch (error) {
        console.error('Error getting device info:', error);
        return null;
    }
}

async function getUserTokensForDevice(deviceId) {
    try {
        const params = {
            TableName: process.env.USER_DEVICES_TABLE,
            IndexName: 'DeviceIdIndex',
            KeyConditionExpression: 'deviceId = :deviceId',
            ExpressionAttributeValues: {
                ':deviceId': deviceId
            }
        };
        
        const result = await dynamodb.query(params).promise();
        
        // Get FCM tokens for each user
        const tokens = [];
        for (const item of result.Items) {
            const userTokens = await getUserFCMTokens(item.userId);
            tokens.push(...userTokens);
        }
        
        return tokens;
    } catch (error) {
        console.error('Error getting user tokens:', error);
        return [];
    }
}

async function getUserFCMTokens(userId) {
    try {
        const params = {
            TableName: process.env.USER_TOKENS_TABLE,
            Key: { userId: userId }
        };
        
        const result = await dynamodb.get(params).promise();
        return result.Item ? result.Item.fcmTokens || [] : [];
    } catch (error) {
        console.error('Error getting user FCM tokens:', error);
        return [];
    }
}

async function sendNotificationsToTokens(tokens, message) {
    const results = {
        successful: 0,
        failed: 0,
        errors: []
    };
    
    // Send to multiple tokens in batches
    const batchSize = 500; // FCM limit
    for (let i = 0; i < tokens.length; i += batchSize) {
        const batch = tokens.slice(i, i + batchSize);
        
        try {
            const multicastMessage = {
                ...message,
                tokens: batch
            };
            
            const response = await admin.messaging().sendMulticast(multicastMessage);
            
            results.successful += response.successCount;
            results.failed += response.failureCount;
            
            // Handle failed tokens (remove invalid ones)
            if (response.failureCount > 0) {
                const failedTokens = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        failedTokens.push({
                            token: batch[idx],
                            error: resp.error?.code
                        });
                        
                        // Remove invalid tokens
                        if (resp.error?.code === 'messaging/invalid-registration-token' ||
                            resp.error?.code === 'messaging/registration-token-not-registered') {
                            removeInvalidToken(batch[idx]);
                        }
                    }
                });
                results.errors.push(...failedTokens);
            }
            
        } catch (error) {
            console.error('Error sending batch notifications:', error);
            results.failed += batch.length;
            results.errors.push({
                batch: batch,
                error: error.message
            });
        }
    }
    
    return results;
}

async function removeInvalidToken(token) {
    try {
        // Find and remove the invalid token from user records
        const params = {
            TableName: process.env.USER_TOKENS_TABLE,
            FilterExpression: 'contains(fcmTokens, :token)',
            ExpressionAttributeValues: {
                ':token': token
            }
        };
        
        const result = await dynamodb.scan(params).promise();
        
        for (const item of result.Items) {
            const updatedTokens = item.fcmTokens.filter(t => t !== token);
            
            await dynamodb.update({
                TableName: process.env.USER_TOKENS_TABLE,
                Key: { userId: item.userId },
                UpdateExpression: 'SET fcmTokens = :tokens',
                ExpressionAttributeValues: {
                    ':tokens': updatedTokens
                }
            }).promise();
        }
        
        console.log(`Removed invalid FCM token: ${token}`);
    } catch (error) {
        console.error('Error removing invalid token:', error);
    }
}

async function logDoorbellEvent(deviceId, eventId, timestamp, notificationResults) {
    try {
        const params = {
            TableName: process.env.EVENTS_TABLE,
            Item: {
                eventId: eventId,
                deviceId: deviceId,
                eventType: 'doorbell',
                timestamp: timestamp.toISOString(),
                notificationsSent: notificationResults.successful,
                notificationsFailed: notificationResults.failed,
                createdAt: new Date().toISOString()
            }
        };
        
        await dynamodb.put(params).promise();
        console.log(`Logged doorbell event: ${eventId}`);
    } catch (error) {
        console.error('Error logging doorbell event:', error);
    }
}