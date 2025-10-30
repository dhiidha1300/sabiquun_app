import 'package:equatable/equatable.dart';
import '../../domain/entities/user_management_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminInitial extends AdminState {
  const AdminInitial();
}

/// Loading state
class AdminLoading extends AdminState {
  const AdminLoading();
}

/// Users loaded successfully
class UsersLoaded extends AdminState {
  final List<UserManagementEntity> users;
  final String? appliedFilter; // To show which filter is active

  const UsersLoaded({
    required this.users,
    this.appliedFilter,
  });

  @override
  List<Object?> get props => [users, appliedFilter];
}

/// Single user loaded
class UserDetailLoaded extends AdminState {
  final UserManagementEntity user;

  const UserDetailLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// User approved successfully
class UserApproved extends AdminState {
  final String userId;

  const UserApproved(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// User rejected successfully
class UserRejected extends AdminState {
  final String userId;

  const UserRejected(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// User updated successfully
class UserUpdated extends AdminState {
  final String userId;
  final String message;

  const UserUpdated({
    required this.userId,
    this.message = 'User updated successfully',
  });

  @override
  List<Object?> get props => [userId, message];
}

/// User role changed successfully
class UserRoleChanged extends AdminState {
  final String userId;
  final String newRole;

  const UserRoleChanged({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [userId, newRole];
}

/// User suspended successfully
class UserSuspended extends AdminState {
  final String userId;

  const UserSuspended(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// User activated successfully
class UserActivated extends AdminState {
  final String userId;

  const UserActivated(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// User deleted successfully
class UserDeleted extends AdminState {
  final String userId;

  const UserDeleted(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Error state
class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
