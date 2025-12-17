import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/doorphone_manager.dart';
import '../../models/doorbell_event.dart';

class EventHistoryScreen extends StatelessWidget {
  const EventHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Consumer<DoorphoneManager>(
        builder: (context, doorphoneManager, child) {
          return FutureBuilder<List<DoorbellEvent>>(
            future: doorphoneManager.getEventHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final events = snapshot.data ?? [];

              if (events.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No events found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(context, event);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, DoorbellEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventColor(event.type).withOpacity(0.1),
          child: Icon(
            _getEventIcon(event.type),
            color: _getEventColor(event.type),
          ),
        ),
        title: Text(_getEventTitle(event.type)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device: ${event.deviceId}'),
            Text(_formatTimestamp(event.timestamp)),
          ],
        ),
        trailing: event.visitorImage != null ? const Icon(Icons.photo) : null,
        onTap: () {
          _showEventDetails(context, event);
        },
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

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _showEventDetails(BuildContext context, DoorbellEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getEventTitle(event.type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event ID: ${event.id}'),
            Text('Device ID: ${event.deviceId}'),
            Text('Timestamp: ${event.timestamp}'),
            if (event.callDuration != null)
              Text('Duration: ${event.callDuration}'),
            if (event.metadata != null) Text('Metadata: ${event.metadata}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
