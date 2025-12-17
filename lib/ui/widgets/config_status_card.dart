import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/config_service.dart';
import '../../models/aws_config.dart';

class ConfigStatusCard extends StatefulWidget {
  const ConfigStatusCard({super.key});

  @override
  State<ConfigStatusCard> createState() => _ConfigStatusCardState();
}

class _ConfigStatusCardState extends State<ConfigStatusCard> {
  AWSConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final configService = context.read<ConfigService>();
    final config = await configService.getAWSConfig();
    
    if (mounted) {
      setState(() {
        _config = config;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_config == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Configuration Required',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('AWS credentials and settings need to be configured.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Configuration Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConfigRow('Region', _config!.region),
            _buildConfigRow('IoT Endpoint', _config!.iotEndpoint),
            _buildConfigRow('KVS Channel', _config!.kvsChannelArn, maxLength: 50),
            _buildConfigRow('Access Key ID', _maskCredential(_config!.accessKeyId)),
            _buildConfigRow('Secret Key', _maskCredential(_config!.secretAccessKey)),
            if (_config!.sessionToken != null)
              _buildConfigRow('Session Token', 'Configured'),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value, {int? maxLength}) {
    String displayValue = value;
    if (maxLength != null && value.length > maxLength) {
      displayValue = '${value.substring(0, maxLength)}...';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _maskCredential(String credential) {
    if (credential.length <= 8) return '***';
    return '${credential.substring(0, 4)}***${credential.substring(credential.length - 4)}';
  }
}