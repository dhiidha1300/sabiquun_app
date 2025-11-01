import 'package:equatable/equatable.dart';
import '../../domain/entities/user_management_entity.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../../deeds/domain/entities/deed_template_entity.dart';

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

// ==================== ANALYTICS STATES ====================

/// Analytics loaded successfully
class AnalyticsLoaded extends AdminState {
  final AnalyticsEntity analytics;

  const AnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

// ==================== SYSTEM SETTINGS STATES ====================

/// System settings loaded successfully
class SystemSettingsLoaded extends AdminState {
  final SystemSettingsEntity settings;

  const SystemSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// System settings updated successfully
class SystemSettingsUpdated extends AdminState {
  const SystemSettingsUpdated();
}

// ==================== DEED TEMPLATE STATES ====================

/// Deed templates loaded successfully
class DeedTemplatesLoaded extends AdminState {
  final List<DeedTemplateEntity> templates;

  const DeedTemplatesLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

/// Deed template created successfully
class DeedTemplateCreated extends AdminState {
  final DeedTemplateEntity template;

  const DeedTemplateCreated(this.template);

  @override
  List<Object?> get props => [template];
}

/// Deed template updated successfully
class DeedTemplateUpdated extends AdminState {
  final String templateId;

  const DeedTemplateUpdated(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

/// Deed template deactivated successfully
class DeedTemplateDeactivated extends AdminState {
  final String templateId;

  const DeedTemplateDeactivated(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

/// Deed templates reordered successfully
class DeedTemplatesReordered extends AdminState {
  const DeedTemplatesReordered();
}
