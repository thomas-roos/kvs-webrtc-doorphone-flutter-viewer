import 'dart:async';
import 'dart:typed_data';
import '../core/utils/logger.dart';
import 'kvs_webrtc_platform.dart';

enum WebRTCSignalingState { idle, connecting, connected, failed }

class VideoFrame {
  final Uint8List data;
  final int width;
  final int height;
  final VideoFormat format;
  final DateTime timestamp;

  const VideoFrame({
    required this.data,
    required this.width,
    required this.height,
    required this.format,
    required this.timestamp,
  });
}

enum VideoFormat { h264, mjpeg, webrtc }

abstract class KVSWebRTCService {
  Future<void> initialize(String channelName, String region);
  Future<void> createSignalingChannel(String channelName);
  Future<void> connectAsViewer(String channelName);
  Future<void> sendOffer(Map<String, dynamic> offer);
  Future<void> sendAnswer(Map<String, dynamic> answer);
  Future<void> sendIceCandidate(Map<String, dynamic> candidate);
  Stream<Map<String, dynamic>> get signalingMessages;
  Stream<VideoFrame> get videoStream;
  Stream<WebRTCSignalingState> get connectionState;
  Future<void> disconnect();
  bool get isConnected;
}

class KVSWebRTCServiceImpl implements KVSWebRTCService {
  static const Logger _logger = Logger('KVSWebRTCService');
  
  String? _currentChannelName;
  String? _accessKeyId;
  String? _secretAccessKey;
  String? _region;

  final StreamController<Map<String, dynamic>> _signalingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<VideoFrame> _videoStreamController =
      StreamController<VideoFrame>.broadcast();
  final StreamController<WebRTCSignalingState> _connectionStateController =
      StreamController<WebRTCSignalingState>.broadcast();

  WebRTCSignalingState _currentState = WebRTCSignalingState.idle;
  bool _isInitialized = false;
  StreamSubscription? _platformStateSubscription;
  StreamSubscription? _platformSignalingSubscription;


  @override
  Stream<Map<String, dynamic>> get signalingMessages =>
      _signalingController.stream;

  @override
  Stream<VideoFrame> get videoStream => _videoStreamController.stream;

  @override
  Stream<WebRTCSignalingState> get connectionState =>
      _connectionStateController.stream;

  @override
  bool get isConnected => _currentState == WebRTCSignalingState.connected;

  @override
  Future<void> initialize(String channelName, String region) async {
    try {
      _currentChannelName = channelName;
      _region = region;
      
      // Initialize platform channel if credentials are available
      if (_accessKeyId != null && _secretAccessKey != null) {
        await KVSWebRTCPlatform.initialize(
          accessKeyId: _accessKeyId!,
          secretAccessKey: _secretAccessKey!,
          region: region,
        );
      }

      _isInitialized = true;
      _logger.info('Initialized for channel $channelName in region $region');
    } catch (e) {
      _logger.error('Initialization failed', e);
      _updateConnectionState(WebRTCSignalingState.failed);
      rethrow;
    }
  }
  
  /// Set AWS credentials for KVS WebRTC
  Future<void> setCredentials({
    required String accessKeyId,
    required String secretAccessKey,
  }) async {
    _accessKeyId = accessKeyId;
    _secretAccessKey = secretAccessKey;
    
    if (_isInitialized && _region != null) {
      await KVSWebRTCPlatform.initialize(
        accessKeyId: accessKeyId,
        secretAccessKey: secretAccessKey,
        region: _region!,
      );
    }
  }

  @override
  Future<void> createSignalingChannel(String channelName) async {
    if (!_isInitialized) {
      throw Exception('KVS WebRTC service not initialized');
    }

    try {
      // For demo purposes, simulate signaling channel creation
      _logger.info('Signaling channel created for $channelName (simulated)');
    } catch (e) {
      _logger.error('Failed to create signaling channel', e);
      rethrow;
    }
  }

