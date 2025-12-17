// This is a basic test file for the doorphone viewer app.
// In a real application, you would write comprehensive tests for your widgets and logic.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doorphone_viewer/models/doorphone_device.dart';
import 'package:doorphone_viewer/models/doorbell_event.dart';

void main() {
  group('Data Models Tests', () {
    test('DoorphoneDevice creation', () {
      final device = DoorphoneDevice(
        id: 'test-device',
        name: 'Test Device',
        ipAddress: '192.168.1.100',
        kvsChannelName: 'test-channel',
        mqttTopic: 'doorphone/test-device',
        awsRegion: 'us-east-1',
        status: DeviceStatus.online,
        capabilities: ['video', 'audio'],
        lastSeen: DateTime.now(),
      );

      expect(device.id, equals('test-device'));
      expect(device.name, equals('Test Device'));
      expect(device.status, equals(DeviceStatus.online));
    });

    test('DoorbellEvent creation', () {
      final event = DoorbellEvent(
        id: 'test-event',
        deviceId: 'test-device',
        timestamp: DateTime.now(),
        type: EventType.doorbell,
      );

      expect(event.id, equals('test-event'));
      expect(event.deviceId, equals('test-device'));
      expect(event.type, equals(EventType.doorbell));
    });

    test('JSON serialization round trip for DoorphoneDevice', () {
      final originalDevice = DoorphoneDevice(
        id: 'test-device',
        name: 'Test Device',
        ipAddress: '192.168.1.100',
        kvsChannelName: 'test-channel',
        mqttTopic: 'doorphone/test-device',
        awsRegion: 'us-east-1',
        status: DeviceStatus.online,
        capabilities: ['video', 'audio'],
        lastSeen: DateTime.parse('2023-01-01T00:00:00Z'),
      );

      final json = originalDevice.toJson();
      final deserializedDevice = DoorphoneDevice.fromJson(json);

      expect(deserializedDevice.id, equals(originalDevice.id));
      expect(deserializedDevice.name, equals(originalDevice.name));
      expect(deserializedDevice.status, equals(originalDevice.status));
    });
  });

  test('Basic unit test example', () {
    // Simple unit test to ensure test framework is working
    expect(2 + 2, equals(4));
  });
}