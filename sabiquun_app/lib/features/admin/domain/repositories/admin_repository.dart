import '../entities/user_management_entity.dart';
import '../entities/system_settings_entity.dart';
import '../entities/audit_log_entity.dart';
import '../entities/notification_template_entity.dart';
import '../entities/rest_day_entity.dart';
import '../entities/analytics_entity.dart';
import '../../../deeds/domain/entities/deed_template_entity.dart';

abstract class AdminRepository {
  // ==================== USER MANAGEMENT ====================

  /// Get all users with optional filters
  Future<List<UserManagementEntity>> getUsers({
    String? accountStatus, // 'pending', 'active', 'suspended', 'auto_deactivated'
    String? searchQuery,
    String? membershipStatus,
  });

  /// Get a single user by ID with statistics
  Future<UserManagementEntity> getUserById(String userId);

  /// Approve a pending user
  Future<void> approveUser({
    required String userId,
    required String approvedBy,
  });

  /// Reject a pending user
  Future<void> rejectUser({
    required String userId,
    required String rejectedBy,
    required String reason,
  });

  /// Update user information
  Future<void> updateUser({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? role,
    String? membershipStatus,
    String? accountStatus,
    required String updatedBy,
    required String reason,
  });

  /// Change user role
  Future<void> changeUserRole({
    required String userId,
    required String newRole,
    required String changedBy,
    required String reason,
  });

  /// Suspend user
  Future<void> suspendUser({
    required String userId,
    required String suspendedBy,
    required String reason,
  });

  /// Activate suspended user
  Future<void> activateUser({
    required String userId,
    required String activatedBy,
    required String reason,
  });

  /// Delete user
  Future<void> deleteUser({
    required String userId,
    required String deletedBy,
    required String reason,
  });

  // ==================== SYSTEM SETTINGS ====================

  /// Get all system settings
  Future<SystemSettingsEntity> getSystemSettings();

  /// Update system settings
  Future<void> updateSystemSettings({
    required SystemSettingsEntity settings,
    required String updatedBy,
  });

  /// Get a specific setting value
  Future<String?> getSettingValue(String settingKey);

  /// Update a specific setting
  Future<void> updateSetting({
    required String settingKey,
    required String settingValue,
    required String updatedBy,
  });

  // ==================== DEED TEMPLATE MANAGEMENT ====================

  /// Get all deed templates
  Future<List<DeedTemplateEntity>> getDeedTemplates({
    bool? isActive,
    String? category,
  });

  /// Create a new deed template
  Future<DeedTemplateEntity> createDeedTemplate({
    required String deedName,
    required String deedKey,
    required String category,
    required String valueType,
    required int sortOrder,
    required bool isActive,
    required String createdBy,
  });

  /// Update deed template
  Future<void> updateDeedTemplate({
    required String templateId,
    String? deedName,
    String? category,
    String? valueType,
    int? sortOrder,
    bool? isActive,
    required String updatedBy,
  });

  /// Deactivate deed template
  Future<void> deactivateDeedTemplate({
    required String templateId,
    required String deactivatedBy,
    required String reason,
  });

  /// Reorder deed templates
  Future<void> reorderDeedTemplates({
    required List<String> templateIds,
    required String updatedBy,
  });

  // ==================== AUDIT LOGS ====================

  /// Get audit logs with filters
  Future<List<AuditLogEntity>> getAuditLogs({
    String? action,
    String? performedBy,
    String? entityType,
    String? entityId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Export audit logs
  Future<String> exportAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv', // 'csv' or 'excel'
  });

  // ==================== NOTIFICATION TEMPLATES ====================

  /// Get all notification templates
  Future<List<NotificationTemplateEntity>> getNotificationTemplates({
    String? templateType,
    bool? isActive,
  });

  /// Get a single notification template
  Future<NotificationTemplateEntity> getNotificationTemplateById(String templateId);

  /// Update notification template
  Future<void> updateNotificationTemplate({
    required String templateId,
    String? emailSubject,
    String? emailBody,
    String? pushTitle,
    String? pushBody,
    bool? isActive,
    required String updatedBy,
  });

  // ==================== REST DAYS MANAGEMENT ====================

  /// Get all rest days
  Future<List<RestDayEntity>> getRestDays({
    int? year,
    bool? isRecurring,
  });

  /// Create a rest day
  Future<RestDayEntity> createRestDay({
    required DateTime date,
    DateTime? endDate,
    required String description,
    required bool isRecurring,
    required String createdBy,
  });

  /// Update rest day
  Future<void> updateRestDay({
    required String restDayId,
    DateTime? date,
    DateTime? endDate,
    String? description,
    bool? isRecurring,
    required String updatedBy,
  });

  /// Delete rest day
  Future<void> deleteRestDay({
    required String restDayId,
    required String deletedBy,
  });

  /// Bulk import rest days from CSV/Excel
  Future<int> bulkImportRestDays({
    required String fileContent,
    required String createdBy,
  });

  // ==================== ANALYTICS ====================

  /// Get comprehensive system analytics
  Future<AnalyticsEntity> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Export analytics report
  Future<String> exportAnalyticsReport({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'pdf', // 'pdf' or 'excel'
  });

  // ==================== EXCUSE MANAGEMENT ====================

  /// Get excuses with optional filters
  Future<List<dynamic>> getExcuses({
    String? status,
    String? userId,
    String? excuseType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get single excuse by ID
  Future<dynamic> getExcuseById(String excuseId);

  /// Approve excuse
  Future<void> approveExcuse({
    required String excuseId,
    required String approvedBy,
  });

  /// Reject excuse
  Future<void> rejectExcuse({
    required String excuseId,
    required String rejectedBy,
    required String reason,
  });

  /// Bulk approve excuses
  Future<int> bulkApproveExcuses({
    required List<String> excuseIds,
    required String approvedBy,
  });

  /// Bulk reject excuses
  Future<int> bulkRejectExcuses({
    required List<String> excuseIds,
    required String rejectedBy,
    required String reason,
  });
}
