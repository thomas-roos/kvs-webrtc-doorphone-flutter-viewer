class AppConfig {
  // AWS Configuration
  static const String awsRegion = 'us-east-1';
  static const String awsIoTEndpoint =
      'your-iot-endpoint.iot.us-east-1.amazonaws.com';
  static const String kvsRegion = 'us-east-1';

  // AWS Authentication using access keys (no certificates needed)

  // MQTT Topics
  static const String deviceRegistryTopic = 'doorphone/devices/+/registry';
  static const String deviceEventsTopic = 'doorphone/devices/+/events';
  static const String deviceCommandsTopic = 'doorphone/devices/+/commands';
  static const String doorbellEventsTopic = 'doorphone/devices/+/doorbell';

  // KVS Channel Configuration
  static const String defaultKVSChannelPrefix = 'doorphone-channel-';

  // App Settings
  static const int videoStreamTimeoutSeconds = 30;
  static const int mqttConnectionTimeoutSeconds = 10;
  static const int maxReconnectionAttempts = 5;
  static const Duration reconnectionDelay = Duration(seconds: 5);

  // Notification Settings
  static const String notificationChannelId = 'doorphone_notifications';
  static const String notificationChannelName = 'Doorphone Notifications';
  static const String notificationChannelDescription =
      'Notifications for doorphone events';

  // UI Configuration
  static const double videoAspectRatio = 16.0 / 9.0;
  static const int eventHistoryPageSize = 20;
  static const Duration splashScreenDuration = Duration(seconds: 2);
}
