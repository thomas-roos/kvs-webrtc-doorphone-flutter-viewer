import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doorphone_viewer/services/config_service.dart';
import 'package:doorphone_viewer/models/aws_config.dart';

void main() {
  group('ConfigService Tests', () {
    late ConfigService configService;

    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      configService = ConfigServiceImpl();
    });

    test('should return null when no config is stored', () async {
      final config = await configService.getAWSConfig();
      expect(config, isNull);
    });

    test('should return false for hasValidConfig when no config exists', () async {
      final hasConfig = await configService.hasValidConfig();
      expect(hasConfig, isFalse);
    });

    test('should save and retrieve AWS config correctly', () async {
      // Create test config
      const testConfig = AWSConfig(
        region: 'us-east-1',
        iotEndpoint: 'test-endpoint.iot.us-east-1.amazonaws.com',
        kvsChannelArn: 'arn:aws:kinesisvideo:us-east-1:123456789012:channel/test-channel',
        accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
        secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
        sessionToken: 'test-session-token',
      );

      // Save config
      await configService.saveAWSConfig(testConfig);

      // Retrieve config
      final retrievedConfig = await configService.getAWSConfig();

      // Verify config was saved correctly
      expect(retrievedConfig, isNotNull);
      expect(retrievedConfig!.region, equals(testConfig.region));
      expect(retrievedConfig.iotEndpoint, equals(testConfig.iotEndpoint));
      expect(retrievedConfig.kvsChannelArn, equals(testConfig.kvsChannelArn));
      expect(retrievedConfig.accessKeyId, equals(testConfig.accessKeyId));
      expect(retrievedConfig.secretAccessKey, equals(testConfig.secretAccessKey));
      expect(retrievedConfig.sessionToken, equals(testConfig.sessionToken));
    });

    test('should return true for hasValidConfig when valid config exists', () async {
      const testConfig = AWSConfig(
        region: 'us-west-2',
        iotEndpoint: 'test-endpoint.iot.us-west-2.amazonaws.com',
        kvsChannelArn: 'arn:aws:kinesisvideo:us-west-2:123456789012:channel/test-channel',
        accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
        secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
      );

      await configService.saveAWSConfig(testConfig);
      final hasConfig = await configService.hasValidConfig();
      expect(hasConfig, isTrue);
    });

    test('should clear config correctly', () async {
      // Save a config first
      const testConfig = AWSConfig(
        region: 'eu-west-1',
        iotEndpoint: 'test-endpoint.iot.eu-west-1.amazonaws.com',
        kvsChannelArn: 'arn:aws:kinesisvideo:eu-west-1:123456789012:channel/test-channel',
        accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
        secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
      );

      await configService.saveAWSConfig(testConfig);
      expect(await configService.hasValidConfig(), isTrue);

      // Clear config
      await configService.clearAWSConfig();

      // Verify config is cleared
      expect(await configService.getAWSConfig(), isNull);
      expect(await configService.hasValidConfig(), isFalse);
    });

    test('should handle config without session token', () async {
      const testConfig = AWSConfig(
        region: 'ap-southeast-1',
        iotEndpoint: 'test-endpoint.iot.ap-southeast-1.amazonaws.com',
        kvsChannelArn: 'arn:aws:kinesisvideo:ap-southeast-1:123456789012:channel/test-channel',
        accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
        secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
        // No session token
      );

      await configService.saveAWSConfig(testConfig);
      final retrievedConfig = await configService.getAWSConfig();

      expect(retrievedConfig, isNotNull);
      expect(retrievedConfig!.sessionToken, isNull);
      expect(await configService.hasValidConfig(), isTrue);
    });
  });

  group('AWSConfig Model Tests', () {
    test('should create AWSConfig from JSON correctly', () {
      final json = {
        'region': 'us-east-1',
        'iotEndpoint': 'test-endpoint.iot.us-east-1.amazonaws.com',
        'kvsChannelArn': 'arn:aws:kinesisvideo:us-east-1:123456789012:channel/test-channel',
        'accessKeyId': 'AKIAIOSFODNN7EXAMPLE',
        'secretAccessKey': 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
        'sessionToken': 'test-session-token',
      };

      final config = AWSConfig.fromJson(json);

      expect(config.region, equals('us-east-1'));
      expect(config.iotEndpoint, equals('test-endpoint.iot.us-east-1.amazonaws.com'));
      expect(config.kvsChannelArn, equals('arn:aws:kinesisvideo:us-east-1:123456789012:channel/test-channel'));
      expect(config.accessKeyId, equals('AKIAIOSFODNN7EXAMPLE'));
      expect(config.secretAccessKey, equals('wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'));
      expect(config.sessionToken, equals('test-session-token'));
    });

    test('should convert AWSConfig to JSON correctly', () {
      const config = AWSConfig(
        region: 'us-west-2',
        iotEndpoint: 'test-endpoint.iot.us-west-2.amazonaws.com',
        kvsChannelArn: 'arn:aws:kinesisvideo:us-west-2:123456789012:channel/test-channel',
        accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
        secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
      );

      final json = config.toJson();

      expect(json['region'], equals('us-west-2'));
      expect(json['iotEndpoint'], equals('test-endpoint.iot.us-west-2.amazonaws.com'));
      expect(json['kvsChannelArn'], equals('arn:aws:kinesisvideo:us-west-2:123456789012:channel/test-channel'));
      expect(json['accessKeyId'], equals('AKIAIOSFODNN7EXAMPLE'));
      expect(json['secretAccessKey'], equals('wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'));
      expect(json['sessionToken'], isNull);
    });

    test('should support copyWith method', () {
      const originalConfig = AWSConfig(
        region: 'us-east-1',
        iotEndpoint: 'original-endpoint.iot.us-east-1.amazonaws.com',
        kvsChannelArn: 'arn:aws:kinesisvideo:us-east-1:123456789012:channel/original-channel',
        accessKeyId: 'ORIGINAL_ACCESS_KEY',
        secretAccessKey: 'original-secret-key',
      );

      final updatedConfig = originalConfig.copyWith(
        region: 'us-west-2',
        iotEndpoint: 'updated-endpoint.iot.us-west-2.amazonaws.com',
      );

      expect(updatedConfig.region, equals('us-west-2'));
      expect(updatedConfig.iotEndpoint, equals('updated-endpoint.iot.us-west-2.amazonaws.com'));
      expect(updatedConfig.kvsChannelArn, equals(originalConfig.kvsChannelArn));
      expect(updatedConfig.accessKeyId, equals(originalConfig.accessKeyId));
      expect(updatedConfig.secretAccessKey, equals(originalConfig.secretAccessKey));
    });
  });
}