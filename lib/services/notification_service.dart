import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/doorbell_event.dart';
import '../core/app_config.dart';
import 'doorphone_manager.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> showDoorbellNotification(DoorbellEvent event);
  Future<void> requestPermissions();
  Stream<RemoteMessage> get notificationStream;
  Future<String?> getToken();
}

class NotificationServiceImpl implements NotificationService {
  final DoorphoneManager _doorphoneManager;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final StreamController<RemoteMessage> _notificationController =
      StreamController<RemoteMessage>.broadcast();

  late StreamSubscription<DoorbellEvent> _doorbellSubscription;
  bool _isInitialized = false;

  NotificationServiceImpl({
    required DoorphoneManager doorphoneManager,
  }) : _doorphoneManager = doorphoneManager;

  @override
  Stream<RemoteMessage> get notificationStream => _notificationController.stream;

  @override
  Future<void> initialize() async {
    try {
      // Request permissions
      await requestPermissions();

      // Configure Firebase Messaging
      await _configureFirebaseMessaging();

      // Subscribe to doorbell events from doorphone manager
      _doorbellSubscription = _doorphoneManager.doorbellEvents.listen(
        (event) => showDoorbellNotification(event),
      );

      _isInitialized = true;
      print('NotificationService: Initialized');
    } catch (e) {
      print('NotificationService: Initialization failed - $e');
      rethrow;
    }
  }

  @override
  Future<void> requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('NotificationService: Permissions granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('NotificationService: Provisional permissions granted');
      } else {
        print('NotificationService: Permissions denied');
      }
    } catch (e) {
      print('NotificationService: Permission request failed - $e');
      rethrow;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('NotificationService: FCM Token - $token');
      return token;
    } catch (e) {
      print('NotificationService: Failed to get FCM token - $e');
      return null;
    }
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
      
      // Create a RemoteMessage-like object for consistency
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

  Future<void> _configureFirebaseMessaging() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('NotificationService: Foreground message received');
      _handleForegroundMessage(message);
    });

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('NotificationService: Background message opened app');
      _handleBackgroundMessage(message);
    });

    // Handle messages when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('NotificationService: App opened from terminated state');
      _handleTerminatedMessage(initialMessage);
    }

    // Subscribe to token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      print('NotificationService: FCM token refreshed - $token');
      // Here you would typically send the new token to your backend
    });
  }

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
      final eventId = message.data['eventId'];
      
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
      
      print('NotificationService: Access message for device $deviceId - $action');
    } catch (e) {
      print('NotificationService: Failed to handle access message - $e');
    }
  }

  void dispose() {
    _doorbellSubscription.cancel();
    _notificationController.close();
  }
}