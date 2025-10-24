import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/core/constants/user_role.dart';
import 'package:sabiquun_app/core/constants/account_status.dart';

/// User entity representing a user in the domain layer
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final UserRole role;
  final AccountStatus accountStatus;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profilePhotoUrl,
    required this.role,
    required this.accountStatus,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Check if user can access the application
  bool get canAccessApp => accountStatus.canAccessApp;

  /// Check if user has elevated privileges
  bool get hasElevatedPrivileges => role.isElevated;

  /// Check if user is admin
  bool get isAdmin => role.isAdmin;

  /// Check if user is supervisor
  bool get isSupervisor => role.isSupervisor;

  /// Check if user is cashier
  bool get isCashier => role.isCashier;

  /// Check if user is normal user
  bool get isNormalUser => role.isNormalUser;

  /// Get initials from full name
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        profilePhotoUrl,
        role,
        accountStatus,
        createdAt,
        lastLoginAt,
      ];
}
