import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/doorphone_manager.dart';
import '../widgets/device_card.dart';
import 'video_viewer_screen.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh devices
            },
          ),
        ],
      ),
      body: Consumer<DoorphoneManager>(
        builder: (context, doorphoneManager, child) {
          final devices = doorphoneManager.deviceList;

          if (devices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_other,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No devices found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DeviceCard(
                  device: device,
                  isActive: device.id == doorphoneManager.activeDevice?.id,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VideoViewerScreen(device: device),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}