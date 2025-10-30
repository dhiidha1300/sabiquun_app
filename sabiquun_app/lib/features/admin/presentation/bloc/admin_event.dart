import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// ==================== USER MANAGEMENT EVENTS ====================

/// Load users with optional filters
class LoadUsersRequested extends AdminEvent {
  final String? accountStatus; // 'pending', 'active', 'suspended', 'auto_deactivated'
  final String? searchQuery;
  final String? membershipStatus;

  const LoadUsersRequested({
    this.accountStatus,
    this.searchQuery,
    this.membershipStatus,
  });

  @override
  List<Object?> get props => [accountStatus, searchQuery, membershipStatus];
}

/// Load a single user by ID
class LoadUserByIdRequested extends AdminEvent {
  final String userId;

  const LoadUserByIdRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Approve a pending user
class ApproveUserRequested extends AdminEvent {
  final String userId;
  final String approvedBy;

  const ApproveUserRequested({
    required this.userId,
    required this.approvedBy,
  });

  @override
  List<Object?> get props => [userId, approvedBy];
}

/// Reject a pending user
class RejectUserRequested extends AdminEvent {
  final String userId;
  final String rejectedBy;
  final String reason;

  const RejectUserRequested({
    required this.userId,
    required this.rejectedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, rejectedBy, reason];
}

/// Update user information
class UpdateUserRequested extends AdminEvent {
  final String userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String? role;
  final String? membershipStatus;
  final String? accountStatus;
  final String updatedBy;
  final String reason;

  const UpdateUserRequested({
    required this.userId,
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.role,
    this.membershipStatus,
    this.accountStatus,
    required this.updatedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        photoUrl,
        role,
        membershipStatus,
        accountStatus,
        updatedBy,
        reason,
      ];
}

/// Change user role
class ChangeUserRoleRequested extends AdminEvent {
  final String userId;
  final String newRole;
  final String changedBy;
  final String reason;

  const ChangeUserRoleRequested({
    required this.userId,
    required this.newRole,
    required this.changedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, newRole, changedBy, reason];
}

/// Suspend user
class SuspendUserRequested extends AdminEvent {
  final String userId;
  final String suspendedBy;
  final String reason;

  const SuspendUserRequested({
    required this.userId,
    required this.suspendedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, suspendedBy, reason];
}

/// Activate suspended user
class ActivateUserRequested extends AdminEvent {
  final String userId;
  final String activatedBy;
  final String reason;

  const ActivateUserRequested({
    required this.userId,
    required this.activatedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, activatedBy, reason];
}

/// Delete user
class DeleteUserRequested extends AdminEvent {
  final String userId;
  final String deletedBy;
  final String reason;

  const DeleteUserRequested({
    required this.userId,
    required this.deletedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, deletedBy, reason];
}
