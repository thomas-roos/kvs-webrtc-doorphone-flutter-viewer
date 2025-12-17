import 'package:json_annotation/json_annotation.dart';

part 'access_event.g.dart';

@JsonSerializable()
class AccessEvent {
  final String id;
  final String deviceId;
  final String userId;
  final AccessAction action;
  final DateTime timestamp;
  final bool success;
  final String? reason;

  const AccessEvent({
    required this.id,
    required this.deviceId,
    required this.userId,
    required this.action,
    required this.timestamp,
    required this.success,
    this.reason,
  });

  factory AccessEvent.fromJson(Map<String, dynamic> json) =>
      _$AccessEventFromJson(json);

  Map<String, dynamic> toJson() => _$AccessEventToJson(this);

  AccessEvent copyWith({
    String? id,
    String? deviceId,
    String? userId,
    AccessAction? action,
    DateTime? timestamp,
    bool? success,
    String? reason,
  }) {
    return AccessEvent(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      success: success ?? this.success,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AccessEvent{id: $id, deviceId: $deviceId, action: $action, success: $success}';
  }
}

enum AccessAction {
  @JsonValue('unlock')
  unlock,
  @JsonValue('lock')
  lock,
  @JsonValue('deny')
  deny,
}
