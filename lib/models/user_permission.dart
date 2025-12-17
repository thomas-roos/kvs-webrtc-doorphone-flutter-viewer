// JSON serialization removed for demo simplicity
class UserPermission {
  final String userId;
  final String deviceId;
  final List<Permission> permissions;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final String createdBy;

  const UserPermission({
    required this.userId,
    required this.deviceId,
    required this.permissions,
    this.expiresAt,
    required this.createdAt,
    required this.createdBy,
  });

  // JSON serialization methods removed for demo simplicity
  factory UserPermission.fromJson(Map<String, dynamic> json) {
    return UserPermission(
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      permissions: (json['permissions'] as List).map((e) => Permission.values.firstWhere((p) => p.toString().split('.').last == e)).toList(),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'permissions': permissions.map((e) => e.toString().split('.').last).toList(),
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  bool hasPermission(Permission permission) {
    return permissions.contains(permission);
  }

  bool isExpired() {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  UserPermission copyWith({
    String? userId,
    String? deviceId,
    List<Permission>? permissions,
    DateTime? expiresAt,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return UserPermission(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      permissions: permissions ?? this.permissions,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPermission &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          deviceId == other.deviceId;

  @override
  int get hashCode => userId.hashCode ^ deviceId.hashCode;

  @override
  String toString() {
    return 'UserPermission{userId: $userId, deviceId: $deviceId, permissions: $permissions}';
  }
}

enum Permission {
  view,
  unlock,
  manage,
  admin,
}
