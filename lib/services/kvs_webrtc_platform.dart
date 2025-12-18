import 'dart:async';
import 'package:flutter/services.dart';
import '../core/utils/logger.dart';

enum KVSConnectionState { idle, connecting, connected, failed, disconnected }

class KVSWebRTCPlatform {
  static const Logger _logger = Logger('KVSWebRTCPlatform');
  
  static const MethodChannel _methodChannel = 
      MethodChannel('com.doorphone.doorphone_viewer/kvs_webrtc');
  static const EventChannel _eventChannel = 
      EventChannel('com.doorphone.doorphone_viewer/kvs_webrtc_events');

  static Stream<Map<String, dynamic>>? _eventStream;
  static final Map<String, StreamController<KVSConnectionState>> _connectionStateControllers = {};
  static final Map<String, StreamController<Map<String, dynamic>>> _signalingControllers = {};

  /// Initialize the KVS WebRTC platform with AWS credentials
  static Future<void> initialize({
    required String accessKeyId,
    required String secretAccessKey,
    required String region,
  }) async {
    try {
      await _methodChannel.invokeMethod('initialize', {
        'accessKeyId': accessKeyId,
        'secretAccessKey': secretAccessKey,
        'region': region,
      });
      
      // Start listening to events
      _startEventListener();
      
      _logger.info('KVS WebRTC platform initialized');
    } catch (e) {
      _logger.error('Failed to initialize KVS WebRTC platform', e);
      rethrow;
    }
  }

  /// Connect to a KVS WebRTC channel as a viewer
  static Future<void> connectAsViewer({
    required String channelName,
    required String region,
    required String accessKeyId,
    required String secretAccessKey,
  }) async {
    try {
      await _methodChannel.invokeMethod('connectAsViewer', {
        'channelName': channelName,
        'region': region,
        'accessKeyId': accessKeyId,
        'secretAccessKey': secretAccessKey,
      });
      
      _logger.info('Connected as viewer to channel: $channelName');
    } catch (e) {
      _logger.error('Failed to connect as viewer to $channelName', e);
      rethrow;
    }
  }

  /// Disconnect from a KVS WebRTC channel
  static Future<void> disconnect(String channelName) async {
    try {
      await _methodChannel.invokeMethod('disconnect', {
        'channelName': channelName,
      });
      
      _logger.info('Disconnected from channel: $channelName');
    } catch (e) {
      _logger.error('Failed to disconnect from $channelName', e);
      rethrow;
    }
  }

  /// Send WebRTC offer
  static Future<void> sendOffer({
    required String channelName,
    required Map<String, dynamic> offer,
  }) async {
    try {
      await _methodChannel.invokeMethod('sendOffer', {
        'channelName': channelName,
        'offer': offer,
      });
    } catch (e) {
      _logger.error('Failed to send offer for $channelName', e);
      rethrow;
    }
  }

  /// Send WebRTC answer
  static Future<void> sendAnswer({
    required String channelName,
    required Map<String, dynamic> answer,
  }) async {
    try {
      await _methodChannel.invokeMethod('sendAnswer', {
        'channelName': channelName,
        'answer': answer,
      });
    } catch (e) {
      _logger.error('Failed to send answer for $channelName', e);
      rethrow;
    }
  }

  /// Send ICE candidate
  static Future<void> sendIceCandidate({
    required String channelName,
    required Map<String, dynamic> candidate,
  }) async {
    try {
      await _methodChannel.invokeMethod('sendIceCandidate', {
        'channelName': channelName,
        'candidate': candidate,
      });
    } catch (e) {
      _logger.error('Failed to send ICE candidate for $channelName', e);
      rethrow;
    }
  }

  /// Get current connection state for a channel
  static Future<KVSConnectionState> getConnectionState(String channelName) async {
    try {
      final result = await _methodChannel.invokeMethod('getConnectionState', {
        'channelName': channelName,
      });
      
      final state = result['state'] as String;
      return _parseConnectionState(state);
    } catch (e) {
      _logger.error('Failed to get connection state for $channelName', e);
      return KVSConnectionState.failed;
    }
  }

  /// Get connection state stream for a specific channel
  static Stream<KVSConnectionState> getConnectionStateStream(String channelName) {
    if (!_connectionStateControllers.containsKey(channelName)) {
      _connectionStateControllers[channelName] = StreamController<KVSConnectionState>.broadcast();
    }
    return _connectionStateControllers[channelName]!.stream;
  }

  /// Get signaling messages stream for a specific channel
  static Stream<Map<String, dynamic>> getSignalingStream(String channelName) {
    if (!_signalingControllers.containsKey(channelName)) {
      _signalingControllers[channelName] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _signalingControllers[channelName]!.stream;
  }

  static void _startEventListener() {
    _eventStream ??= _eventChannel.receiveBroadcastStream().cast<Map<String, dynamic>>();
    
    _eventStream!.listen((event) {
      final eventType = event['type'] as String?;
      final channelName = event['channelName'] as String?;
      
      if (channelName == null) return;
      
      switch (eventType) {
        case 'connectionStateChanged':
          final state = _parseConnectionState(event['state'] as String);
          _connectionStateControllers[channelName]?.add(state);
          break;
          
        case 'iceCandidate':
          final candidate = event['candidate'] as Map<String, dynamic>?;
          if (candidate != null) {
            _signalingControllers[channelName]?.add({
              'type': 'iceCandidate',
              'candidate': candidate,
            });
          }
          break;
          
        case 'remoteStreamAdded':
          _signalingControllers[channelName]?.add({
            'type': 'remoteStreamAdded',
            'streamId': event['streamId'],
          });
          break;
          
        case 'iceConnectionStateChanged':
          _signalingControllers[channelName]?.add({
            'type': 'iceConnectionStateChanged',
            'state': event['state'],
          });
          break;
      }
    }, onError: (error) {
      _logger.error('Event stream error', error);
    });
  }

  static KVSConnectionState _parseConnectionState(String state) {
    switch (state.toLowerCase()) {
      case 'connecting':
        return KVSConnectionState.connecting;
      case 'connected':
        return KVSConnectionState.connected;
      case 'failed':
        return KVSConnectionState.failed;
      case 'disconnected':
        return KVSConnectionState.disconnected;
      default:
        return KVSConnectionState.idle;
    }
  }

  /// Dispose all resources
  static void dispose() {
    for (final controller in _connectionStateControllers.values) {
      controller.close();
    }
    for (final controller in _signalingControllers.values) {
      controller.close();
    }
    _connectionStateControllers.clear();
    _signalingControllers.clear();
  }
}