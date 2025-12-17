import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aws_config.dart';
import '../core/utils/logger.dart';

abstract class ConfigService {
  Future<AWSConfig?> getAWSConfig();
  Future<void> saveAWSConfig(AWSConfig config);
  Future<void> clearAWSConfig();
  Future<bool> hasValidConfig();
}

class ConfigServiceImpl implements ConfigService {
  static const Logger _logger = Logger('ConfigService');
  static const String _awsConfigKey = 'aws_config';

  @override
  Future<AWSConfig?> getAWSConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_awsConfigKey);
      
      if (configJson == null) return null;
      
      final configMap = json.decode(configJson) as Map<String, dynamic>;
      return AWSConfig.fromJson(configMap);
    } catch (e) {
      _logger.error('Error loading AWS config', e);
      return null;
    }
  }

  @override
  Future<void> saveAWSConfig(AWSConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(config.toJson());
      await prefs.setString(_awsConfigKey, configJson);
    } catch (e) {
      _logger.error('Error saving AWS config', e);
      throw Exception('Failed to save configuration');
    }
  }

  @override
  Future<void> clearAWSConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_awsConfigKey);
    } catch (e) {
      _logger.error('Error clearing AWS config', e);
    }
  }

  @override
  Future<bool> hasValidConfig() async {
    final config = await getAWSConfig();
    return config != null &&
        config.region.isNotEmpty &&
        config.iotEndpoint.isNotEmpty &&
        config.kvsChannelArn.isNotEmpty &&
        config.accessKeyId.isNotEmpty &&
        config.secretAccessKey.isNotEmpty;
  }
}