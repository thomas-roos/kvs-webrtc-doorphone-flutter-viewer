import 'package:json_annotation/json_annotation.dart';

part 'user_permission.g.dart';

@JsonSerializable()
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

  factory UserPermission.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionFromJson(json);

  Map<String, dynamic> toJson() => _$UserPermissionToJson(this);

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
  @JsonValue('view')
  view,
  @JsonValue('unlock')
  unlock,
  @JsonValue('manage')
  manage,
  @JsonValue('admin')
  admin,
}