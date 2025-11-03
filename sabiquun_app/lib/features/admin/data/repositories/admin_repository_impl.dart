import '../../domain/entities/user_management_entity.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/entities/notification_template_entity.dart';
import '../../domain/entities/notification_schedule_entity.dart';
import '../../domain/entities/rest_day_entity.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../deeds/domain/entities/deed_template_entity.dart';
import '../../../deeds/domain/entities/deed_report_entity.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/system_settings_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  // ==================== USER MANAGEMENT ====================

  @override
  Future<List<UserManagementEntity>> getUsers({
    String? accountStatus,
    String? searchQuery,
    String? membershipStatus,
  }) async {
    try {
      final models = await _remoteDataSource.getUsers(
        accountStatus: accountStatus,
        searchQuery: searchQuery,
        membershipStatus: membershipStatus,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get users - $e');
    }
  }

  @override
  Future<UserManagementEntity> getUserById(String userId) async {
    try {
      final model = await _remoteDataSource.getUserById(userId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Repository: Failed to get user - $e');
    }
  }

  @override
  Future<void> approveUser({
    required String userId,
    required String approvedBy,
  }) async {
    try {
      await _remoteDataSource.approveUser(
        userId: userId,
        approvedBy: approvedBy,
      );
    } catch (e) {
      throw Exception('Repository: Failed to approve user - $e');
    }
  }

  @override
  Future<void> rejectUser({
    required String userId,
    required String rejectedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.rejectUser(
        userId: userId,
        rejectedBy: rejectedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to reject user - $e');
    }
  }

  @override
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
  }) async {
    try {
      await _remoteDataSource.updateUser(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
        role: role,
        membershipStatus: membershipStatus,
        accountStatus: accountStatus,
        updatedBy: updatedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to update user - $e');
    }
  }

  @override
  Future<void> changeUserRole({
    required String userId,
    required String newRole,
    required String changedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.changeUserRole(
        userId: userId,
        newRole: newRole,
        changedBy: changedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to change user role - $e');
    }
  }

  @override
  Future<void> suspendUser({
    required String userId,
    required String suspendedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.suspendUser(
        userId: userId,
        suspendedBy: suspendedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to suspend user - $e');
    }
  }

  @override
  Future<void> activateUser({
    required String userId,
    required String activatedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.activateUser(
        userId: userId,
        activatedBy: activatedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to activate user - $e');
    }
  }

  @override
  Future<void> deleteUser({
    required String userId,
    required String deletedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.deleteUser(
        userId: userId,
        deletedBy: deletedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to delete user - $e');
    }
  }

  // ==================== SYSTEM SETTINGS ====================

  @override
  Future<SystemSettingsEntity> getSystemSettings() async {
    try {
      final model = await _remoteDataSource.getSystemSettings();
      return model.toEntity();
    } catch (e) {
      throw Exception('Repository: Failed to get system settings - $e');
    }
  }

  @override
  Future<void> updateSystemSettings({
    required SystemSettingsEntity settings,
    required String updatedBy,
  }) async {
    try {
      // Convert entity to model
      final model = _entityToModel(settings);
      await _remoteDataSource.updateSystemSettings(
        settings: model,
        updatedBy: updatedBy,
      );
    } catch (e) {
      throw Exception('Repository: Failed to update system settings - $e');
    }
  }

  @override
  Future<String?> getSettingValue(String settingKey) async {
    try {
      return await _remoteDataSource.getSettingValue(settingKey);
    } catch (e) {
      throw Exception('Repository: Failed to get setting value - $e');
    }
  }

  @override
  Future<void> updateSetting({
    required String settingKey,
    required String settingValue,
    required String updatedBy,
  }) async {
    try {
      await _remoteDataSource.updateSetting(
        key: settingKey,
        value: settingValue,
        updatedBy: updatedBy,
      );
    } catch (e) {
      throw Exception('Repository: Failed to update setting - $e');
    }
  }

  // Helper to convert entity to model
  SystemSettingsModel _entityToModel(SystemSettingsEntity entity) {
    return SystemSettingsModel(
      dailyDeedTarget: entity.dailyDeedTarget,
      penaltyPerDeed: entity.penaltyPerDeed,
      gracePeriodHours: entity.gracePeriodHours,
      trainingPeriodDays: entity.trainingPeriodDays,
      autoDeactivationThreshold: entity.autoDeactivationThreshold,
      warningThresholds: entity.warningThresholds,
      organizationName: entity.organizationName,
      receiptFooterText: entity.receiptFooterText,
      emailApiKey: entity.emailApiKey,
      emailDomain: entity.emailDomain,
      emailSenderEmail: entity.emailSenderEmail,
      emailSenderName: entity.emailSenderName,
      fcmServerKey: entity.fcmServerKey,
      appVersion: entity.appVersion,
      minimumRequiredVersion: entity.minimumRequiredVersion,
      forceUpdate: entity.forceUpdate,
      updateTitle: entity.updateTitle,
      updateMessage: entity.updateMessage,
      iosMinVersion: entity.iosMinVersion,
      androidMinVersion: entity.androidMinVersion,
    );
  }

  // ==================== DEED TEMPLATES ====================

  @override
  Future<List<DeedTemplateEntity>> getDeedTemplates({
    bool? isActive,
    String? category,
  }) async {
    try {
      final models = await _remoteDataSource.getDeedTemplates(
        isActive: isActive,
        category: category,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get deed templates - $e');
    }
  }

  @override
  Future<DeedTemplateEntity> createDeedTemplate({
    required String deedName,
    required String deedKey,
    required String category,
    required String valueType,
    required int sortOrder,
    required bool isActive,
    required String createdBy,
  }) async {
    try {
      final model = await _remoteDataSource.createDeedTemplate(
        deedName: deedName,
        deedKey: deedKey,
        category: category,
        valueType: valueType,
        sortOrder: sortOrder,
        isActive: isActive,
        createdBy: createdBy,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Repository: Failed to create deed template - $e');
    }
  }

  @override
  Future<void> updateDeedTemplate({
    required String templateId,
    String? deedName,
    String? category,
    String? valueType,
    int? sortOrder,
    bool? isActive,
    required String updatedBy,
  }) async {
    try {
      await _remoteDataSource.updateDeedTemplate(
        templateId: templateId,
        deedName: deedName,
        category: category,
        valueType: valueType,
        sortOrder: sortOrder,
        isActive: isActive,
        updatedBy: updatedBy,
      );
    } catch (e) {
      throw Exception('Repository: Failed to update deed template - $e');
    }
  }

  @override
  Future<void> deactivateDeedTemplate({
    required String templateId,
    required String deactivatedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.deactivateDeedTemplate(
        templateId: templateId,
        deactivatedBy: deactivatedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to deactivate deed template - $e');
    }
  }

  @override
  Future<void> reorderDeedTemplates({
    required List<String> templateIds,
    required String updatedBy,
  }) async {
    try {
      await _remoteDataSource.reorderDeedTemplates(
        templateIds: templateIds,
        updatedBy: updatedBy,
      );
    } catch (e) {
      throw Exception('Repository: Failed to reorder deed templates - $e');
    }
  }

  // ==================== AUDIT LOGS ====================

  @override
  Future<List<AuditLogEntity>> getAuditLogs({
    String? action,
    String? performedBy,
    String? entityType,
    String? entityId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final models = await _remoteDataSource.getAuditLogs(
        action: action,
        performedBy: performedBy,
        entityType: entityType,
        entityId: entityId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get audit logs - $e');
    }
  }

  @override
  Future<String> exportAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    try {
      // Currently only CSV format is supported
      return await _remoteDataSource.exportAuditLogs(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Repository: Failed to export audit logs - $e');
    }
  }

  // ==================== REST DAYS (Stub) ====================

  @override
  Future<List<RestDayEntity>> getRestDays({
    int? year,
    bool? isRecurring,
  }) {
    throw UnimplementedError('Rest days not yet implemented');
  }

  @override
  Future<RestDayEntity> createRestDay({
    required DateTime date,
    DateTime? endDate,
    required String description,
    required bool isRecurring,
    required String createdBy,
  }) {
    throw UnimplementedError('Rest days not yet implemented');
  }

  @override
  Future<void> updateRestDay({
    required String restDayId,
    DateTime? date,
    DateTime? endDate,
    String? description,
    bool? isRecurring,
    required String updatedBy,
  }) {
    throw UnimplementedError('Rest days not yet implemented');
  }

  @override
  Future<void> deleteRestDay({
    required String restDayId,
    required String deletedBy,
  }) {
    throw UnimplementedError('Rest days not yet implemented');
  }

  @override
  Future<int> bulkImportRestDays({
    required String fileContent,
    required String createdBy,
  }) {
    throw UnimplementedError('Rest days bulk import not yet implemented');
  }

  // ==================== ANALYTICS ====================

  @override
  Future<AnalyticsEntity> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final model = await _remoteDataSource.getAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Repository: Failed to get analytics - $e');
    }
  }

  @override
  Future<String> exportAnalyticsReport({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'pdf',
  }) {
    // TODO: Implement analytics export when needed
    throw UnimplementedError('Analytics export not yet implemented');
  }

  // ==================== EXCUSE MANAGEMENT ====================

  @override
  Future<List<dynamic>> getExcuses({
    String? status,
    String? userId,
    String? excuseType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final excusesData = await _remoteDataSource.getExcuses(
        status: status,
        userId: userId,
        excuseType: excuseType,
        startDate: startDate,
        endDate: endDate,
      );
      // Convert to entities (using dynamic to avoid import issues before build_runner)
      return excusesData;
    } catch (e) {
      throw Exception('Repository: Failed to get excuses - $e');
    }
  }

  @override
  Future<dynamic> getExcuseById(String excuseId) async {
    try {
      final excuseData = await _remoteDataSource.getExcuseById(excuseId);
      return excuseData;
    } catch (e) {
      throw Exception('Repository: Failed to get excuse - $e');
    }
  }

  @override
  Future<void> approveExcuse({
    required String excuseId,
    required String approvedBy,
  }) async {
    try {
      await _remoteDataSource.approveExcuse(
        excuseId: excuseId,
        approvedBy: approvedBy,
      );
    } catch (e) {
      throw Exception('Repository: Failed to approve excuse - $e');
    }
  }

  @override
  Future<void> rejectExcuse({
    required String excuseId,
    required String rejectedBy,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.rejectExcuse(
        excuseId: excuseId,
        rejectedBy: rejectedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to reject excuse - $e');
    }
  }

  @override
  Future<int> bulkApproveExcuses({
    required List<String> excuseIds,
    required String approvedBy,
  }) async {
    try {
      return await _remoteDataSource.bulkApproveExcuses(
        excuseIds: excuseIds,
        approvedBy: approvedBy,
      );
    } catch (e) {
      throw Exception('Repository: Failed to bulk approve excuses - $e');
    }
  }

  @override
  Future<int> bulkRejectExcuses({
    required List<String> excuseIds,
    required String rejectedBy,
    required String reason,
  }) async {
    try {
      return await _remoteDataSource.bulkRejectExcuses(
        excuseIds: excuseIds,
        rejectedBy: rejectedBy,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Repository: Failed to bulk reject excuses - $e');
    }
  }

  // ==================== NOTIFICATION TEMPLATES ====================

  @override
  Future<List<NotificationTemplateEntity>> getNotificationTemplates({
    String? templateType,
    bool? isActive,
  }) async {
    try {
      final models = await _remoteDataSource.getNotificationTemplates();

      // Filter by template type and active status if provided
      var filtered = models;
      if (templateType != null) {
        filtered = filtered.where((m) => m.notificationType == templateType).toList();
      }
      if (isActive != null) {
        filtered = filtered.where((m) => m.isEnabled == isActive).toList();
      }

      return filtered.map(_mapNotificationTemplateToEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get notification templates - $e');
    }
  }

  @override
  Future<NotificationTemplateEntity> getNotificationTemplateById(String templateId) async {
    try {
      final model = await _remoteDataSource.getNotificationTemplateById(templateId);
      return _mapNotificationTemplateToEntity(model);
    } catch (e) {
      throw Exception('Repository: Failed to get notification template - $e');
    }
  }

  @override
  Future<NotificationTemplateEntity> createNotificationTemplate({
    required String templateKey,
    required String title,
    required String body,
    String? emailSubject,
    String? emailBody,
    required String notificationType,
  }) async {
    try {
      final model = await _remoteDataSource.createNotificationTemplate(
        templateKey: templateKey,
        title: title,
        body: body,
        emailSubject: emailSubject,
        emailBody: emailBody,
        notificationType: notificationType,
      );
      return _mapNotificationTemplateToEntity(model);
    } catch (e) {
      throw Exception('Repository: Failed to create notification template - $e');
    }
  }

  @override
  Future<NotificationTemplateEntity> updateNotificationTemplate({
    required String templateId,
    String? title,
    String? body,
    String? emailSubject,
    String? emailBody,
    bool? isEnabled,
  }) async {
    try {
      final model = await _remoteDataSource.updateNotificationTemplate(
        templateId: templateId,
        title: title,
        body: body,
        emailSubject: emailSubject,
        emailBody: emailBody,
        isEnabled: isEnabled,
      );
      return _mapNotificationTemplateToEntity(model);
    } catch (e) {
      throw Exception('Repository: Failed to update notification template - $e');
    }
  }

  @override
  Future<void> deleteNotificationTemplate(String templateId) async {
    try {
      await _remoteDataSource.deleteNotificationTemplate(templateId);
    } catch (e) {
      throw Exception('Repository: Failed to delete notification template - $e');
    }
  }

  @override
  Future<NotificationTemplateEntity> toggleNotificationTemplate({
    required String templateId,
    required bool isEnabled,
  }) async {
    try {
      final model = await _remoteDataSource.toggleNotificationTemplate(
        templateId: templateId,
        isEnabled: isEnabled,
      );
      return _mapNotificationTemplateToEntity(model);
    } catch (e) {
      throw Exception('Repository: Failed to toggle notification template - $e');
    }
  }

  // ==================== NOTIFICATION SCHEDULES ====================

  @override
  Future<List<NotificationScheduleEntity>> getNotificationSchedules() async {
    try {
      final models = await _remoteDataSource.getNotificationSchedules();
      return models.map(_mapNotificationScheduleToEntity).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get notification schedules - $e');
    }
  }

  @override
  Future<NotificationScheduleEntity> getNotificationScheduleById(String scheduleId) async {
    try {
      final model = await _remoteDataSource.getNotificationScheduleById(scheduleId);
      return _mapNotificationScheduleToEntity(model);
    } catch (e) {
      throw Exception('Repository: Failed to get notification schedule - $e');
    }
  }

  @override
  Future<NotificationScheduleEntity> createNotificationSchedule({
    required String notificationTemplateId,
    required String scheduledTime,
    required String frequency,
    List<int>? daysOfWeek,
    Map<String, dynamic>? conditions,
    required String createdBy,
  }) async {
    try {
      final model = await _remoteDataSource.createNotificationSchedule(
        notificationTemplateId: notificationTemplateId,
        scheduledTime: scheduledTime,
        frequency: frequency,
        daysOfWeek: daysOfWeek,
        conditions: conditions,
        createdBy: createdBy,
      );
      return _mapNotificationScheduleToEntity(model);
    } catch (e) {
      throw Exception('Repository: Failed to create notification schedule - $e');
    }
  }

  @override
  Future<NotificationScheduleEntity> updateNotificationSchedule({
    required String scheduleId,
    String? notificationTemplateId,
    String? scheduledTime,
    String? frequency,
    List<int>? daysOfWeek,
    Map<String, dynamic>? conditions,
    bool? isActive,
  }) async {
    try {
      final model = await _remoteDataSource.updateNotificationSchedule(
        scheduleId: scheduleId,
        notificationTemplateId: notificationTemplateId,
        scheduledTime: scheduledTime,
        frequency: frequency,
        daysOfWeek: daysOfWeek,
        conditions: conditions,
        isActive: isActive,
      );
      return _mapNotificationScheduleToEntity(model);
    } catch (e) {
      throw Exception('Repository: Failed to update notification schedule - $e');
    }
  }

  @override
  Future<void> deleteNotificationSchedule(String scheduleId) async {
    try {
      await _remoteDataSource.deleteNotificationSchedule(scheduleId);
    } catch (e) {
      throw Exception('Repository: Failed to delete notification schedule - $e');
    }
  }

  @override
  Future<NotificationScheduleEntity> toggleNotificationSchedule({
    required String scheduleId,
    required bool isActive,
  }) async {
    try {
      final model = await _remoteDataSource.toggleNotificationSchedule(
        scheduleId: scheduleId,
        isActive: isActive,
      );
      return _mapNotificationScheduleToEntity(model);
    } catch (e) {
      throw Exception('Repository: Failed to toggle notification schedule - $e');
    }
  }

  @override
  Future<void> sendManualNotification({
    required List<String> userIds,
    required String title,
    required String body,
    String? notificationType,
  }) async {
    try {
      await _remoteDataSource.sendManualNotification(
        userIds: userIds,
        title: title,
        body: body,
        notificationType: notificationType,
      );
    } catch (e) {
      throw Exception('Repository: Failed to send manual notification - $e');
    }
  }

  // ==================== MAPPER FUNCTIONS ====================

  NotificationTemplateEntity _mapNotificationTemplateToEntity(model) {
    return NotificationTemplateEntity(
      id: model.id,
      templateKey: model.templateKey,
      title: model.title,
      body: model.body,
      emailSubject: model.emailSubject,
      emailBody: model.emailBody,
      notificationType: model.notificationType,
      isEnabled: model.isEnabled,
      isSystemDefault: model.isSystemDefault,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  NotificationScheduleEntity _mapNotificationScheduleToEntity(model) {
    return NotificationScheduleEntity(
      id: model.id,
      notificationTemplateId: model.notificationTemplateId,
      scheduledTime: model.scheduledTime,
      frequency: model.frequency,
      daysOfWeek: model.daysOfWeek,
      conditions: model.conditions,
      isActive: model.isActive,
      createdBy: model.createdBy,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  // ==================== REPORT MANAGEMENT ====================

  @override
  Future<List<DeedReportEntity>> searchReports({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      final reports = await _remoteDataSource.searchReports(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      return reports.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search reports: $e');
    }
  }

  @override
  Future<DeedReportEntity> getReportById(String reportId) async {
    try {
      final report = await _remoteDataSource.getReportById(reportId);
      return report.toEntity();
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  @override
  Future<DeedReportEntity> updateReport({
    required String reportId,
    required Map<String, double> deedValues,
    required String reason,
  }) async {
    try {
      final report = await _remoteDataSource.updateReport(
        reportId: reportId,
        deedValues: deedValues,
        reason: reason,
      );
      return report.toEntity();
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }
}
