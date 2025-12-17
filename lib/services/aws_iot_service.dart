import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../core/app_config.dart';

enum MQTTConnectionState { disconnected, connecting, connected, error }

abstract class AWSIoTService {
  Future<void> initialize(
    String endpoint,
    String certificatePath,
    String privateKeyPath,
  );
  Future<void> connect();
  Future<void> disconnect();
  Future<void> subscribe(
    String topic,
    Function(String, Map<String, dynamic>) callback,
  );
  Future<void> publish(String topic, Map<String, dynamic> message);
  Stream<MQTTConnectionState> get connectionState;
  bool get isConnected;
}

class AWSIoTServiceImpl implements AWSIoTService {
  late MqttServerClient _mqttClient;
  final StreamController<MQTTConnectionState> _connectionStateController =
      StreamController<MQTTConnectionState>.broadcast();
  final Map<String, Function(String, Map<String, dynamic>)> _subscriptions = {};

  MQTTConnectionState _currentState = MQTTConnectionState.disconnected;
  bool _isInitialized = false;

  @override
  Stream<MQTTConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  bool get isConnected => _currentState == MQTTConnectionState.connected;

  @override
  Future<void> initialize(
    String endpoint,
    String certificatePath,
    String privateKeyPath,
  ) async {
    try {
      final clientId =
          'doorphone_viewer_${DateTime.now().millisecondsSinceEpoch}';
      _mqttClient = MqttServerClient(endpoint, clientId);

      // Configure MQTT client
      _mqttClient.port = 8883; // AWS IoT MQTT port
      _mqttClient.secure = true;
      _mqttClient.keepAlivePeriod = 60;
      _mqttClient.connectTimeoutPeriod = 10000;

      // Set up connection state listeners
      _mqttClient.onConnected = () {
        _updateConnectionState(MQTTConnectionState.connected);
        print('AWS IoT MQTT: Connected');
      };

      _mqttClient.onDisconnected = () {
        _updateConnectionState(MQTTConnectionState.disconnected);
        print('AWS IoT MQTT: Disconnected');
      };

      _mqttClient.onSubscribed = (String topic) {
        print('AWS IoT MQTT: Subscribed to $topic');
      };

      // Set up message listener
      _mqttClient.updates!.listen((
        List<MqttReceivedMessage<MqttMessage>> messages,
      ) {
        for (final message in messages) {
          final topic = message.topic;
          final payload = MqttPublishPayload.bytesToStringAsString(
            (message.payload as MqttPublishMessage).payload.message,
          );
          _handleMessage(topic, payload);
        }
      });

      _isInitialized = true;
      print('AWS IoT MQTT: Initialized');
    } catch (e) {
      print('AWS IoT MQTT: Initialization failed - $e');
      _updateConnectionState(MQTTConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> connect() async {
    if (!_isInitialized) {
      throw Exception('AWS IoT service not initialized');
    }

    try {
      _updateConnectionState(MQTTConnectionState.connecting);

      // For demo purposes, we'll simulate a connection
      // In a real implementation, you would set up AWS IoT certificates here
      print('AWS IoT MQTT: Attempting connection (simulated)');
      print('AWS IoT MQTT: Endpoint: $_mqttClient.server');
      print('AWS IoT MQTT: Client ID: ${_mqttClient.clientIdentifier}');

      // Simulate connection delay
      await Future.delayed(const Duration(seconds: 2));

      // For now, we'll just mark as connected for demo purposes
      _updateConnectionState(MQTTConnectionState.connected);
      print('AWS IoT MQTT: Connected (simulated)');
      
      // Subscribe to doorphone topics
      await _subscribeToDoorphoneTopics();
    } catch (e) {
      print('AWS IoT MQTT: Connection failed - $e');
      _updateConnectionState(MQTTConnectionState.error);
      rethrow;
    }
  }

  Future<void> _subscribeToDoorphoneTopics() async {
    try {
      // Subscribe to all doorphone topics
      final topics = [
        'doorphone/devices/+/registry',
        'doorphone/devices/+/events', 
        'doorphone/devices/+/commands',
        'doorphone/devices/+/doorbell',
      ];
      
      for (final topic in topics) {
        print('AWS IoT MQTT: Subscribing to $topic');
        // In real implementation, would call _mqttClient.subscribe()
      }
      
      print('AWS IoT MQTT: Subscribed to ${topics.length} topics');
    } catch (e) {
      print('AWS IoT MQTT: Subscription failed - $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _mqttClient.disconnect();
      _updateConnectionState(MQTTConnectionState.disconnected);
    } catch (e) {
      print('AWS IoT MQTT: Disconnect failed - $e');
    }
  }

  @override
  Future<void> subscribe(
    String topic,
    Function(String, Map<String, dynamic>) callback,
  ) async {
    if (!isConnected) {
      throw Exception('Not connected to AWS IoT');
    }

    try {
      _subscriptions[topic] = callback;
      print('AWS IoT MQTT: Subscribed to $topic (simulated)');
      
      // For testing: simulate a doorbell message after 5 seconds if it's a doorbell topic
      if (topic.contains('doorbell')) {
        print('AWS IoT MQTT: Will simulate doorbell message in 5 seconds for testing');
        Timer(const Duration(seconds: 5), () {
          _simulateDoorbellMessage(topic, callback);
        });
      }
    } catch (e) {
      print('AWS IoT MQTT: Subscription failed for $topic - $e');
      rethrow;
    }
  }

  void _simulateDoorbellMessage(String topic, Function(String, Map<String, dynamic>) callback) {
    final testMessage = {
      'eventId': 'test_doorbell_${DateTime.now().millisecondsSinceEpoch}',
      'deviceId': 'test-device-001',
      'timestamp': DateTime.now().toIso8601String(),
      'eventType': 'doorbell_pressed',
      'metadata': {
        'location': 'Front Door',
        'deviceName': 'Test Doorphone'
      }
    };
    
    print('AWS IoT MQTT: Simulating doorbell message: $testMessage');
    callback(topic, testMessage);
  }

  @override
  Future<void> publish(String topic, Map<String, dynamic> message) async {
    if (!isConnected) {
      throw Exception('Not connected to AWS IoT');
    }

    try {
      final jsonMessage = jsonEncode(message);
      // For demo purposes, simulate publishing
      print('AWS IoT MQTT: Published to $topic (simulated): $jsonMessage');
    } catch (e) {
      print('AWS IoT MQTT: Publish failed for $topic - $e');
      rethrow;
    }
  }

  void _updateConnectionState(MQTTConnectionState state) {
    _currentState = state;
    _connectionStateController.add(state);
  }

  void _handleMessage(String topic, String message) {
    try {
      final Map<String, dynamic> jsonMessage = jsonDecode(message);

      // Find matching subscription callback
      for (final subscription in _subscriptions.entries) {
        if (_topicMatches(subscription.key, topic)) {
          subscription.value(topic, jsonMessage);
        }
      }
    } catch (e) {
      print('AWS IoT MQTT: Message parsing failed for $topic - $e');
    }
  }

  bool _topicMatches(String subscriptionTopic, String receivedTopic) {
    // Handle MQTT wildcards (+ for single level, # for multi-level)
    final subscriptionParts = subscriptionTopic.split('/');
    final receivedParts = receivedTopic.split('/');

    if (subscriptionParts.last == '#') {
      // Multi-level wildcard - check if prefix matches
      final prefixParts = subscriptionParts.sublist(
        0,
        subscriptionParts.length - 1,
      );
      if (receivedParts.length < prefixParts.length) return false;

      for (int i = 0; i < prefixParts.length; i++) {
        if (prefixParts[i] != '+' && prefixParts[i] != receivedParts[i]) {
          return false;
        }
      }
      return true;
    }

    if (subscriptionParts.length != receivedParts.length) return false;

    for (int i = 0; i < subscriptionParts.length; i++) {
      if (subscriptionParts[i] != '+' &&
          subscriptionParts[i] != receivedParts[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> _attemptReconnection() async {
    int attempts = 0;
    while (attempts < AppConfig.maxReconnectionAttempts && !isConnected) {
      attempts++;
      print('AWS IoT MQTT: Reconnection attempt $attempts');

      await Future.delayed(AppConfig.reconnectionDelay);

      try {
        await connect();
        break;
      } catch (e) {
        print('AWS IoT MQTT: Reconnection attempt $attempts failed - $e');
      }
    }
  }

  void dispose() {
    _connectionStateController.close();
    disconnect();
  }
}
