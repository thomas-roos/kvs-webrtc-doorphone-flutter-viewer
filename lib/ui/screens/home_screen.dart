import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/doorphone_manager.dart';
import '../../services/notification_service.dart';
import '../../models/doorphone_device.dart';
import '../../models/doorbell_event.dart';
import '../widgets/device_card.dart';
import '../widgets/recent_events_list.dart';
import '../widgets/quick_actions_panel.dart';
import 'device_list_screen.dart';
import 'video_viewer_screen.dart';
import 'event_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    final notificationService = context.read<NotificationService>();
    
    notificationService.notificationStream.listen((message) {
      if (message.data['type'] == 'doorbell') {
        _handleDoorbellNotification(message.data);
      }
    });
  }

  void _handleDoorbellNotification(Map<String, dynamic> data) {
    final deviceId = data['deviceId'] as String?;
    if (deviceId != null) {
      // Show doorbell alert dialog
      _showDoorbellAlert(deviceId);
    }
  }

  void _showDoorbellAlert(String deviceId) {
    final doorphoneManager = context.read<DoorphoneManager>();
    final device = doorphoneManager.deviceList
        .where((d) => d.id == deviceId)
        .firstOrNull;
    
    if (device == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.doorbell,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Doorbell Ring'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Someone is at ${device.name}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToVideoViewer(device);
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('View'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await doorphoneManager.unlockDoor(deviceId);
                    _showSnackBar('Door unlocked');
                  },
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Unlock'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _navigateToVideoViewer(DoorphoneDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoViewerScreen(device: device),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doorphone Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          _DevicesTab(),
          _HistoryTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DoorphoneManager>(
      builder: (context, doorphoneManager, child) {
        final devices = doorphoneManager.deviceList;
        final activeDevice = doorphoneManager.activeDevice;

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh devices and events
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Device Section
                if (activeDevice != null) ...[
                  Text(
                    'Active Device',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  DeviceCard(
                    device: activeDevice,
                    isActive: true,
                    onTap: () => _navigateToVideoViewer(context, activeDevice),
                  ),
                  const SizedBox(height: 24),
                ],

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const QuickActionsPanel(),
                const SizedBox(height: 24),

                // Recent Events
                Text(
                  'Recent Events',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const RecentEventsList(),
                const SizedBox(height: 24),

                // All Devices
                if (devices.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Devices',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DeviceListScreen(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...devices.take(3).map((device) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DeviceCard(
                      device: device,
                      isActive: device.id == activeDevice?.id,
                      onTap: () => _navigateToVideoViewer(context, device),
                    ),
                  )),
                ] else ...[
                  // No Devices State
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.devices_other,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No devices found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Make sure your doorphone devices are connected to AWS IoT',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToVideoViewer(BuildContext context, DoorphoneDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoViewerScreen(device: device),
      ),
    );
  }
}

class _DevicesTab extends StatelessWidget {
  const _DevicesTab();

  @override
  Widget build(BuildContext context) {
    return const DeviceListScreen();
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return const EventHistoryScreen();
  }
}