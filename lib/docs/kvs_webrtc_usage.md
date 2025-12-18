# KVS WebRTC Integration Usage

This document explains how to use the official AWS KVS WebRTC SDK integration in the doorphone viewer app.

## Overview

The app now uses the official AWS KVS WebRTC Android SDK through platform channels for better performance and full feature support.

## Setup

### 1. AWS Configuration

First, configure your AWS credentials and KVS settings:

```dart
final configService = ConfigService();
final awsConfig = AWSConfig(
  region: 'us-east-1',
  iotEndpoint: 'your-iot-endpoint.iot.us-east-1.amazonaws.com',
  kvsChannelArn: 'arn:aws:kinesisvideo:us-east-1:123456789012:channel/your-channel',
  accessKeyId: 'YOUR_ACCESS_KEY_ID',
  secretAccessKey: 'YOUR_SECRET_ACCESS_KEY',
);

await configService.saveAWSConfig(awsConfig);
```

### 2. Connect to Device

```dart
final doorphoneManager = DoorphoneManager();

// Initialize AWS IoT
await doorphoneManager.initializeAWSIoT('your-iot-endpoint.iot.us-east-1.amazonaws.com');

// Connect to a doorphone device
await doorphoneManager.connectToDevice('device-id');
```

### 3. Listen to Video Stream

```dart
final kvsWebRTCService = KVSWebRTCService();

// Listen to video frames
kvsWebRTCService.videoStream.listen((videoFrame) {
  // Handle video frame
  print('Received video frame: ${videoFrame.width}x${videoFrame.height}');
});

// Listen to connection state
kvsWebRTCService.connectionState.listen((state) {
  switch (state) {
    case WebRTCSignalingState.connecting:
      print('Connecting to KVS WebRTC...');
      break;
    case WebRTCSignalingState.connected:
      print('Connected to KVS WebRTC');
      break;
    case WebRTCSignalingState.failed:
      print('KVS WebRTC connection failed');
      break;
    case WebRTCSignalingState.idle:
      print('KVS WebRTC disconnected');
      break;
  }
});
```

## Architecture

### Platform Channel Implementation

The integration uses platform channels to communicate with the native Android KVS WebRTC SDK:

- **Method Channel**: `com.doorphone.doorphone_viewer/kvs_webrtc`
- **Event Channel**: `com.doorphone.doorphone_viewer/kvs_webrtc_events`

### Native Android Components

1. **KVSWebRTCPlugin.kt**: Main platform channel handler
2. **MainActivity.kt**: Registers the plugin and handles lifecycle

### Flutter Components

1. **KVSWebRTCPlatform**: Platform channel interface
2. **KVSWebRTCService**: High-level service wrapper
3. **DoorphoneManager**: Integrates KVS WebRTC with device management

## Features

### Supported Operations

- ✅ Initialize KVS WebRTC with AWS credentials
- ✅ Connect as viewer to KVS channels
- ✅ Receive WebRTC signaling events
- ✅ Handle ICE candidates
- ✅ Connection state monitoring
- ✅ Graceful disconnect

### WebRTC Capabilities

- **Video Streaming**: Receive H.264 video from doorphone cameras
- **Audio Communication**: Two-way audio through WebRTC
- **ICE Handling**: Automatic ICE candidate exchange
- **Connection Management**: Robust connection state handling

## Error Handling

The implementation includes comprehensive error handling:

```dart
try {
  await doorphoneManager.connectToDevice('device-id');
} catch (e) {
  if (e.toString().contains('AWS configuration not found')) {
    // Handle missing AWS config
    showConfigurationDialog();
  } else if (e.toString().contains('CONNECTION_FAILED')) {
    // Handle connection failure
    showConnectionErrorDialog();
  }
}
```

## Security

- All WebRTC connections use secure signaling channels
- AWS credentials are stored securely using SharedPreferences
- ICE servers use STUN/TURN for NAT traversal
- End-to-end encryption for media streams

## Performance Considerations

- Native SDK provides better performance than pure Dart implementation
- Hardware-accelerated video decoding on supported devices
- Efficient memory management for video frames
- Background processing for signaling

## Troubleshooting

### Common Issues

1. **Missing AWS Credentials**
   - Ensure AWS config is saved before connecting
   - Check access key permissions for KVS

2. **Connection Timeout**
   - Verify KVS channel exists and is active
   - Check network connectivity
   - Ensure proper IAM permissions

3. **Video Not Displaying**
   - Check camera permissions
   - Verify video codec support
   - Monitor connection state events

### Debug Logging

Enable debug logging to troubleshoot issues:

```dart
// In your app initialization
Logger.setLevel(LogLevel.debug);
```

## Next Steps

1. Implement video rendering widget
2. Add audio controls
3. Implement recording functionality
4. Add bandwidth adaptation
5. Support multiple simultaneous connections