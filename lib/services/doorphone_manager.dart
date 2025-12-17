import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/doorphone_device.dart';
import '../models/doorbell_event.dart';
import '../models/access_event.dart';
import '../core/app_config.dart';
import 'aws_iot_service.dart';
import 'kvs_webrtc_service.dart';

abstract class DoorphoneManager extends ChangeNotifier {
  Future<void> initializeAWSIoT(String endpoint, String certificatePath);
  Stream<DoorphoneDevice> get devices;
  List<DoorphoneDevice> get deviceList;
  DoorphoneDevice? get activeDevice;
  Future<void> connectToDevice(String deviceId);
  Future<void> disconnectFromDevice(String deviceId);
  Future<List<DoorbellEvent>> getEventHistory();
  Future<void> subscribeToMQTTTopic(String topic);
  Future<void> publishMQTTMessage(String topic, Map<String, dynamic> message);
  Future<void> unlockDoor(String deviceId);
  Future<void> lockDoor(String deviceId);
  Stream<DoorbellEvent> get doorbellEvents;
  Stream<AccessEvent> get accessEvents;
}

class DoorphoneManagerImpl extends DoorphoneManager {
  final AWSIoTService _awsIoTService;
  final KVSWebRTCService _kvsWebRTCService;
  
  final StreamController<DoorphoneDevice> _devicesController =
      StreamController<DoorphoneDevice>.broadcast();
  final StreamController<DoorbellEvent> _doorbellEventsController =
      StreamController<DoorbellEvent>.broadcast();
  final StreamController<AccessEvent> _accessEventsController =
      StreamController<AccessEvent>.broadcast();

  final List<DoorphoneDevice> _devices = [];
  final List<DoorbellEvent> _eventHistory = [];
  DoorphoneDevice? _activeDevice;

  DoorphoneManagerImpl({
    required AWSIoTService awsIoTService,
    required KVSWebRTCService kvsWebRTCService,
  }) : _awsIoTService = awsIoTService,
       _kvsWebRTCService = kvsWebRTCService;

  @override
  Stream<DoorphoneDevice> get devices => _devicesController.stream;

  @override
  List<DoorphoneDevice> get deviceList => List.unmodifiable(_devices);

  @override
  DoorphoneDevice? get activeDevice => _activeDevice;

  @override
  Stream<DoorbellEvent> get doorbellEvents => _doorbellEventsController.stream;

  @override
  Stream<AccessEvent> get accessEvents => _accessEventsController.stream;

  @override
  Future<void> initializeAWSIoT(String endpoint, String certificatePath) async {
    try {
      await _awsIoTService.initialize(
        endpoint,
        certificatePath,
        AppConfig.privateKeyPath,
      );
      
      await _awsIoTService.connect();
      
      // Subscribe to device registry and events
      await _subscribeToDeviceTopics();
      
      print('DoorphoneManager: AWS IoT initialized');
    } catch (e) {
      print('DoorphoneManager: AWS IoT initialization failed - $e');
      rethrow;
    }
  }

  @override
  Future<void> connectToDevice(String deviceId) async {
    final device = _devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => throw Exception('Device not found: $deviceId'),
    );

