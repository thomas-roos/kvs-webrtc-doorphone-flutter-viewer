import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/doorphone_manager.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DoorphoneManager>(
      builder: (context, doorphoneManager, child) {
        final activeDevice = doorphoneManager.activeDevice;
        final hasDevices = doorphoneManager.deviceList.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (!hasDevices) ...[
                _buildDisabledAction(
                  context,
                  Icons.devices_other,
                  'No Devices Available',
                  'Connect doorphone devices to AWS IoT',
                ),
              ] else if (activeDevice == null) ...[
                _buildDisabledAction(
                  context,
                  Icons.play_circle_outline,
                  'No Active Device',
                  'Select a device to enable quick actions',
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        Icons.lock_open,
                        'Unlock Door',
                        Colors.green,
                        () => _unlockDoor(context, activeDevice.id),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        Icons.lock,
                        'Lock Door',
                        Colors.red,
                        () => _lockDoor(context, activeDevice.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        Icons.videocam,
                        'View Camera',
                        Colors.blue,
                        () => _viewCamera(context, activeDevice),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        Icons.history,
                        'View History',
                        Colors.orange,
                        () => _viewHistory(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledAction(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.outline, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockDoor(BuildContext context, String deviceId) async {
    try {
      final doorphoneManager = context.read<DoorphoneManager>();
      await doorphoneManager.unlockDoor(deviceId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Door unlocked successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unlock door: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _lockDoor(BuildContext context, String deviceId) async {
    try {
      final doorphoneManager = context.read<DoorphoneManager>();
      await doorphoneManager.lockDoor(deviceId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Door locked successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to lock door: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewCamera(BuildContext context, device) {
    // Navigate to video viewer
    Navigator.of(context).pushNamed('/video', arguments: device);
  }

  void _viewHistory(BuildContext context) {
    // Navigate to history screen
    Navigator.of(context).pushNamed('/history');
  }
}
