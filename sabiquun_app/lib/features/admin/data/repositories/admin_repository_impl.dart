import '../../domain/entities/user_management_entity.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/entities/notification_template_entity.dart';
import '../../domain/entities/rest_day_entity.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../deeds/domain/entities/deed_template_entity.dart';
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

  // ==================== DEED TEMPLATES (Stub) ====================

  @override
  Future<List<DeedTemplateEntity>> getDeedTemplates({
    bool? isActive,
    String? category,
  }) {
    throw UnimplementedError('Deed templates not yet implemented');
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
  }) {
    throw UnimplementedError('Deed templates not yet implemented');
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
  }) {
    throw UnimplementedError('Deed templates not yet implemented');
  }

  @override
  Future<void> deactivateDeedTemplate({
    required String templateId,
    required String deactivatedBy,
    required String reason,
  }) {
    throw UnimplementedError('Deed templates not yet implemented');
  }

  @override
  Future<void> reorderDeedTemplates({
    required List<String> templateIds,
    required String updatedBy,
  }) {
    throw UnimplementedError('Deed templates not yet implemented');
  }

  // ==================== AUDIT LOGS (Stub) ====================

  @override
  Future<List<AuditLogEntity>> getAuditLogs({
    String? action,
    String? performedBy,
    String? entityType,
    String? entityId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    throw UnimplementedError('Audit logs not yet implemented');
  }

  @override
  Future<String> exportAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) {
    throw UnimplementedError('Audit logs export not yet implemented');
  }

  // ==================== NOTIFICATION TEMPLATES (Stub) ====================

  @override
  Future<List<NotificationTemplateEntity>> getNotificationTemplates({
    String? templateType,
    bool? isActive,
  }) {
    throw UnimplementedError('Notification templates not yet implemented');
  }

  @override
  Future<NotificationTemplateEntity> getNotificationTemplateById(String templateId) {
    throw UnimplementedError('Notification templates not yet implemented');
  }

  @override
  Future<void> updateNotificationTemplate({
    required String templateId,
    String? emailSubject,
    String? emailBody,
    String? pushTitle,
    String? pushBody,
    bool? isActive,
    required String updatedBy,
  }) {
    throw UnimplementedError('Notification templates not yet implemented');
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
}
