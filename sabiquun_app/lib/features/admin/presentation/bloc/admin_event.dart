import 'package:equatable/equatable.dart';
import '../../domain/entities/system_settings_entity.dart';

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

// ==================== ANALYTICS EVENTS ====================

/// Load analytics data
class LoadAnalyticsRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAnalyticsRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

// ==================== SYSTEM SETTINGS EVENTS ====================

/// Load system settings
class LoadSystemSettingsRequested extends AdminEvent {
  const LoadSystemSettingsRequested();
}

/// Update system settings
class UpdateSystemSettingsRequested extends AdminEvent {
  final SystemSettingsEntity settings;
  final String updatedBy;

  const UpdateSystemSettingsRequested({
    required this.settings,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [settings, updatedBy];
}

// ==================== DEED TEMPLATE EVENTS ====================

/// Load all deed templates with optional filters
class LoadDeedTemplatesRequested extends AdminEvent {
  final bool? isActive;
  final String? category; // 'faraid' or 'sunnah'

  const LoadDeedTemplatesRequested({
    this.isActive,
    this.category,
  });

  @override
  List<Object?> get props => [isActive, category];
}

// ==================== AUDIT LOG EVENTS ====================

/// Load audit logs with optional filters
class LoadAuditLogsRequested extends AdminEvent {
  final String? action;
  final String? performedBy;
  final String? entityType;
  final String? entityId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const LoadAuditLogsRequested({
    this.action,
    this.performedBy,
    this.entityType,
    this.entityId,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object?> get props => [
        action,
        performedBy,
        entityType,
        entityId,
        startDate,
        endDate,
        limit,
      ];
}

/// Export audit logs to CSV
class ExportAuditLogsRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportAuditLogsRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Create a new deed template
class CreateDeedTemplateRequested extends AdminEvent {
  final String deedName;
  final String deedKey;
  final String category;
  final String valueType;
  final int sortOrder;
  final bool isActive;
  final String createdBy;

  const CreateDeedTemplateRequested({
    required this.deedName,
    required this.deedKey,
    required this.category,
    required this.valueType,
    required this.sortOrder,
    required this.isActive,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        deedName,
        deedKey,
        category,
        valueType,
        sortOrder,
        isActive,
        createdBy,
      ];
}

/// Update an existing deed template
class UpdateDeedTemplateRequested extends AdminEvent {
  final String templateId;
  final String? deedName;
  final String? category;
  final String? valueType;
  final int? sortOrder;
  final bool? isActive;
  final String updatedBy;

  const UpdateDeedTemplateRequested({
    required this.templateId,
    this.deedName,
    this.category,
    this.valueType,
    this.sortOrder,
    this.isActive,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [
        templateId,
        deedName,
        category,
        valueType,
        sortOrder,
        isActive,
        updatedBy,
      ];
}

/// Deactivate a deed template
class DeactivateDeedTemplateRequested extends AdminEvent {
  final String templateId;
  final String deactivatedBy;
  final String reason;

  const DeactivateDeedTemplateRequested({
    required this.templateId,
    required this.deactivatedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [templateId, deactivatedBy, reason];
}

/// Reorder deed templates
class ReorderDeedTemplatesRequested extends AdminEvent {
  final List<String> templateIds;
  final String updatedBy;

  const ReorderDeedTemplatesRequested({
    required this.templateIds,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [templateIds, updatedBy];
}

// ============================================================================
// Excuse Management Events
// ============================================================================

/// Load excuses with optional filters
class LoadExcusesRequested extends AdminEvent {
  final String? status; // 'pending', 'approved', 'rejected'
  final String? userId;
  final String? excuseType; // 'sickness', 'travel', 'raining'
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadExcusesRequested({
    this.status,
    this.userId,
    this.excuseType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, userId, excuseType, startDate, endDate];
}

/// Load single excuse by ID
class LoadExcuseByIdRequested extends AdminEvent {
  final String excuseId;

  const LoadExcuseByIdRequested(this.excuseId);

  @override
  List<Object?> get props => [excuseId];
}

/// Approve excuse
class ApproveExcuseRequested extends AdminEvent {
  final String excuseId;
  final String approvedBy;

  const ApproveExcuseRequested({
    required this.excuseId,
    required this.approvedBy,
  });

  @override
  List<Object?> get props => [excuseId, approvedBy];
}

/// Reject excuse
class RejectExcuseRequested extends AdminEvent {
  final String excuseId;
  final String rejectedBy;
  final String reason;

  const RejectExcuseRequested({
    required this.excuseId,
    required this.rejectedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [excuseId, rejectedBy, reason];
}

/// Bulk approve excuses
class BulkApproveExcusesRequested extends AdminEvent {
  final List<String> excuseIds;
  final String approvedBy;

  const BulkApproveExcusesRequested({
    required this.excuseIds,
    required this.approvedBy,
  });

  @override
  List<Object?> get props => [excuseIds, approvedBy];
}

/// Bulk reject excuses
class BulkRejectExcusesRequested extends AdminEvent {
  final List<String> excuseIds;
  final String rejectedBy;
  final String reason;

  const BulkRejectExcusesRequested({
    required this.excuseIds,
    required this.rejectedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [excuseIds, rejectedBy, reason];
}

// ==================== NOTIFICATION TEMPLATE EVENTS ====================

/// Load notification templates
class LoadNotificationTemplatesRequested extends AdminEvent {
  final String? templateType;
  final bool? isActive;

  const LoadNotificationTemplatesRequested({
    this.templateType,
    this.isActive,
  });

  @override
  List<Object?> get props => [templateType, isActive];
}

/// Load notification template by ID
class LoadNotificationTemplateByIdRequested extends AdminEvent {
  final String templateId;

  const LoadNotificationTemplateByIdRequested({
    required this.templateId,
  });

  @override
  List<Object?> get props => [templateId];
}

/// Create notification template
class CreateNotificationTemplateRequested extends AdminEvent {
  final String templateKey;
  final String title;
  final String body;
  final String? emailSubject;
  final String? emailBody;
  final String notificationType;

  const CreateNotificationTemplateRequested({
    required this.templateKey,
    required this.title,
    required this.body,
    this.emailSubject,
    this.emailBody,
    required this.notificationType,
  });

  @override
  List<Object?> get props => [templateKey, title, body, emailSubject, emailBody, notificationType];
}

/// Update notification template
class UpdateNotificationTemplateRequested extends AdminEvent {
  final String templateId;
  final String? title;
  final String? body;
  final String? emailSubject;
  final String? emailBody;
  final bool? isEnabled;

  const UpdateNotificationTemplateRequested({
    required this.templateId,
    this.title,
    this.body,
    this.emailSubject,
    this.emailBody,
    this.isEnabled,
  });

  @override
  List<Object?> get props => [templateId, title, body, emailSubject, emailBody, isEnabled];
}

/// Delete notification template
class DeleteNotificationTemplateRequested extends AdminEvent {
  final String templateId;

  const DeleteNotificationTemplateRequested({
    required this.templateId,
  });

  @override
  List<Object?> get props => [templateId];
}

/// Toggle notification template status
class ToggleNotificationTemplateRequested extends AdminEvent {
  final String templateId;
  final bool isEnabled;

  const ToggleNotificationTemplateRequested({
    required this.templateId,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [templateId, isEnabled];
}

// ==================== NOTIFICATION SCHEDULE EVENTS ====================

/// Load notification schedules
class LoadNotificationSchedulesRequested extends AdminEvent {
  const LoadNotificationSchedulesRequested();

  @override
  List<Object?> get props => [];
}

/// Load notification schedule by ID
class LoadNotificationScheduleByIdRequested extends AdminEvent {
  final String scheduleId;

  const LoadNotificationScheduleByIdRequested({
    required this.scheduleId,
  });

  @override
  List<Object?> get props => [scheduleId];
}

/// Create notification schedule
class CreateNotificationScheduleRequested extends AdminEvent {
  final String notificationTemplateId;
  final String scheduledTime;
  final String frequency;
  final List<int>? daysOfWeek;
  final Map<String, dynamic>? conditions;
  final String createdBy;

  const CreateNotificationScheduleRequested({
    required this.notificationTemplateId,
    required this.scheduledTime,
    required this.frequency,
    this.daysOfWeek,
    this.conditions,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [notificationTemplateId, scheduledTime, frequency, daysOfWeek, conditions, createdBy];
}

/// Update notification schedule
class UpdateNotificationScheduleRequested extends AdminEvent {
  final String scheduleId;
  final String? notificationTemplateId;
  final String? scheduledTime;
  final String? frequency;
  final List<int>? daysOfWeek;
  final Map<String, dynamic>? conditions;
  final bool? isActive;

  const UpdateNotificationScheduleRequested({
    required this.scheduleId,
    this.notificationTemplateId,
    this.scheduledTime,
    this.frequency,
    this.daysOfWeek,
    this.conditions,
    this.isActive,
  });

  @override
  List<Object?> get props => [scheduleId, notificationTemplateId, scheduledTime, frequency, daysOfWeek, conditions, isActive];
}

/// Delete notification schedule
class DeleteNotificationScheduleRequested extends AdminEvent {
  final String scheduleId;

  const DeleteNotificationScheduleRequested({
    required this.scheduleId,
  });

  @override
  List<Object?> get props => [scheduleId];
}

/// Toggle notification schedule status
class ToggleNotificationScheduleRequested extends AdminEvent {
  final String scheduleId;
  final bool isActive;

  const ToggleNotificationScheduleRequested({
    required this.scheduleId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [scheduleId, isActive];
}

/// Send manual notification
class SendManualNotificationRequested extends AdminEvent {
  final List<String> userIds;
  final String title;
  final String body;
  final String? notificationType;

  const SendManualNotificationRequested({
    required this.userIds,
    required this.title,
    required this.body,
    this.notificationType,
  });

  @override
  List<Object?> get props => [userIds, title, body, notificationType];
}

// ==================== REPORT MANAGEMENT EVENTS ====================

/// Search reports by user and date range
class SearchReportsRequested extends AdminEvent {
  final String? userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  const SearchReportsRequested({
    this.userId,
    this.startDate,
    this.endDate,
    this.status,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate, status];
}

/// Get a single report by ID
class GetReportByIdRequested extends AdminEvent {
  final String reportId;

  const GetReportByIdRequested({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// Update report (admin override)
class UpdateReportRequested extends AdminEvent {
  final String reportId;
  final Map<String, double> deedValues;
  final String reason;

  const UpdateReportRequested({
    required this.reportId,
    required this.deedValues,
    required this.reason,
  });

  @override
  List<Object?> get props => [reportId, deedValues, reason];
}
