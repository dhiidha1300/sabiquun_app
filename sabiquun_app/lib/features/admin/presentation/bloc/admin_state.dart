import 'package:equatable/equatable.dart';
import '../../domain/entities/user_management_entity.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../domain/entities/audit_log_entity.dart';
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

// ==================== AUDIT LOG STATES ====================

/// Audit logs loaded successfully
class AuditLogsLoaded extends AdminState {
  final List<AuditLogEntity> logs;

  const AuditLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

/// Audit logs exported successfully
class AuditLogsExported extends AdminState {
  final String csvContent;
  final int logCount;

  const AuditLogsExported({
    required this.csvContent,
    required this.logCount,
  });

  @override
  List<Object?> get props => [csvContent, logCount];
}

// ============================================================================
// Excuse Management States
// ============================================================================

/// Excuses loaded successfully
class ExcusesLoaded extends AdminState {
  final List<dynamic> excuses; // List<ExcuseEntity>
  final String? appliedFilter;

  const ExcusesLoaded({
    required this.excuses,
    this.appliedFilter,
  });

  @override
  List<Object?> get props => [excuses, appliedFilter];
}

/// Single excuse detail loaded
class ExcuseDetailLoaded extends AdminState {
  final dynamic excuse; // ExcuseEntity

  const ExcuseDetailLoaded(this.excuse);

  @override
  List<Object?> get props => [excuse];
}

/// Excuse approved successfully
class ExcuseApproved extends AdminState {
  final String excuseId;

  const ExcuseApproved(this.excuseId);

  @override
  List<Object?> get props => [excuseId];
}

/// Excuse rejected successfully
class ExcuseRejected extends AdminState {
  final String excuseId;

  const ExcuseRejected(this.excuseId);

  @override
  List<Object?> get props => [excuseId];
}

/// Bulk excuses approved successfully
class BulkExcusesApproved extends AdminState {
  final int count;

  const BulkExcusesApproved(this.count);

  @override
  List<Object?> get props => [count];
}

/// Bulk excuses rejected successfully
class BulkExcusesRejected extends AdminState {
  final int count;

  const BulkExcusesRejected(this.count);

  @override
  List<Object?> get props => [count];
}

// ==================== NOTIFICATION TEMPLATE STATES ====================

/// Notification templates loaded successfully
class NotificationTemplatesLoaded extends AdminState {
  final List<dynamic> templates;

  const NotificationTemplatesLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

/// Notification template loaded successfully
class NotificationTemplateLoaded extends AdminState {
  final dynamic template;

  const NotificationTemplateLoaded(this.template);

  @override
  List<Object?> get props => [template];
}

/// Notification template created successfully
class NotificationTemplateCreated extends AdminState {
  final dynamic template;

  const NotificationTemplateCreated(this.template);

  @override
  List<Object?> get props => [template];
}

/// Notification template updated successfully
class NotificationTemplateUpdated extends AdminState {
  final dynamic template;

  const NotificationTemplateUpdated(this.template);

  @override
  List<Object?> get props => [template];
}

/// Notification template deleted successfully
class NotificationTemplateDeleted extends AdminState {
  final String templateId;

  const NotificationTemplateDeleted(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

/// Notification template toggled successfully
class NotificationTemplateToggled extends AdminState {
  final dynamic template;

  const NotificationTemplateToggled(this.template);

  @override
  List<Object?> get props => [template];
}

// ==================== NOTIFICATION SCHEDULE STATES ====================

/// Notification schedules loaded successfully
class NotificationSchedulesLoaded extends AdminState {
  final List<dynamic> schedules;

  const NotificationSchedulesLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

/// Notification schedule loaded successfully
class NotificationScheduleLoaded extends AdminState {
  final dynamic schedule;

  const NotificationScheduleLoaded(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

/// Notification schedule created successfully
class NotificationScheduleCreated extends AdminState {
  final dynamic schedule;

  const NotificationScheduleCreated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

/// Notification schedule updated successfully
class NotificationScheduleUpdated extends AdminState {
  final dynamic schedule;

  const NotificationScheduleUpdated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

/// Notification schedule deleted successfully
class NotificationScheduleDeleted extends AdminState {
  final String scheduleId;

  const NotificationScheduleDeleted(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

/// Notification schedule toggled successfully
class NotificationScheduleToggled extends AdminState {
  final dynamic schedule;

  const NotificationScheduleToggled(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

/// Manual notification sent successfully
class ManualNotificationSent extends AdminState {
  final int userCount;

  const ManualNotificationSent(this.userCount);

  @override
  List<Object?> get props => [userCount];
}

// ==================== REPORT MANAGEMENT STATES ====================

/// Reports search in progress
class ReportsSearchInProgress extends AdminState {
  const ReportsSearchInProgress();
}

/// Reports search successful
class ReportsSearchSuccess extends AdminState {
  final List<dynamic> reports;

  const ReportsSearchSuccess(this.reports);

  @override
  List<Object?> get props => [reports];
}

/// Single report loaded successfully
class ReportLoadedSuccess extends AdminState {
  final dynamic report;

  const ReportLoadedSuccess(this.report);

  @override
  List<Object?> get props => [report];
}

/// Report updated successfully
class ReportUpdatedSuccess extends AdminState {
  final dynamic report;

  const ReportUpdatedSuccess(this.report);

  @override
  List<Object?> get props => [report];
}
