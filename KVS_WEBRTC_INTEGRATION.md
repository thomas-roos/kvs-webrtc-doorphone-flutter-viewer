# AWS KVS WebRTC Integration

This document describes the integration of the official AWS Kinesis Video Streams (KVS) WebRTC SDK into the doorphone viewer Flutter app.

## Overview

The app now uses the official AWS KVS WebRTC Android SDK through Flutter platform channels, providing:

- **Native Performance**: Hardware-accelerated video decoding
- **Full Feature Support**: Complete AWS KVS WebRTC capabilities
- **Better Reliability**: Official SDK maintenance and updates
- **Production Ready**: Battle-tested AWS implementation

## Architecture

### Components

```
┌─────────────────────────────────────────┐
│         Flutter Application             │
├─────────────────────────────────────────┤
│  KVSWebRTCService (High-level API)      │
│  KVSWebRTCPlatform (Platform Channel)   │
└──────────────┬──────────────────────────┘
               │ Method/Event Channels
┌──────────────┴──────────────────────────┐
│      Android Native (Kotlin)            │
├─────────────────────────────────────────┤
│  KVSWebRTCPlugin                        │
│  - AWS KVS WebRTC SDK                   │
│  - WebRTC PeerConnection                │
│  - Signaling Client                     │
└─────────────────────────────────────────┘
```

### Platform Channels

**Method Channel**: `com.doorphone.doorphone_viewer/kvs_webrtc`
- `initialize`: Initialize KVS WebRTC with AWS credentials
- `connectAsViewer`: Connect to a KVS channel as viewer
- `disconnect`: Disconnect from a channel
- `sendOffer`: Send WebRTC offer
- `sendAnswer`: Send WebRTC answer
- `sendIceCandidate`: Send ICE candidate
- `getConnectionState`: Get current connection state

**Event Channel**: `com.doorphone.doorphone_viewer/kvs_webrtc_events`
- `connectionStateChanged`: Connection state updates
- `iceCandidate`: ICE candidate received
- `remoteStreamAdded`: Remote video stream available
- `iceConnectionStateChanged`: ICE connection state updates

## Dependencies

### Android (build.gradle)

```gradle
dependencies {
    // AWS KVS WebRTC SDK
    implementation 'com.amazonaws:amazon-kinesis-video-streams-webrtc:1.10.0'
    
    // WebRTC
    implementation 'org.webrtc:google-webrtc:1.0.32006'
    
    // AWS SDK
    implementation 'com.amazonaws:aws-android-sdk-core:2.77.0'
    implementation 'com.amazonaws:aws-android-sdk-kinesisvideo:2.77.0'
}
```

### Flutter (pubspec.yaml)

No additional Flutter dependencies required - uses platform channels.

## Setup Instructions

### 1. Configure AWS Credentials

Create an AWS configuration with your credentials:

```dart
import 'package:doorphone_viewer/services/config_service.dart';
import 'package:doorphone_viewer/models/aws_config.dart';

final configService = ConfigServiceImpl();
final awsConfig = AWSConfig(
  region: 'us-east-1',
  iotEndpoint: 'your-endpoint.iot.us-east-1.amazonaws.com',
  kvsChannelArn: 'arn:aws:kinesisvideo:us-east-1:123456789012:channel/your-channel',
  accessKeyId: 'YOUR_ACCESS_KEY_ID',
  secretAccessKey: 'YOUR_SECRET_ACCESS_KEY',
);

await configService.saveAWSConfig(awsConfig);
```

### 2. Initialize and Connect

```dart
import 'package:doorphone_viewer/services/doorphone_manager.dart';

final doorphoneManager = DoorphoneManagerImpl(
  awsIoTService: awsIoTService,
  kvsWebRTCService: kvsWebRTCService,
  configService: configService,
);

// Initialize AWS IoT
await doorphoneManager.initializeAWSIoT('your-endpoint.iot.us-east-1.amazonaws.com');

// Connect to device
await doorphoneManager.connectToDevice('device-id');
```

### 3. Monitor Connection

```dart
kvsWebRTCService.connectionState.listen((state) {
  switch (state) {
    case WebRTCSignalingState.connecting:
      print('Connecting...');
      break;
    case WebRTCSignalingState.connected:
      print('Connected!');
      break;
    case WebRTCSignalingState.failed:
      print('Connection failed');
      break;
    case WebRTCSignalingState.idle:
      print('Disconnected');
      break;
  }
});
```

## AWS IAM Permissions

Your AWS credentials need the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesisvideo:DescribeSignalingChannel",
        "kinesisvideo:GetSignalingChannelEndpoint",
        "kinesisvideo:GetIceServerConfig",
        "kinesisvideo:ConnectAsViewer"
      ],
      "Resource": "arn:aws:kinesisvideo:*:*:channel/*"
    }
  ]
}
```

## Testing

### Unit Tests

Run the platform channel tests:

```bash
flutter test test/kvs_webrtc_platform_test.dart
```

### Integration Testing

1. Configure valid AWS credentials
2. Ensure a KVS WebRTC channel is active
3. Run the app and connect to a device
4. Monitor logs for connection status

### Debug Logging

Enable debug logging in Android:

```kotlin
// In KVSWebRTCPlugin.kt
private const val TAG = "KVSWebRTCPlugin"
Log.d(TAG, "Your debug message")
```

Enable debug logging in Flutter:

```dart
// In your app
Logger.setLevel(LogLevel.debug);
```

## Known Limitations

1. **Android Only**: Currently only Android implementation is available
2. **Single Connection**: One active KVS connection at a time per channel
3. **Video Rendering**: Video rendering widget needs to be implemented
4. **Audio Controls**: Audio mute/unmute controls need to be added

## Future Enhancements

- [ ] iOS platform implementation
- [ ] Web platform implementation
- [ ] Video rendering widget
- [ ] Audio controls (mute/unmute)
- [ ] Recording functionality
- [ ] Multiple simultaneous connections
- [ ] Bandwidth adaptation
- [ ] Network quality indicators
- [ ] Connection statistics

## Troubleshooting

### Connection Fails

1. Verify AWS credentials are correct
2. Check IAM permissions
3. Ensure KVS channel exists and is active
4. Check network connectivity
5. Review Android logs: `adb logcat | grep KVSWebRTC`

### No Video Stream

1. Verify remote peer is sending video
2. Check camera permissions
3. Monitor ICE connection state
4. Verify codec support (H.264)

### Build Errors

1. Ensure Android SDK is up to date
2. Sync Gradle dependencies
3. Clean and rebuild: `flutter clean && flutter pub get`
4. Check minimum SDK version (API 24+)

## Support

For issues related to:
- **AWS KVS SDK**: Check [AWS KVS WebRTC documentation](https://docs.aws.amazon.com/kinesisvideostreams-webrtc-dg/)
- **Flutter Integration**: Open an issue in this repository
- **WebRTC**: Refer to [WebRTC documentation](https://webrtc.org/)

## References

- [AWS KVS WebRTC Developer Guide](https://docs.aws.amazon.com/kinesisvideostreams-webrtc-dg/)
- [AWS KVS WebRTC Android SDK](https://github.com/awslabs/amazon-kinesis-video-streams-webrtc-sdk-android)
- [Flutter Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [WebRTC API](https://webrtc.org/getting-started/overview)