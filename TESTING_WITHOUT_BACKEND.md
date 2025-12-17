# Testing Without Backend Bridge

You can fully test the doorphone app without the AWS Lambda backend bridge by using direct MQTT communication and simulated notifications.

## 🎯 What You Can Test Now

### ✅ **Direct MQTT Communication**
- App connects directly to AWS IoT Core via MQTT
- Receives doorbell/access events in real-time
- Processes device registry and commands
- No backend bridge needed!

### ✅ **Local Notifications**
- App generates local notifications for doorbell events
- Shows rich notifications with unlock/view actions
- Tests notification permissions and handling

### ✅ **Full App Functionality**
- AWS configuration system
- Device management
- Video streaming (KVS WebRTC)
- Event history
- Door control commands

## 📱 Testing Approach

### 1. **Configure AWS Credentials**
Use the new configuration screen to enter:
- AWS Region
- IoT Endpoint  
- KVS Channel ARN
- Access Key ID
- Secret Access Key

### 2. **MQTT Topics the App Listens To**
```
doorphone/devices/+/registry    # Device registration
doorphone/devices/+/events      # General events
doorphone/devices/+/commands    # Command responses
doorphone/devices/+/doorbell    # Doorbell events
```

### 3. **Simulate Doorbell Events**
You can test by publishing MQTT messages directly to AWS IoT:

#### **Doorbell Event:**
```json
Topic: doorphone/devices/test-device-001/doorbell
Payload: {
  "eventId": "doorbell_123456789",
  "deviceId": "test-device-001", 
  "timestamp": "2024-01-15T10:30:00Z",
  "eventType": "doorbell_pressed",
  "metadata": {
    "location": "Front Door",
    "deviceName": "Front Door Camera"
  }
}
```

#### **Device Registry:**
```json
Topic: doorphone/devices/test-device-001/registry
Payload: {
  "deviceId": "test-device-001",
  "name": "Front Door Camera",
  "location": "Main Entrance", 
  "status": "online",
  "capabilities": ["video", "audio", "unlock"],
  "kvsChannelArn": "arn:aws:kinesisvideo:us-east-1:123456789012:channel/front-door"
}
```

## 🧪 Testing Steps

### **Step 1: Install & Configure**
1. Download APK from GitHub Actions
2. Install on Android device
3. Open app → Configure AWS credentials
4. App should connect to AWS IoT

### **Step 2: Test MQTT Connection**
1. Check app logs for "AWS IoT MQTT: Connected"
2. App should subscribe to doorphone topics
3. Device list should be empty initially

### **Step 3: Simulate Device Registration**
Use AWS IoT Test Client or MQTT client to publish device registry message:
```bash
# Using AWS CLI
aws iot-data publish \
  --topic "doorphone/devices/test-device-001/registry" \
  --payload '{"deviceId":"test-device-001","name":"Front Door","status":"online"}'
```

### **Step 4: Test Doorbell Notification**
Publish doorbell event:
```bash
aws iot-data publish \
  --topic "doorphone/devices/test-device-001/doorbell" \
  --payload '{"eventId":"test123","deviceId":"test-device-001","timestamp":"2024-01-15T10:30:00Z"}'
```

**Expected Result:**
- App receives MQTT message
- Shows local notification: "Someone is at Front Door"
- Notification has "Unlock" and "View" buttons
- Tapping opens video viewer or sends unlock command

## 🔧 How It Works Without Backend

### **Current Flow:**
```
MQTT Publisher → AWS IoT Core → Flutter App → Local Notification
```

### **What the App Does:**
1. **Connects to AWS IoT** using configured credentials
2. **Subscribes to MQTT topics** for doorphone events
3. **Receives doorbell events** directly via MQTT
4. **Generates local notifications** using NotificationService
5. **Shows rich notifications** with action buttons

### **Notification Generation:**
The app's `NotificationService` listens to doorbell events from `DoorphoneManager` and creates local notifications:

```dart
// In NotificationService
doorbellSubscription = doorphoneManager.doorbellEvents.listen(
  (event) => showDoorbellNotification(event),
);
```

## 🛠️ Testing Tools

### **1. AWS IoT Test Client**
- Go to AWS Console → IoT Core → Test
- Publish messages to doorphone topics
- Monitor app responses

### **2. MQTT Client Apps**
- **Android:** MQTT Client by HiveMQ
- **Desktop:** MQTT Explorer, MQTT.fx
- **CLI:** mosquitto_pub

### **3. AWS CLI**
```bash
# Publish doorbell event
aws iot-data publish \
  --topic "doorphone/devices/YOUR_DEVICE_ID/doorbell" \
  --payload file://doorbell-event.json

# Monitor topic
aws iot-data get-thing-shadow --thing-name YOUR_DEVICE_ID
```

## 📋 Test Scenarios

### **Scenario 1: Device Discovery**
- Publish device registry → App should show device in list

### **Scenario 2: Doorbell Notification**  
- Publish doorbell event → App should show notification

### **Scenario 3: Door Control**
- Tap "Unlock" in notification → App should publish unlock command

### **Scenario 4: Video Streaming**
- Tap "View" in notification → App should open KVS WebRTC viewer

### **Scenario 5: Event History**
- Multiple events → App should show in history tab

## 🚀 Future Backend Integration

When you're ready to add the backend bridge:

### **Enhanced Flow:**
```
Doorphone Device → AWS IoT → Lambda Bridge → Firebase FCM → App
```

### **Benefits of Backend:**
- **Push notifications** when app is closed
- **User management** and device permissions  
- **Event logging** and analytics
- **Scalable architecture** for multiple users
- **Rich notification actions** from system tray

## ✅ Current Testing Checklist

- [ ] App installs and opens
- [ ] Configuration screen works
- [ ] AWS IoT connection established
- [ ] MQTT subscription successful
- [ ] Device registry message received
- [ ] Device appears in app
- [ ] Doorbell MQTT message received  
- [ ] Local notification appears
- [ ] Notification actions work
- [ ] Video viewer opens
- [ ] Door unlock command sent

The app is fully functional for testing without any backend infrastructure! The MQTT direct connection gives you real-time communication and local notifications work perfectly for development and testing.