# AWS IoT to Firebase FCM Bridge

This backend service bridges AWS IoT Core events with Firebase Cloud Messaging to send push notifications to the Flutter doorphone app.

## Architecture

```
Doorphone Device → AWS IoT Core → IoT Rule → Lambda Function → Firebase FCM → Mobile App
```

## Components

1. **AWS IoT Rules** - Route specific MQTT topics to Lambda
2. **Lambda Functions** - Process IoT events and send FCM notifications
3. **DynamoDB** - Store user FCM tokens and device mappings
4. **Firebase Admin SDK** - Send push notifications

## Setup Instructions

### 1. Deploy Infrastructure
```bash
cd backend/infrastructure
npm install
npx cdk deploy
```

### 2. Configure Firebase
- Add Firebase service account key to AWS Secrets Manager
- Update Lambda environment variables

### 3. Configure IoT Rules
- Rules automatically created by CDK
- Routes doorbell/access events to appropriate Lambda functions

## Message Flow

### Doorbell Event
1. Device publishes to: `doorphone/devices/{deviceId}/doorbell`
2. IoT Rule triggers: `doorbell-notification-lambda`
3. Lambda sends FCM message with unlock/view actions
4. App shows rich notification

### Access Event  
1. Device publishes to: `doorphone/devices/{deviceId}/access`
2. IoT Rule triggers: `access-notification-lambda`
3. Lambda sends FCM message about door status
4. App shows status notification