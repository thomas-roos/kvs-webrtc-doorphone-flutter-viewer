// JSON serialization removed for demo simplicity
class DoorbellEvent {
  final String id;
  final String deviceId;
  final DateTime timestamp;
  final EventType type;
  final String? visitorImage;
  final Duration? callDuration;
  final Map<String, dynamic>? metadata;

  const DoorbellEvent({
    required this.id,
    required this.deviceId,
    required this.timestamp,
    required this.type,
    this.visitorImage,
    this.callDuration,
    this.metadata,
  });

  // JSON serialization methods removed for demo simplicity
  factory DoorbellEvent.fromJson(Map<String, dynamic> json) {
    return DoorbellEvent(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: EventType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      visitorImage: json['visitorImage'] as String?,
      callDuration: json['callDuration'] != null ? Duration(seconds: json['callDuration'] as int) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'visitorImage': visitorImage,
      'callDuration': callDuration?.inSeconds,
      'metadata': metadata,
    };
  }

  DoorbellEvent copyWith({
    String? id,
    String? deviceId,
    DateTime? timestamp,
    EventType? type,
    String? visitorImage,
    Duration? callDuration,
    Map<String, dynamic>? metadata,
  }) {
    return DoorbellEvent(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      visitorImage: visitorImage ?? this.visitorImage,
      callDuration: callDuration ?? this.callDuration,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoorbellEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DoorbellEvent{id: $id, deviceId: $deviceId, type: $type, timestamp: $timestamp}';
  }
}

enum EventType {
  doorbell,
  motion,
  access,
  call,
}