    try {
      // Initialize KVS WebRTC for this device
      await _kvsWebRTCService.initialize(device.kvsChannelName, device.awsRegion);
      await _kvsWebRTCService.connectAsViewer(device.kvsChannelName);
      
      // Update device status
      final updatedDevice = device.copyWith(status: DeviceStatus.connecting);
      _updateDevice(updatedDevice);
      
      // Set as active device
      _activeDevice = updatedDevice;
      
      // Subscribe to device-specific MQTT topics
      await _subscribeToDeviceSpecificTopics(deviceId);
      
      // Update status to online after successful connection
      final connectedDevice = updatedDevice.copyWith(status: DeviceStatus.online);
      _updateDevice(connectedDevice);
      _activeDevice = connectedDevice;
      
      notifyListeners();
      print('DoorphoneManager: Connected to device $deviceId');
    } catch (e) {
      print('DoorphoneManager: Failed to connect to device $deviceId - $e');
      final errorDevice = device.copyWith(status: DeviceStatus.error);
      _updateDevice(errorDevice);
      rethrow;
    }
  }

  @override
  Future<void> disconnectFromDevice(String deviceId) async {
    try {
      await _kvsWebRTCService.disconnect();
      
      final device = _devices.firstWhere((d) => d.id == deviceId);
      final disconnectedDevice = device.copyWith(status: DeviceStatus.offline);
      _updateDevice(disconnectedDevice);
      
      if (_activeDevice?.id == deviceId) {
        _activeDevice = null;
      }
      
      notifyListeners();
      print('DoorphoneManager: Disconnected from device $deviceId');
    } catch (e) {
      print('DoorphoneManager: Failed to disconnect from device $deviceId - $e');
    }
  }

  @override
  Future<List<DoorbellEvent>> getEventHistory() async {
    return List.unmodifiable(_eventHistory);
  }

  @override
  Future<void> subscribeToMQTTTopic(String topic) async {
    if (!_awsIoTService.isConnected) {
      throw Exception('AWS IoT not connected');
    }

    await _awsIoTService.subscribe(topic, _handleMQTTMessage);
  }

  @override
  Future<void> publishMQTTMessage(String topic, Map<String, dynamic> message) async {
    if (!_awsIoTService.isConnected) {
      throw Exception('AWS IoT not connected');
    }

    await _awsIoTService.publish(topic, message);
  }

  @override
  Future<void> unlockDoor(String deviceId) async {
    final device = _devices.firstWhere((d) => d.id == deviceId);
    final commandTopic = '${device.mqttTopic}/commands';
    
    final command = {
      'action': 'unlock',
      'deviceId': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
      'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    await publishMQTTMessage(commandTopic, command);
    print('DoorphoneManager: Unlock command sent to $deviceId');
  }

  @override
  Future<void> lockDoor(String deviceId) async {
    final device = _devices.firstWhere((d) => d.id == deviceId);
    final commandTopic = '${device.mqttTopic}/commands';
    
    final command = {
      'action': 'lock',
      'deviceId': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
      'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    await publishMQTTMessage(commandTopic, command);
    print('DoorphoneManager: Lock command sent to $deviceId');
  }

  Future<void> _subscribeToDeviceTopics() async {
    // Subscribe to device registry updates
    await subscribeToMQTTTopic(AppConfig.deviceRegistryTopic);
    
    // Subscribe to general device events
    await subscribeToMQTTTopic(AppConfig.deviceEventsTopic);
    
    // Subscribe to doorbell events
    await subscribeToMQTTTopic(AppConfig.doorbellEventsTopic);
  }

  Future<void> _subscribeToDeviceSpecificTopics(String deviceId) async {
    final device = _devices.firstWhere((d) => d.id == deviceId);
    
    // Subscribe to device-specific events
    await subscribeToMQTTTopic('${device.mqttTopic}/events');
    await subscribeToMQTTTopic('${device.mqttTopic}/doorbell');
    await subscribeToMQTTTopic('${device.mqttTopic}/access');
  }

  void _handleMQTTMessage(String topic, Map<String, dynamic> message) {
    try {
      if (topic.contains('/registry')) {
        _handleDeviceRegistryMessage(message);
      } else if (topic.contains('/doorbell')) {
        _handleDoorbellMessage(message);
      } else if (topic.contains('/access')) {
        _handleAccessMessage(message);
      } else if (topic.contains('/events')) {
        _handleGeneralEventMessage(message);
      }
    } catch (e) {
      print('DoorphoneManager: Failed to handle MQTT message - $e');
    }
  }

  void _handleDeviceRegistryMessage(Map<String, dynamic> message) {
    try {
      final device = DoorphoneDevice.fromJson(message);
      _addOrUpdateDevice(device);
    } catch (e) {
      print('DoorphoneManager: Failed to parse device registry message - $e');
    }
  }

  void _handleDoorbellMessage(Map<String, dynamic> message) {
    try {
      final event = DoorbellEvent.fromJson(message);
      _eventHistory.add(event);
      _doorbellEventsController.add(event);
      print('DoorphoneManager: Doorbell event received for device ${event.deviceId}');
    } catch (e) {
      print('DoorphoneManager: Failed to parse doorbell message - $e');
    }
  }

  void _handleAccessMessage(Map<String, dynamic> message) {
    try {
      final event = AccessEvent.fromJson(message);
      _accessEventsController.add(event);
      print('DoorphoneManager: Access event received for device ${event.deviceId}');
    } catch (e) {
      print('DoorphoneManager: Failed to parse access message - $e');
    }
  }

  void _handleGeneralEventMessage(Map<String, dynamic> message) {
    try {
      final eventType = message['type'] as String?;
      if (eventType == 'doorbell') {
        final event = DoorbellEvent.fromJson(message);
        _eventHistory.add(event);
        _doorbellEventsController.add(event);
      }
    } catch (e) {
      print('DoorphoneManager: Failed to parse general event message - $e');
    }
  }

  void _addOrUpdateDevice(DoorphoneDevice device) {
    final existingIndex = _devices.indexWhere((d) => d.id == device.id);
    
    if (existingIndex >= 0) {
      _devices[existingIndex] = device;
    } else {
      _devices.add(device);
    }
    
    _devicesController.add(device);
    notifyListeners();
  }

  void _updateDevice(DoorphoneDevice device) {
    final index = _devices.indexWhere((d) => d.id == device.id);
    if (index >= 0) {
      _devices[index] = device;
      _devicesController.add(device);
    }
  }

  @override
  void dispose() {
    _devicesController.close();
    _doorbellEventsController.close();
    _accessEventsController.close();
    _awsIoTService.disconnect();
    _kvsWebRTCService.disconnect();
    super.dispose();
  }
}