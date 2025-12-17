import 'dart:async';
// Firebase disabled for now
// import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/doorbell_event.dart';
import 'doorphone_manager.dart';

// Simplified RemoteMessage class for when Firebase is disabled
class RemoteMessage {
  final String? messageId;
  final Map<String, dynamic> data;
  final RemoteNotification? notification;
  final DateTime? sentTime;

  RemoteMessage({
    this.messageId,
    required this.data,
    this.notification,
    this.sentTime,
  });
}

class RemoteNotification {
  final String? title;
  final String? body;

  RemoteNotification({this.title, this.body});
}

abstract class NotificationService {
  Future<void> initialize();
  Future<void> showDoorbellNotification(DoorbellEvent event);
  Future<void> requestPermissions();
  Stream<RemoteMessage> get notificationStream;
  Future<String?> getToken();
}

class NotificationServiceImpl implements NotificationService {
  final DoorphoneManager _doorphoneManager;
  // Firebase disabled - using local notification stream only
  final StreamController<RemoteMessage> _notificationController =
      StreamController<RemoteMessage>.broadcast();

  late StreamSubscription<DoorbellEvent> _doorbellSubscription;
  bool _isInitialized = false;

  NotificationServiceImpl({required DoorphoneManager doorphoneManager})
    : _doorphoneManager = doorphoneManager;

  @override
  Stream<RemoteMessage> get notificationStream =>
      _notificationController.stream;

  @override
  Future<void> initialize() async {
    try {
      // Firebase disabled - simplified initialization
      print('NotificationService: Firebase disabled, using local notifications only');

      // Subscribe to doorbell events from doorphone manager
      _doorbellSubscription = _doorphoneManager.doorbellEvents.listen(
        (event) => showDoorbellNotification(event),
      );

      _isInitialized = true;
      print('NotificationService: Initialized (Firebase disabled)');
    } catch (e) {
      print('NotificationService: Initialization failed - $e');
      rethrow;
    }
  }

  @override
  Future<void> requestPermissions() async {
    // Firebase disabled - no FCM permissions needed
    print('NotificationService: Firebase disabled, skipping FCM permissions');
  }

  @override
  Future<String?> getToken() async {
    // Firebase disabled - no FCM token available
    print('NotificationService: Firebase disabled, no FCM token available');
    return null;
  }

  @override
  Future<void> showDoorbellNotification(DoorbellEvent event) async {
    if (!_isInitialized) {
      print('NotificationService: Not initialized, skipping notification');
      return;
    }

    try {
      // Find the device name for the notification
      final device = _doorphoneManager.deviceList
          .where((d) => d.id == event.deviceId)
          .firstOrNull;

      final deviceName = device?.name ?? 'Unknown Device';

      // Create notification data
      final notificationData = {
        'title': 'Doorbell Ring',
        'body': 'Someone is at the door ($deviceName)',
        'deviceId': event.deviceId,
        'eventId': event.id,
        'timestamp': event.timestamp.toIso8601String(),
        'type': 'doorbell',
      };

      // For local notifications, we would use a local notification plugin
      // For now, we'll just log and emit the event
      print('NotificationService: Doorbell notification for ${event.deviceId}');

      // Create a local notification message
      final message = RemoteMessage(
        messageId: event.id,
        data: notificationData,
        notification: RemoteNotification(
          title: notificationData['title'],
          body: notificationData['body'],
        ),
        sentTime: event.timestamp,
      );

      _notificationController.add(message);
    } catch (e) {
      print('NotificationService: Failed to show doorbell notification - $e');
    }
  }

  // Firebase messaging configuration disabled
  // Future<void> _configureFirebaseMessaging() async {
  //   // Firebase disabled - no FCM configuration needed
  // }

  void _handleForegroundMessage(RemoteMessage message) {
    _notificationController.add(message);

    // Handle doorphone-specific messages
    final messageType = message.data['type'];
    if (messageType == 'doorbell') {
      _handleDoorbellMessage(message);
    } else if (messageType == 'access') {
      _handleAccessMessage(message);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    _notificationController.add(message);

    // Navigate to appropriate screen based on message type
    final messageType = message.data['type'];
    if (messageType == 'doorbell') {
      // Navigate to video view or home screen
      print('NotificationService: Navigate to doorbell view');
    }
  }

  void _handleTerminatedMessage(RemoteMessage message) {
    _notificationController.add(message);

    // Handle app launch from notification
    final messageType = message.data['type'];
    if (messageType == 'doorbell') {
      print('NotificationService: App launched from doorbell notification');
    }
  }

  void _handleDoorbellMessage(RemoteMessage message) {
    try {
      final deviceId = message.data['deviceId'];

      print('NotificationService: Doorbell message for device $deviceId');

      // You could trigger additional actions here, such as:
      // - Auto-connecting to the device
      // - Showing an in-app notification
      // - Playing a custom sound
    } catch (e) {
      print('NotificationService: Failed to handle doorbell message - $e');
    }
  }

  void _handleAccessMessage(RemoteMessage message) {
    try {
      final deviceId = message.data['deviceId'];
      final action = message.data['action'];

      print(
        'NotificationService: Access message for device $deviceId - $action',
      );
    } catch (e) {
      print('NotificationService: Failed to handle access message - $e');
    }
  }

  void dispose() {
    _doorbellSubscription.cancel();
    _notificationController.close();
  }
}
