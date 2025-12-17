import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/aws_iot_service.dart';
import '../../services/doorphone_manager.dart';

class ConnectionStatusCard extends StatelessWidget {
  const ConnectionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DoorphoneManager>(
      builder: (context, doorphoneManager, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      color: _getConnectionColor(doorphoneManager.connectionState),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // AWS IoT Connection Status
                _buildStatusRow(
                  'AWS IoT MQTT',
                  _getConnectionStatusText(doorphoneManager.connectionState),
                  _getConnectionColor(doorphoneManager.connectionState),
                ),
                
                // Device Count
                _buildStatusRow(
                  'Registered Devices',
                  '${doorphoneManager.deviceList.length}',
                  doorphoneManager.deviceList.isNotEmpty ? Colors.green : Colors.orange,
                ),
                
                // Active Device
                _buildStatusRow(
                  'Active Device',
                  doorphoneManager.activeDevice?.name ?? 'None',
                  doorphoneManager.activeDevice != null ? Colors.green : Colors.grey,
                ),
                
                const SizedBox(height: 8),
                
                // Debug Info
                if (doorphoneManager.connectionState != MQTTConnectionState.connected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Troubleshooting:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('• Check AWS credentials in settings'),
                        Text('• Verify IoT endpoint is correct'),
                        Text('• Ensure device has internet connection'),
                        Text('• Check AWS IoT policies and permissions'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConnectionColor(MQTTConnectionState state) {
    switch (state) {
      case MQTTConnectionState.connected:
        return Colors.green;
      case MQTTConnectionState.connecting:
        return Colors.orange;
      case MQTTConnectionState.disconnected:
        return Colors.grey;
      case MQTTConnectionState.error:
        return Colors.red;
    }
  }

  String _getConnectionStatusText(MQTTConnectionState state) {
    switch (state) {
      case MQTTConnectionState.connected:
        return 'Connected';
      case MQTTConnectionState.connecting:
        return 'Connecting...';
      case MQTTConnectionState.disconnected:
        return 'Disconnected';
      case MQTTConnectionState.error:
        return 'Error';
    }
  }
}