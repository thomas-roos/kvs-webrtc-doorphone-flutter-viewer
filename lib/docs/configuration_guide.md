# AWS Configuration Guide

This app now supports dynamic AWS configuration through a user-friendly form interface.

## Configuration Fields

### Required Fields:
1. **AWS Region**: The AWS region where your IoT and KVS resources are located (e.g., `us-east-1`)
2. **IoT Endpoint**: Your AWS IoT Core endpoint URL (format: `your-endpoint.iot.region.amazonaws.com`)
3. **KVS Channel ARN**: The Amazon Resource Name for your Kinesis Video Streams channel
4. **Access Key ID**: Your AWS access key ID for authentication
5. **Secret Access Key**: Your AWS secret access key for authentication

### Optional Fields:
6. **Session Token**: Required only if using temporary AWS credentials (STS tokens)

## How to Configure

### First Time Setup:
1. Launch the app
2. The splash screen will detect no configuration and automatically navigate to the configuration screen
3. Fill in all required fields
4. Tap "Save Configuration"
5. The app will navigate to the home screen

### Updating Configuration:
1. From the home screen, tap the settings icon in the app bar
2. Update any fields as needed
3. Tap "Save Configuration" to save changes
4. Or tap "Clear Config" to remove all stored configuration

## Security

- All credentials are stored securely on the device using Flutter's `shared_preferences` package
- Credentials are not transmitted to any third parties
- Secret keys and session tokens are masked in the UI for security
- The configuration can be completely cleared from the device at any time

## Configuration Storage

The configuration is stored locally on the device in encrypted shared preferences. The app checks for valid configuration on startup:

- If no configuration exists → Navigate to configuration screen
- If configuration exists → Use stored values to initialize AWS services

## Integration with AWS Services

The stored configuration is automatically used by:
- AWS IoT Service for MQTT connections (using access key authentication)
- KVS WebRTC Service for video streaming
- All other AWS-related functionality

Note: This app uses AWS access key authentication instead of certificates for simplified setup.

## Troubleshooting

### Common Issues:
1. **Invalid IoT Endpoint**: Ensure the endpoint follows the format `your-endpoint.iot.region.amazonaws.com`
2. **Invalid KVS Channel ARN**: Must start with `arn:aws:kinesisvideo:`
3. **Credential Length**: Access keys must be at least 16 characters, secret keys at least 20 characters
4. **Connection Failures**: Verify your AWS credentials have the necessary permissions for IoT and KVS services

### Required AWS Permissions:
Your AWS credentials need the following permissions:
- `iot:Connect`
- `iot:Subscribe`
- `iot:Publish`
- `kinesisvideo:GetSignalingChannelEndpoint`
- `kinesisvideo:GetIceServerConfig`
- `kinesisvideo:ConnectAsMaster`
- `kinesisvideo:ConnectAsViewer`