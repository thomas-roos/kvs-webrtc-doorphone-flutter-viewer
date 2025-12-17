import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/doorphone_manager.dart';
import '../../services/config_service.dart';
import '../../models/aws_config.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  AWSConfig? _config;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _setupLogListener();
  }

  Future<void> _loadConfig() async {
    final configService = context.read<ConfigService>();
    final config = await configService.getAWSConfig();
    setState(() {
      _config = config;
    });
  }

  void _setupLogListener() {
    // Add some initial logs
    _addLog('Debug screen initialized');
    _addLog('Checking AWS configuration...');
    
    if (_config != null) {
      _addLog('✅ AWS configuration found');
      _addLog('Region: ${_config!.region}');
      _addLog('IoT Endpoint: ${_config!.iotEndpoint}');
    } else {
      _addLog('❌ No AWS configuration found');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String().substring(11, 19)}: $message');
    });
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _testMQTTConnection() {
    _addLog('🔄 Testing MQTT connection...');
    final doorphoneManager = context.read<DoorphoneManager>();
    
    // Check connection state
    _addLog('Connection state: ${doorphoneManager.connectionState}');
    
    if (_config != null) {
      _addLog('Attempting to connect to: ${_config!.iotEndpoint}');
      // The connection attempt will be logged by the service
    } else {
      _addLog('❌ Cannot test connection - no configuration');
    }
  }

  void _simulateDoorbellEvent() {
    _addLog('🔔 Simulating doorbell event...');
    
    // You can add code here to simulate a doorbell event
    // This would help test the notification system
    _addLog('Doorbell simulation not implemented yet');
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    _addLog('Logs cleared');
  }

  void _copyLogsToClipboard() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug & Diagnostics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogsToClipboard,
            tooltip: 'Copy logs',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testMQTTConnection,
                        icon: const Icon(Icons.wifi_find),
                        label: const Text('Test MQTT'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _simulateDoorbellEvent,
                        icon: const Icon(Icons.notifications),
                        label: const Text('Test Doorbell'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Configuration Summary
                if (_config != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Configuration:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Region: ${_config!.region}'),
                        Text('Endpoint: ${_config!.iotEndpoint}'),
                        Text('Channel: ${_config!.kvsChannelArn.length > 50 ? "${_config!.kvsChannelArn.substring(0, 50)}..." : _config!.kvsChannelArn}'),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '❌ No AWS configuration found. Please configure in settings.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          
          // Logs Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Debug Logs',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}