  @override
  Future<void> connectAsViewer(String channelName) async {
    if (!_isInitialized) {
      throw Exception('KVS WebRTC service not initialized');
    }

    if (_accessKeyId == null || _secretAccessKey == null || _region == null) {
      throw Exception('AWS credentials not set. Call setCredentials() first.');
    }

    try {
      _currentChannelName = channelName;
      _updateConnectionState(WebRTCSignalingState.connecting);

      // Connect using platform channel
      await KVSWebRTCPlatform.connectAsViewer(
        channelName: channelName,
        region: _region!,
        accessKeyId: _accessKeyId!,
        secretAccessKey: _secretAccessKey!,
      );

      // Listen to platform events
      _platformStateSubscription?.cancel();
      _platformStateSubscription = KVSWebRTCPlatform.getConnectionStateStream(channelName)
          .listen((state) {
        _updateConnectionState(_mapPlatformState(state));
      });

      _platformSignalingSubscription?.cancel();
      _platformSignalingSubscription = KVSWebRTCPlatform.getSignalingStream(channelName)
          .listen((message) {
        _signalingController.add(message);
        _handleSignalingMessage(message);
      });

      _updateConnectionState(WebRTCSignalingState.connected);
      _logger.info('Connected as viewer to $channelName');
    } catch (e) {
      _logger.error('Failed to connect as viewer', e);
      _updateConnectionState(WebRTCSignalingState.failed);
      rethrow;
    }
  }

  @override
  Future<void> sendOffer(Map<String, dynamic> offer) async {
    if (!isConnected || _currentChannelName == null) {
      throw Exception('Not connected to KVS WebRTC');
    }

    try {
      await KVSWebRTCPlatform.sendOffer(
        channelName: _currentChannelName!,
        offer: offer,
      );
      _logger.debug('Offer sent');
    } catch (e) {
      _logger.error('Failed to send offer', e);
      rethrow;
    }
  }

  @override
  Future<void> sendAnswer(Map<String, dynamic> answer) async {
    if (!isConnected || _currentChannelName == null) {
      throw Exception('Not connected to KVS WebRTC');
    }

    try {
      await KVSWebRTCPlatform.sendAnswer(
        channelName: _currentChannelName!,
        answer: answer,
      );
      _logger.debug('Answer sent');
    } catch (e) {
      _logger.error('Failed to send answer', e);
      rethrow;
    }
  }

  @override
  Future<void> sendIceCandidate(Map<String, dynamic> candidate) async {
    if (!isConnected || _currentChannelName == null) {
      throw Exception('Not connected to KVS WebRTC');
    }

    try {
      await KVSWebRTCPlatform.sendIceCandidate(
        channelName: _currentChannelName!,
        candidate: candidate,
      );
      _logger.debug('ICE candidate sent');
    } catch (e) {
      _logger.error('Failed to send ICE candidate', e);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      if (_currentChannelName != null) {
        await KVSWebRTCPlatform.disconnect(_currentChannelName!);
      }
      
      _platformStateSubscription?.cancel();
      _platformSignalingSubscription?.cancel();
      _platformStateSubscription = null;
      _platformSignalingSubscription = null;
      
      _currentChannelName = null;
      _updateConnectionState(WebRTCSignalingState.idle);
      _logger.info('Disconnected');
    } catch (e) {
      _logger.error('Disconnect failed', e);
    }
  }

  WebRTCSignalingState _mapPlatformState(KVSConnectionState platformState) {
    switch (platformState) {
      case KVSConnectionState.idle:
        return WebRTCSignalingState.idle;
      case KVSConnectionState.connecting:
        return WebRTCSignalingState.connecting;
      case KVSConnectionState.connected:
        return WebRTCSignalingState.connected;
      case KVSConnectionState.failed:
      case KVSConnectionState.disconnected:
        return WebRTCSignalingState.failed;
    }
  }

  void _handleSignalingMessage(Map<String, dynamic> message) {
    final messageType = message['type'] as String?;
    
    switch (messageType) {
      case 'remoteStreamAdded':
        _handleRemoteStreamAdded(message);
        break;
      case 'iceCandidate':
        // ICE candidate received from remote peer
        _logger.debug('ICE candidate received');
        break;
      case 'iceConnectionStateChanged':
        _logger.debug('ICE connection state: ${message['state']}');
        break;
    }
  }

  void _handleRemoteStreamAdded(Map<String, dynamic> message) {
    _logger.info('Remote stream added: ${message['streamId']}');

    // Emit a placeholder VideoFrame for the UI
    // In a real implementation, the platform channel would provide actual video frames
    final videoFrame = VideoFrame(
      data: Uint8List(0),
      width: 1920,
      height: 1080,
      format: VideoFormat.webrtc,
      timestamp: DateTime.now(),
    );

    _videoStreamController.add(videoFrame);
  }

  void _updateConnectionState(WebRTCSignalingState state) {
    _currentState = state;
    _connectionStateController.add(state);
  }

  void dispose() {
    _platformStateSubscription?.cancel();
    _platformSignalingSubscription?.cancel();
    _signalingController.close();
    _videoStreamController.close();
    _connectionStateController.close();
    disconnect();
    KVSWebRTCPlatform.dispose();
  }
}
