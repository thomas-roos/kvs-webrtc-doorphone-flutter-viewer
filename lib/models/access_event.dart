// JSON serialization removed for demo simplicity
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

  // JSON serialization methods removed for demo simplicity
  factory AccessEvent.fromJson(Map<String, dynamic> json) {
    return AccessEvent(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      userId: json['userId'] as String,
      action: AccessAction.values.firstWhere((e) => e.toString().split('.').last == json['action']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'userId': userId,
      'action': action.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'reason': reason,
    };
  }

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
  unlock,
  lock,
  deny,
}
