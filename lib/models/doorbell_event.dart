import 'package:json_annotation/json_annotation.dart';

part 'doorbell_event.g.dart';

@JsonSerializable()
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

  factory DoorbellEvent.fromJson(Map<String, dynamic> json) =>
      _$DoorbellEventFromJson(json);

  Map<String, dynamic> toJson() => _$DoorbellEventToJson(this);

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
  @JsonValue('doorbell')
  doorbell,
  @JsonValue('motion')
  motion,
  @JsonValue('access')
  access,
  @JsonValue('call')
  call,
}