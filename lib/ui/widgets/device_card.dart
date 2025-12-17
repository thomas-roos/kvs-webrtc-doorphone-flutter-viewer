import 'package:flutter/material.dart';
import '../../models/doorphone_device.dart';

class DeviceCard extends StatelessWidget {
  final DoorphoneDevice device;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DeviceCard({
    super.key,
    required this.device,
    this.isActive = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Device Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getStatusColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.video_camera_front,
                      color: _getStatusColor(context),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Device Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          device.ipAddress,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _getStatusColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Device Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.cloud,
                      'Region',
                      device.awsRegion,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.access_time,
                      'Last Seen',
                      _formatLastSeen(),
                    ),
                  ),
                ],
              ),

              if (device.capabilities.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: device.capabilities.map((capability) {
                    return Chip(
                      label: Text(
                        capability,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],

              if (isActive) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active Device',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (device.status) {
      case DeviceStatus.online:
        return Colors.green;
      case DeviceStatus.offline:
        return Colors.grey;
      case DeviceStatus.connecting:
        return Colors.orange;
      case DeviceStatus.error:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (device.status) {
      case DeviceStatus.online:
        return 'Online';
      case DeviceStatus.offline:
        return 'Offline';
      case DeviceStatus.connecting:
        return 'Connecting';
      case DeviceStatus.error:
        return 'Error';
    }
  }

  String _formatLastSeen() {
    final now = DateTime.now();
    final difference = now.difference(device.lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
