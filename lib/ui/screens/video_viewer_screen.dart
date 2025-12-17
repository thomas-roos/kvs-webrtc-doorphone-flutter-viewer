import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doorphone_device.dart';
import '../../services/doorphone_manager.dart';


class VideoViewerScreen extends StatefulWidget {
  final DoorphoneDevice device;

  const VideoViewerScreen({super.key, required this.device});

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    setState(() => _isConnecting = true);

    try {
      final doorphoneManager = context.read<DoorphoneManager>();
      await doorphoneManager.connectToDevice(widget.device.id);

      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });
    } catch (e) {
      setState(() => _isConnecting = false);
      _showErrorSnackBar('Failed to connect: $e');
    }
  }

  Future<void> _unlockDoor() async {
    try {
      final doorphoneManager = context.read<DoorphoneManager>();
      await doorphoneManager.unlockDoor(widget.device.id);
      _showSuccessSnackBar('Door unlocked');
    } catch (e) {
      _showErrorSnackBar('Failed to unlock door: $e');
    }
  }

  Future<void> _lockDoor() async {
    try {
      final doorphoneManager = context.read<DoorphoneManager>();
      await doorphoneManager.lockDoor(widget.device.id);
      _showSuccessSnackBar('Door locked');
    } catch (e) {
      _showErrorSnackBar('Failed to lock door: $e');
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    // TODO: Implement actual mute functionality
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Video Display Area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _buildVideoDisplay(),
            ),
          ),

          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: _buildControlPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDisplay() {
    if (_isConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Connecting to video stream...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'Video stream not available',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _connectToDevice,
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      );
    }

    // Placeholder for actual video stream
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.black87],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'Video Stream Active',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'WebRTC connection established',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Column(
      children: [
        // Primary Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: Icons.lock_open,
              label: 'Unlock',
              onPressed: _unlockDoor,
              color: Colors.green,
            ),
            _buildControlButton(
              icon: Icons.lock,
              label: 'Lock',
              onPressed: _lockDoor,
              color: Colors.red,
            ),
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              label: _isMuted ? 'Unmute' : 'Mute',
              onPressed: _toggleMute,
              color: _isMuted ? Colors.red : Colors.blue,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Device Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Connected to ${widget.device.name} (${widget.device.ipAddress})',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color),
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
