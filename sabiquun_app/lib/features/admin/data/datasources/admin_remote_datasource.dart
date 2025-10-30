import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_management_model.dart';

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
}
