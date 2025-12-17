import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/aws_config.dart';
import '../../services/config_service.dart';
import '../widgets/config_status_card.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _iotEndpointController = TextEditingController();
  final _kvsChannelArnController = TextEditingController();
  final _accessKeyIdController = TextEditingController();
  final _secretAccessKeyController = TextEditingController();
  final _sessionTokenController = TextEditingController();

  bool _isLoading = false;
  bool _obscureSecretKey = true;
  bool _obscureSessionToken = true;

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    final configService = context.read<ConfigService>();
    final config = await configService.getAWSConfig();
    
    if (config != null) {
      setState(() {
        _regionController.text = config.region;
        _iotEndpointController.text = config.iotEndpoint;
        _kvsChannelArnController.text = config.kvsChannelArn;
        _accessKeyIdController.text = config.accessKeyId;
        _secretAccessKeyController.text = config.secretAccessKey;
        _sessionTokenController.text = config.sessionToken ?? '';
      });
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final config = AWSConfig(
        region: _regionController.text.trim(),
        iotEndpoint: _iotEndpointController.text.trim(),
        kvsChannelArn: _kvsChannelArnController.text.trim(),
        accessKeyId: _accessKeyIdController.text.trim(),
        secretAccessKey: _secretAccessKeyController.text.trim(),
        sessionToken: _sessionTokenController.text.trim().isEmpty 
            ? null 
            : _sessionTokenController.text.trim(),
      );

      final configService = context.read<ConfigService>();
      await configService.saveAWSConfig(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving configuration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearConfig() async {
    final configService = context.read<ConfigService>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Configuration'),
        content: const Text('Are you sure you want to clear all AWS configuration? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await configService.clearAWSConfig();

        // Clear form fields
        _regionController.clear();
        _iotEndpointController.clear();
        _kvsChannelArnController.clear();
        _accessKeyIdController.clear();
        _secretAccessKeyController.clear();
        _sessionTokenController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuration cleared successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing configuration: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _regionController.dispose();
    _iotEndpointController.dispose();
    _kvsChannelArnController.dispose();
    _accessKeyIdController.dispose();
    _secretAccessKeyController.dispose();
    _sessionTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWS Configuration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your AWS credentials and configuration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              // Current Configuration Status
              const ConfigStatusCard(),
              const SizedBox(height: 24),
              
              // AWS Region
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: 'AWS Region',
                  hintText: 'us-east-1, us-west-2, eu-west-1, etc.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.public),
                  helperText: 'The AWS region where your IoT and KVS resources are located',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'AWS Region is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // IoT Endpoint
              TextFormField(
                controller: _iotEndpointController,
                decoration: const InputDecoration(
                  labelText: 'IoT Endpoint',
                  hintText: 'a1b2c3d4e5f6g7-ats.iot.us-east-1.amazonaws.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cloud),
                  helperText: 'Your AWS IoT Core device data endpoint',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'IoT Endpoint is required';
                  }
                  if (!value.contains('.iot.') || !value.contains('.amazonaws.com')) {
                    return 'Please enter a valid IoT endpoint';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // KVS Channel ARN
              TextFormField(
                controller: _kvsChannelArnController,
                decoration: const InputDecoration(
                  labelText: 'KVS Channel ARN',
                  hintText: 'arn:aws:kinesisvideo:us-east-1:123456789012:channel/doorphone-channel',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.video_library),
                  helperText: 'The ARN of your Kinesis Video Streams signaling channel',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'KVS Channel ARN is required';
                  }
                  if (!value.startsWith('arn:aws:kinesisvideo:')) {
                    return 'Please enter a valid KVS Channel ARN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Access Key ID
              TextFormField(
                controller: _accessKeyIdController,
                decoration: const InputDecoration(
                  labelText: 'Access Key ID',
                  hintText: 'AKIA...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Access Key ID is required';
                  }
                  if (value.length < 16) {
                    return 'Access Key ID must be at least 16 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Secret Access Key
              TextFormField(
                controller: _secretAccessKeyController,
                decoration: InputDecoration(
                  labelText: 'Secret Access Key',
                  hintText: 'Enter your secret access key',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureSecretKey ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureSecretKey = !_obscureSecretKey;
                      });
                    },
                  ),
                ),
                obscureText: _obscureSecretKey,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Secret Access Key is required';
                  }
                  if (value.length < 20) {
                    return 'Secret Access Key must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Session Token (Optional)
              TextFormField(
                controller: _sessionTokenController,
                decoration: InputDecoration(
                  labelText: 'Session Token (Optional)',
                  hintText: 'Enter session token if using temporary credentials',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.token),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureSessionToken ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureSessionToken = !_obscureSessionToken;
                      });
                    },
                  ),
                ),
                obscureText: _obscureSessionToken,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _clearConfig,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Clear Config'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveConfig,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Configuration',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your credentials are stored securely on this device and are not transmitted to any third parties.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}