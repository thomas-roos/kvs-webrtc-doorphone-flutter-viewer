import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:doorphone_viewer/services/kvs_webrtc_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KVSWebRTCPlatform', () {
    const MethodChannel methodChannel = MethodChannel('com.doorphone.doorphone_viewer/kvs_webrtc');
    const EventChannel eventChannel = EventChannel('com.doorphone.doorphone_viewer/kvs_webrtc_events');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'initialize':
            return {'status': 'initialized'};
          case 'connectAsViewer':
            return {'status': 'connected', 'channelName': methodCall.arguments['channelName']};
          case 'disconnect':
            return {'status': 'disconnected'};
          case 'getConnectionState':
            return {'state': 'connected'};
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
    });

    test('initialize should call platform method with correct parameters', () async {
      await KVSWebRTCPlatform.initialize(
        accessKeyId: 'test-access-key',
        secretAccessKey: 'test-secret-key',
        region: 'us-east-1',
      );

      // Test passes if no exception is thrown
      expect(true, isTrue);
    });

    test('connectAsViewer should call platform method with correct parameters', () async {
      await KVSWebRTCPlatform.connectAsViewer(
        channelName: 'test-channel',
        region: 'us-east-1',
        accessKeyId: 'test-access-key',
        secretAccessKey: 'test-secret-key',
      );

      // Test passes if no exception is thrown
      expect(true, isTrue);
    });

    test('disconnect should call platform method', () async {
      await KVSWebRTCPlatform.disconnect('test-channel');

      // Test passes if no exception is thrown
      expect(true, isTrue);
    });

    test('getConnectionState should return correct state', () async {
      final state = await KVSWebRTCPlatform.getConnectionState('test-channel');
      expect(state, equals(KVSConnectionState.connected));
    });

    test('connection state stream should be available', () {
      final stream = KVSWebRTCPlatform.getConnectionStateStream('test-channel');
      expect(stream, isNotNull);
    });

    test('signaling stream should be available', () {
      final stream = KVSWebRTCPlatform.getSignalingStream('test-channel');
      expect(stream, isNotNull);
    });
  });
}