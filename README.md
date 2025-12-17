# Doorphone Viewer

A cross-platform Flutter application for monitoring and controlling doorphone systems using AWS KVS WebRTC and IoT MQTT services.

## Features

- **Real-time Video Streaming**: View live camera feeds from doorphone devices using Amazon Kinesis Video Streams WebRTC
- **Two-way Audio Communication**: Communicate with visitors through WebRTC audio channels
- **Remote Access Control**: Lock/unlock doors remotely via AWS IoT MQTT commands
- **Push Notifications**: Receive instant notifications when someone rings the doorbell
- **Event History**: View and manage historical doorphone events
- **Multi-device Support**: Connect and manage multiple doorphone devices
- **Android Native**: Optimized for Android with Material Design 3

## Architecture

The app follows a layered architecture:

- **Presentation Layer**: Flutter UI with Material Design 3
- **Business Logic Layer**: Services for doorphone management, video streaming, and notifications
- **Data Layer**: AWS IoT MQTT and KVS WebRTC integrations

## AWS Services Used

- **Amazon Kinesis Video Streams (KVS) WebRTC**: For real-time video and audio streaming
- **AWS IoT Core MQTT**: For device communication and control commands
- **Firebase Cloud Messaging (FCM)**: For push notifications

## Setup

### Prerequisites

- Flutter SDK (>=3.10.0)
- Android SDK (API level 21+)
- AWS Account with IoT Core and KVS configured
- Firebase project for push notifications

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure AWS certificates:
   - Place your AWS IoT certificates in `assets/certificates/`
   - Update `lib/core/app_config.dart` with your AWS endpoints

4. Configure Firebase:
   - Add `google-services.json` to `android/app/`
   - Update Firebase configuration

5. Build and run:
   ```bash
   flutter run
   ```

## Configuration

Update the following in `lib/core/app_config.dart`:

- `awsIoTEndpoint`: Your AWS IoT endpoint
- `kvsRegion`: Your KVS region
- MQTT topics for your doorphone devices

## Project Structure

```
lib/
├── core/                 # Core configuration and themes
├── models/              # Data models
├── services/            # Business logic services
├── ui/
│   ├── screens/         # App screens
│   └── widgets/         # Reusable UI components
└── main.dart           # App entry point

android/                 # Android-specific code
assets/                  # App assets and certificates
```

## Services

- **DoorphoneManager**: Manages device connections and MQTT communication
- **KVSWebRTCService**: Handles WebRTC video/audio streaming
- **AWSIoTService**: Manages MQTT connections and messaging
- **NotificationService**: Handles push notifications and alerts

## Security

- All communications are encrypted using AWS IoT certificates
- WebRTC connections use secure signaling channels
- Device access is controlled through AWS IoT policies

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the documentation
- Review AWS IoT and KVS documentation
- Open an issue on GitHub