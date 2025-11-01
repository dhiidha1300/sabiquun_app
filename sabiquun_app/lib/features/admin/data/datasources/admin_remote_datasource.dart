import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_management_model.dart';
import '../models/analytics_model.dart';
import '../models/system_settings_model.dart';
import '../models/deed_template_model.dart';

class AdminRemoteDataSource {
  final SupabaseClient _supabase;

  AdminRemoteDataSource(this._supabase);

  // ==================== USER MANAGEMENT ====================

  /// Get all users with optional filters and statistics
  Future<List<UserManagementModel>> getUsers({
    String? accountStatus,
    String? searchQuery,
    String? membershipStatus,
  }) async {
    try {
      var query = _supabase.from('users').select('''
        id,
        email,
        name,
        phone,
        photo_url,
        role,
        account_status,
        membership_status,
        created_at,
        approved_at,
        approved_by,
        updated_at,
        excuse_mode
      ''');

      // Apply filters
      if (accountStatus != null && accountStatus.isNotEmpty) {
        query = query.eq('account_status', accountStatus);
      }

      if (membershipStatus != null && membershipStatus.isNotEmpty) {
        query = query.eq('membership_status', membershipStatus);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
      }

      // Order by created_at descending
      final response = await query.order('created_at', ascending: false);

      // Fetch statistics for each user
      final users = response as List<dynamic>;
      final List<UserManagementModel> result = [];

      for (var userData in users) {
        final userId = userData['id'] as String;

        // Get user statistics
        final stats = await _getUserStatistics(userId);

        // Merge user data with statistics
        final userWithStats = <String, dynamic>{
          ...Map<String, dynamic>.from(userData as Map),
          ...stats,
        };

        result.add(UserManagementModel.fromJson(userWithStats));
      }

      return result;
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Get statistics for a single user
  Future<Map<String, dynamic>> _getUserStatistics(String userId) async {
    try {
      // Get penalty balance
      final penaltiesResponse = await _supabase
          .from('penalties')
          .select('amount, paid_amount')
          .eq('user_id', userId)
          .inFilter('status', ['unpaid', 'partially_paid']);

      double currentBalance = 0.0;
      for (var penalty in penaltiesResponse as List<dynamic>) {
        final amount = (penalty['amount'] as num?)?.toDouble() ?? 0.0;
        final paidAmount = (penalty['paid_amount'] as num?)?.toDouble() ?? 0.0;
        currentBalance += (amount - paidAmount);
      }

      // Get total reports count
      final reportsResponse = await _supabase
          .from('deeds_reports')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'submitted');

      final totalReports = (reportsResponse as List<dynamic>).length;

      // Get compliance rate from user_statistics table if exists
      double complianceRate = 0.0;
      DateTime? lastReportDate;

      try {
        final statsResponse = await _supabase
            .from('user_statistics')
            .select('compliance_rate, last_report_date')
            .eq('user_id', userId)
            .maybeSingle();

        if (statsResponse != null) {
          complianceRate = (statsResponse['compliance_rate'] as num?)?.toDouble() ?? 0.0;
          final lastReportStr = statsResponse['last_report_date'];
          if (lastReportStr != null) {
            lastReportDate = DateTime.parse(lastReportStr as String);
          }
        }
      } catch (e) {
        // user_statistics might not exist yet
      }

      // Get last report date from reports if not in statistics
      if (lastReportDate == null) {
        try {
          final lastReportResponse = await _supabase
              .from('deeds_reports')
              .select('report_date')
              .eq('user_id', userId)
              .eq('status', 'submitted')
              .order('report_date', ascending: false)
              .limit(1)
              .maybeSingle();

          if (lastReportResponse != null) {
            lastReportDate = DateTime.parse(lastReportResponse['report_date'] as String);
          }
        } catch (e) {
          // No reports yet
        }
      }

      return {
        'current_balance': currentBalance,
        'total_reports': totalReports,
        'compliance_rate': complianceRate,
        'last_report_date': lastReportDate?.toIso8601String(),
      };
    } catch (e) {
      // Return default values on error
      return {
        'current_balance': 0.0,
        'total_reports': 0,
        'compliance_rate': 0.0,
        'last_report_date': null,
      };
    }
  }

  /// Get a single user by ID with full details
  Future<UserManagementModel> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('''
            id,
            email,
            name,
            phone,
            photo_url,
            role,
            account_status,
            membership_status,
            created_at,
            approved_at,
            approved_by,
            updated_at,
            excuse_mode
          ''')
          .eq('id', userId)
          .single();

      // Get statistics
      final stats = await _getUserStatistics(userId);

      // Merge data
      final userWithStats = {
        ...response,
        ...stats,
      };

      return UserManagementModel.fromJson(userWithStats);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Approve a pending user
  Future<void> approveUser({
    required String userId,
    required String approvedBy,
  }) async {
    try {
      // Update user status
      await _supabase.from('users').update({
        'account_status': 'active',
        'approved_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Create audit log
      await _createAuditLog(
        actionType: 'user_approved',
        performedBy: approvedBy,
        affectedUserId: userId,
        entityType: 'user',
        entityId: userId,
        newValues: {'account_status': 'active'},
      );
    } catch (e) {
      throw Exception('Failed to approve user: $e');
    }
  }

  /// Reject a pending user
  Future<void> rejectUser({
    required String userId,
    required String rejectedBy,
    required String reason,
  }) async {
    try {
      // Delete user (or mark as rejected depending on requirements)
      await _supabase.from('users').delete().eq('id', userId);

      // Create audit log
      await _createAuditLog(
        actionType: 'user_rejected',
        performedBy: rejectedBy,
        affectedUserId: userId,
        entityType: 'user',
        entityId: userId,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to reject user: $e');
    }
  }

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
  }) async {
    try {
      // Get old values for audit log
      final oldUser = await getUserById(userId);
      final oldValues = {
        'name': oldUser.name,
        'email': oldUser.email,
        'phone': oldUser.phone,
        'role': oldUser.role,
        'membership_status': oldUser.membershipStatus,
        'account_status': oldUser.accountStatus,
      };

      // Build update data
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photo_url'] = photoUrl;
      if (role != null) updateData['role'] = role;
      if (membershipStatus != null) updateData['membership_status'] = membershipStatus;
      if (accountStatus != null) updateData['account_status'] = accountStatus;

      // Update user
      final updateResult = await _supabase
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select();

      if (updateResult.isEmpty) {
        throw Exception('Update failed: No rows affected. Check RLS policies or user ID.');
      }

      // Create audit log
      await _createAuditLog(
        actionType: 'user_updated',
        performedBy: updatedBy,
        affectedUserId: userId,
        entityType: 'user',
        entityId: userId,
        oldValues: oldValues,
        newValues: updateData,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Change user role
  Future<void> changeUserRole({
    required String userId,
    required String newRole,
    required String changedBy,
    required String reason,
  }) async {
    try {
      // Get old role
      final oldUser = await getUserById(userId);
      final oldRole = oldUser.role;

      // Update role
      await _supabase.from('users').update({
        'role': newRole,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Create audit log
      await _createAuditLog(
        actionType: 'role_changed',
        performedBy: changedBy,
        affectedUserId: userId,
        entityType: 'user',
        entityId: userId,
        oldValues: {'role': oldRole},
        newValues: {'role': newRole},
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to change user role: $e');
    }
  }

  /// Suspend user
  Future<void> suspendUser({
    required String userId,
    required String suspendedBy,
    required String reason,
  }) async {
    try {
      await _supabase.from('users').update({
        'account_status': 'suspended',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Create audit log
      await _createAuditLog(
        actionType: 'user_suspended',
        performedBy: suspendedBy,
        affectedUserId: userId,
        entityType: 'user',
        entityId: userId,
        oldValues: {'account_status': 'active'},
        newValues: {'account_status': 'suspended'},
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to suspend user: $e');
    }
  }

  /// Activate suspended user
  Future<void> activateUser({
    required String userId,
    required String activatedBy,
    required String reason,
  }) async {
    try {
      await _supabase.from('users').update({
        'account_status': 'active',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Create audit log
      await _createAuditLog(
        actionType: 'user_reactivated',
        performedBy: activatedBy,
        affectedUserId: userId,
        entityType: 'user',
        entityId: userId,
        oldValues: {'account_status': 'suspended'},
        newValues: {'account_status': 'active'},
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser({
    required String userId,
    required String deletedBy,
    required String reason,
  }) async {
    try {
      // Get user data for audit log
      final user = await getUserById(userId);

      // Create audit log before deletion
      await _createAuditLog(
        actionType: 'user_deleted',
        performedBy: deletedBy,
        affectedUserId: userId,
        entityType: 'user',
        entityId: userId,
        oldValues: {
          'name': user.name,
          'email': user.email,
          'role': user.role,
        },
        reason: reason,
      );

      // Delete user (cascade delete should handle related records)
      await _supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Create an audit log entry
  Future<void> _createAuditLog({
    required String actionType,
    required String performedBy,
    String? affectedUserId,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? reason,
    String? notes,
  }) async {
    try {
      // Get performer name
      String performedByName = 'Unknown';
      try {
        final performer = await _supabase
            .from('users')
            .select('name')
            .eq('id', performedBy)
            .maybeSingle();

        if (performer != null) {
          performedByName = performer['name'] as String;
        }
      } catch (e) {
        // Continue with unknown name
      }

      // Get affected user name
      String? affectedUserName;
      if (affectedUserId != null) {
        try {
          final affectedUser = await _supabase
              .from('users')
              .select('name')
              .eq('id', affectedUserId)
              .maybeSingle();

          if (affectedUser != null) {
            affectedUserName = affectedUser['name'] as String;
          }
        } catch (e) {
          // Continue without name
        }
      }

      await _supabase.from('audit_logs').insert({
        'action_type': actionType,
        'performed_by': performedBy,
        'performed_by_name': performedByName,
        'affected_user_id': affectedUserId,
        'affected_user_name': affectedUserName,
        'entity_type': entityType,
        'entity_id': entityId,
        'old_values': oldValues,
        'new_values': newValues,
        'reason': reason,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Don't throw - audit log failure shouldn't break the operation
      // Log error silently
    }
  }

  // ==================== ANALYTICS ====================

  /// Get comprehensive system analytics
  Future<AnalyticsModel> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Use current date if no dates provided
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month, 1);
      final end = endDate ?? now;

      // Execute all analytics queries in parallel
      final results = await Future.wait([
        _getUserMetrics(),
        _getDeedMetrics(start, end),
        _getFinancialMetrics(start, end),
        _getEngagementMetrics(),
        _getExcuseMetrics(),
      ]);

      return AnalyticsModel(
        userMetrics: results[0] as UserMetricsModel,
        deedMetrics: results[1] as DeedMetricsModel,
        financialMetrics: results[2] as FinancialMetricsModel,
        engagementMetrics: results[3] as EngagementMetricsModel,
        excuseMetrics: results[4] as ExcuseMetricsModel,
      );
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }

  Future<UserMetricsModel> _getUserMetrics() async {
    final response = await _supabase.rpc('get_user_metrics');

    return UserMetricsModel(
      pendingUsers: response['pending_users'] ?? 0,
      activeUsers: response['active_users'] ?? 0,
      suspendedUsers: response['suspended_users'] ?? 0,
      deactivatedUsers: response['deactivated_users'] ?? 0,
      newMembers: response['new_members'] ?? 0,
      exclusiveMembers: response['exclusive_members'] ?? 0,
      legacyMembers: response['legacy_members'] ?? 0,
      usersAtRisk: response['users_at_risk'] ?? 0,
      newRegistrationsThisWeek: response['new_registrations_this_week'] ?? 0,
    );
  }

  Future<DeedMetricsModel> _getDeedMetrics(DateTime start, DateTime end) async {
    final response = await _supabase.rpc('get_deed_metrics', params: {
      'start_date': start.toIso8601String(),
      'end_date': end.toIso8601String(),
    });

    return DeedMetricsModel(
      totalDeedsToday: response['total_deeds_today'] ?? 0,
      totalDeedsWeek: response['total_deeds_week'] ?? 0,
      totalDeedsMonth: response['total_deeds_month'] ?? 0,
      totalDeedsAllTime: response['total_deeds_all_time'] ?? 0,
      averagePerUserToday: (response['average_per_user_today'] ?? 0.0).toDouble(),
      averagePerUserWeek: (response['average_per_user_week'] ?? 0.0).toDouble(),
      averagePerUserMonth: (response['average_per_user_month'] ?? 0.0).toDouble(),
      complianceRateToday: (response['compliance_rate_today'] ?? 0.0).toDouble(),
      complianceRateWeek: (response['compliance_rate_week'] ?? 0.0).toDouble(),
      complianceRateMonth: (response['compliance_rate_month'] ?? 0.0).toDouble(),
      usersCompletedToday: response['users_completed_today'] ?? 0,
      totalActiveUsers: response['total_active_users'] ?? 0,
      faraidComplianceRate: (response['faraid_compliance_rate'] ?? 0.0).toDouble(),
      sunnahComplianceRate: (response['sunnah_compliance_rate'] ?? 0.0).toDouble(),
      topPerformers: (response['top_performers'] as List? ?? [])
          .map((p) => TopPerformerModel.fromJson(p))
          .toList(),
      usersNeedingAttention: (response['users_needing_attention'] as List? ?? [])
          .map((u) => UserNeedingAttentionModel.fromJson(u))
          .toList(),
      deedComplianceByType: Map<String, double>.from(
          response['deed_compliance_by_type'] ?? {}),
    );
  }

  Future<FinancialMetricsModel> _getFinancialMetrics(
      DateTime start, DateTime end) async {
    final response = await _supabase.rpc('get_financial_metrics', params: {
      'start_date': start.toIso8601String(),
      'end_date': end.toIso8601String(),
    });

    return FinancialMetricsModel(
      penaltiesIncurredThisMonth:
          (response['penalties_incurred_this_month'] ?? 0.0).toDouble(),
      penaltiesIncurredAllTime:
          (response['penalties_incurred_all_time'] ?? 0.0).toDouble(),
      paymentsReceivedThisMonth:
          (response['payments_received_this_month'] ?? 0.0).toDouble(),
      paymentsReceivedAllTime:
          (response['payments_received_all_time'] ?? 0.0).toDouble(),
      outstandingBalance: (response['outstanding_balance'] ?? 0.0).toDouble(),
      pendingPaymentsCount: response['pending_payments_count'] ?? 0,
      pendingPaymentsAmount:
          (response['pending_payments_amount'] ?? 0.0).toDouble(),
    );
  }

  Future<EngagementMetricsModel> _getEngagementMetrics() async {
    final response = await _supabase.rpc('get_engagement_metrics');

    return EngagementMetricsModel(
      dailyActiveUsers: response['daily_active_users'] ?? 0,
      totalActiveUsers: response['total_active_users'] ?? 0,
      reportSubmissionRate:
          (response['report_submission_rate'] ?? 0.0).toDouble(),
      averageSubmissionTime: response['average_submission_time'] ?? '00:00',
      notificationOpenRate:
          (response['notification_open_rate'] ?? 0.0).toDouble(),
      averageResponseTimeMinutes: response['average_response_time_minutes'] ?? 0,
    );
  }

  Future<ExcuseMetricsModel> _getExcuseMetrics() async {
    final response = await _supabase.rpc('get_excuse_metrics');

    return ExcuseMetricsModel(
      pendingExcuses: response['pending_excuses'] ?? 0,
      approvalRate: (response['approval_rate'] ?? 0.0).toDouble(),
      excusesByReason:
          Map<String, int>.from(response['excuses_by_reason'] ?? {}),
    );
  }

  // ==================== SYSTEM SETTINGS ====================

  /// Get all system settings
  Future<SystemSettingsModel> getSystemSettings() async {
    try {
      final response = await _supabase.from('settings').select('setting_key, setting_value');

      // Convert list of key-value pairs to map
      final Map<String, dynamic> settingsMap = {};
      for (var setting in response as List) {
        settingsMap[setting['setting_key']] = setting['setting_value'];
      }

      return SystemSettingsModel.fromSettingsMap(settingsMap);
    } catch (e) {
      throw Exception('Failed to get system settings: $e');
    }
  }

  /// Update system settings
  Future<void> updateSystemSettings({
    required SystemSettingsModel settings,
    required String updatedBy,
  }) async {
    try {
      final settingsMap = settings.toSettingsMap();

      // Update each setting individually
      for (var entry in settingsMap.entries) {
        await _supabase.from('settings').upsert({
          'setting_key': entry.key,
          'setting_value': entry.value.toString(),
          'updated_at': DateTime.now().toIso8601String(),
          'updated_by': updatedBy,
        });
      }

      // Log audit trail
      await _createAuditLog(
        actionType: 'system_settings_updated',
        performedBy: updatedBy,
        entityType: 'system_settings',
        entityId: 'global',
        reason: 'System settings updated',
        notes: 'Updated ${settingsMap.length} settings',
      );
    } catch (e) {
      throw Exception('Failed to update system settings: $e');
    }
  }

  /// Get a single setting value by key
  Future<String?> getSettingValue(String key) async {
    try {
      final response = await _supabase
          .from('settings')
          .select('setting_value')
          .eq('setting_key', key)
          .maybeSingle();

      return response?['setting_value'] as String?;
    } catch (e) {
      throw Exception('Failed to get setting value: $e');
    }
  }

  /// Update a single setting
  Future<void> updateSetting({
    required String key,
    required String value,
    required String updatedBy,
  }) async {
    try {
      await _supabase.from('settings').upsert({
        'setting_key': key,
        'setting_value': value,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': updatedBy,
      });

      // Log audit trail
      await _createAuditLog(
        actionType: 'setting_updated',
        performedBy: updatedBy,
        entityType: 'setting',
        entityId: key,
        reason: 'Setting updated',
        newValues: {'setting_value': value},
      );
    } catch (e) {
      throw Exception('Failed to update setting: $e');
    }
  }

  // ==================== DEED TEMPLATE MANAGEMENT ====================

  /// Get all deed templates with optional filters
  Future<List<DeedTemplateModel>> getDeedTemplates({
    bool? isActive,
    String? category,
  }) async {
    try {
      var query = _supabase.from('deed_templates').select('*');

      // Apply filters
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      // Order by sort_order
      final response = await query.order('sort_order', ascending: true);

      return (response as List)
          .map((json) => DeedTemplateModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get deed templates: $e');
    }
  }

  /// Create a new deed template
  Future<DeedTemplateModel> createDeedTemplate({
    required String deedName,
    required String deedKey,
    required String category,
    required String valueType,
    required int sortOrder,
    required bool isActive,
    required String createdBy,
  }) async {
    try {
      final response = await _supabase.from('deed_templates').insert({
        'deed_name': deedName,
        'deed_key': deedKey,
        'category': category,
        'value_type': valueType,
        'sort_order': sortOrder,
        'is_active': isActive,
        'is_system_default': false, // Custom deeds are never system defaults
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      // Log audit trail
      await _createAuditLog(
        actionType: 'deed_template_created',
        performedBy: createdBy,
        entityType: 'deed_template',
        entityId: response['id'] as String,
        reason: 'New deed template created',
        newValues: {
          'deed_name': deedName,
          'category': category,
          'value_type': valueType,
        },
      );

      return DeedTemplateModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create deed template: $e');
    }
  }

  /// Update deed template
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
      // Get old values for audit log
      final oldData = await _supabase
          .from('deed_templates')
          .select()
          .eq('id', templateId)
          .single();

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (deedName != null) updates['deed_name'] = deedName;
      if (category != null) updates['category'] = category;
      if (valueType != null) updates['value_type'] = valueType;
      if (sortOrder != null) updates['sort_order'] = sortOrder;
      if (isActive != null) updates['is_active'] = isActive;

      await _supabase
          .from('deed_templates')
          .update(updates)
          .eq('id', templateId);

      // Log audit trail
      await _createAuditLog(
        actionType: 'deed_template_updated',
        performedBy: updatedBy,
        entityType: 'deed_template',
        entityId: templateId,
        reason: 'Deed template updated',
        oldValues: oldData as Map<String, dynamic>?,
        newValues: updates,
      );
    } catch (e) {
      throw Exception('Failed to update deed template: $e');
    }
  }

  /// Deactivate deed template
  Future<void> deactivateDeedTemplate({
    required String templateId,
    required String deactivatedBy,
    required String reason,
  }) async {
    try {
      // Check if it's a system default
      final template = await _supabase
          .from('deed_templates')
          .select('is_system_default')
          .eq('id', templateId)
          .single();

      if (template['is_system_default'] == true) {
        throw Exception('Cannot deactivate system default deed templates');
      }

      await _supabase
          .from('deed_templates')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', templateId);

      // Log audit trail
      await _createAuditLog(
        actionType: 'deed_template_deactivated',
        performedBy: deactivatedBy,
        entityType: 'deed_template',
        entityId: templateId,
        reason: reason,
        newValues: {'is_active': false},
      );
    } catch (e) {
      throw Exception('Failed to deactivate deed template: $e');
    }
  }

  /// Reorder deed templates by updating sort_order
  Future<void> reorderDeedTemplates({
    required List<String> templateIds,
    required String updatedBy,
  }) async {
    try {
      // Update each template's sort_order based on its position in the list
      for (int i = 0; i < templateIds.length; i++) {
        await _supabase
            .from('deed_templates')
            .update({
              'sort_order': i + 1,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', templateIds[i]);
      }

      // Log audit trail
      await _createAuditLog(
        actionType: 'deed_templates_reordered',
        performedBy: updatedBy,
        entityType: 'deed_template',
        entityId: 'bulk',
        reason: 'Deed templates reordered',
        newValues: {'template_count': templateIds.length},
      );
    } catch (e) {
      throw Exception('Failed to reorder deed templates: $e');
    }
  }

  /// Delete deed template (only for non-system-default templates)
  Future<void> deleteDeedTemplate({
    required String templateId,
    required String deletedBy,
    required String reason,
  }) async {
    try {
      // Check if it's a system default
      final template = await _supabase
          .from('deed_templates')
          .select('is_system_default, deed_name')
          .eq('id', templateId)
          .single();

      if (template['is_system_default'] == true) {
        throw Exception('Cannot delete system default deed templates');
      }

      // Soft delete by deactivating instead of hard delete
      // This preserves historical data in reports
      await _supabase
          .from('deed_templates')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', templateId);

      // Log audit trail
      await _createAuditLog(
        actionType: 'deed_template_deleted',
        performedBy: deletedBy,
        entityType: 'deed_template',
        entityId: templateId,
        reason: reason,
        oldValues: {'deed_name': template['deed_name']},
      );
    } catch (e) {
      throw Exception('Failed to delete deed template: $e');
    }
  }
}
