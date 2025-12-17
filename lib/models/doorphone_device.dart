import 'package:json_annotation/json_annotation.dart';

part 'doorphone_device.g.dart';

@JsonSerializable()
class DoorphoneDevice {
  final String id;
  final String name;
  final String ipAddress;
  final String kvsChannelName;
  final String mqttTopic;
  final String awsRegion;
  final DeviceStatus status;
  final List<String> capabilities;
  final DateTime lastSeen;

  const DoorphoneDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.kvsChannelName,
    required this.mqttTopic,
    required this.awsRegion,
    required this.status,
    required this.capabilities,
    required this.lastSeen,
  });

  factory DoorphoneDevice.fromJson(Map<String, dynamic> json) =>
      _$DoorphoneDeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DoorphoneDeviceToJson(this);

  DoorphoneDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? kvsChannelName,
    String? mqttTopic,
    String? awsRegion,
    DeviceStatus? status,
    List<String>? capabilities,
    DateTime? lastSeen,
  }) {
    return DoorphoneDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      kvsChannelName: kvsChannelName ?? this.kvsChannelName,
      mqttTopic: mqttTopic ?? this.mqttTopic,
      awsRegion: awsRegion ?? this.awsRegion,
      status: status ?? this.status,
      capabilities: capabilities ?? this.capabilities,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoorphoneDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DoorphoneDevice{id: $id, name: $name, status: $status}';
  }
}

enum DeviceStatus {
  @JsonValue('online')
  online,
  @JsonValue('offline')
  offline,
  @JsonValue('connecting')
  connecting,
  @JsonValue('error')
  error,
}
