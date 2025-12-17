import 'dart:async';
// Firebase disabled for now
// import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/doorbell_event.dart';
import '../core/utils/logger.dart';
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
  static const Logger _logger = Logger('NotificationService');
  
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
      _logger.info('Firebase disabled, using local notifications only');

      // Subscribe to doorbell events from doorphone manager
      _doorbellSubscription = _doorphoneManager.doorbellEvents.listen(
        (event) => showDoorbellNotification(event),
      );

      _isInitialized = true;
      _logger.info('Initialized (Firebase disabled)');
    } catch (e) {
      _logger.error('Initialization failed', e);
      rethrow;
    }
  }

  @override
  Future<void> requestPermissions() async {
    // Firebase disabled - no FCM permissions needed
    _logger.debug('Firebase disabled, skipping FCM permissions');
  }

  @override
  Future<String?> getToken() async {
    // Firebase disabled - no FCM token available
    _logger.debug('Firebase disabled, no FCM token available');
    return null;
  }

  @override
  Future<void> showDoorbellNotification(DoorbellEvent event) async {
    if (!_isInitialized) {
      _logger.warning('Not initialized, skipping notification');
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
      _logger.info('Doorbell notification for ${event.deviceId}');

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
      _logger.error('Failed to show doorbell notification', e);
    }
  }

  // Firebase messaging configuration disabled
  // Future<void> _configureFirebaseMessaging() async {
  //   // Firebase disabled - no FCM configuration needed
  // }





  void dispose() {
    _doorbellSubscription.cancel();
    _notificationController.close();
  }
}
