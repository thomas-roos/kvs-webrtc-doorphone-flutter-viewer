// JSON serialization removed for demo simplicity
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

  // JSON serialization methods removed for demo simplicity
  factory DoorphoneDevice.fromJson(Map<String, dynamic> json) {
    return DoorphoneDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      kvsChannelName: json['kvsChannelName'] as String,
      mqttTopic: json['mqttTopic'] as String,
      awsRegion: json['awsRegion'] as String,
      status: DeviceStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      capabilities: List<String>.from(json['capabilities'] as List),
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'kvsChannelName': kvsChannelName,
      'mqttTopic': mqttTopic,
      'awsRegion': awsRegion,
      'status': status.toString().split('.').last,
      'capabilities': capabilities,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

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
  online,
  offline,
  connecting,
  error,
}
