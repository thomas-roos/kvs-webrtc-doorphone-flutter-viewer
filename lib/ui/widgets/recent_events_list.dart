import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/doorphone_manager.dart';
import '../../models/doorbell_event.dart';

class RecentEventsList extends StatelessWidget {
  const RecentEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DoorphoneManager>(
      builder: (context, doorphoneManager, child) {
        return FutureBuilder<List<DoorbellEvent>>(
          future: doorphoneManager.getEventHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final events = snapshot.data ?? [];
            final recentEvents = events.take(5).toList();

            if (recentEvents.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No recent events',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: recentEvents.map((event) {
                return _buildEventItem(context, event);
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildEventItem(BuildContext context, DoorbellEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getEventColor(event.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getEventIcon(event.type),
              color: _getEventColor(event.type),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEventTitle(event.type),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Device: ${event.deviceId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          Text(
            _formatTimestamp(event.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.doorbell:
        return Icons.doorbell;
      case EventType.motion:
        return Icons.motion_photos_on;
      case EventType.access:
        return Icons.lock;
      case EventType.call:
        return Icons.call;
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.doorbell:
        return Colors.blue;
      case EventType.motion:
        return Colors.orange;
      case EventType.access:
        return Colors.green;
      case EventType.call:
        return Colors.purple;
    }
  }

  String _getEventTitle(EventType type) {
    switch (type) {
      case EventType.doorbell:
        return 'Doorbell Ring';
      case EventType.motion:
        return 'Motion Detected';
      case EventType.access:
        return 'Access Event';
      case EventType.call:
        return 'Call Event';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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
