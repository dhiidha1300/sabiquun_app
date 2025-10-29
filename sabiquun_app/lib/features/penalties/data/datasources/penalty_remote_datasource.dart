import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/penalty_model.dart';
import '../models/penalty_balance_model.dart';

class PenaltyRemoteDataSource {
  final SupabaseClient _supabaseClient;

  PenaltyRemoteDataSource(this._supabaseClient);

  /// Get user's current penalty balance with statistics
  Future<PenaltyBalanceModel> getUserBalance(String userId) async {
    try {
      // Get all unpaid and partially paid penalties
      final penaltiesResponse = await _supabaseClient
          .from('penalties')
          .select()
          .eq('user_id', userId)
          .inFilter('status', ['unpaid', 'partially_paid'])
          .order('date_incurred', ascending: true);

      final penalties = (penaltiesResponse as List)
          .map((json) => PenaltyModel.fromJson(json))
          .toList();

      // Calculate total balance
      double balance = 0;
      DateTime? oldestPenaltyDate;

      for (final penalty in penalties) {
        balance += (penalty.amount - penalty.paidAmount);
        if (oldestPenaltyDate == null ||
            penalty.dateIncurred.isBefore(oldestPenaltyDate)) {
          oldestPenaltyDate = penalty.dateIncurred;
        }
      }

      // Get system thresholds from settings
      final settingsResponse = await _supabaseClient
          .from('settings')
          .select('setting_key, setting_value')
          .inFilter('setting_key', [
        'auto_deactivation_threshold',
        'first_warning_threshold',
        'final_warning_threshold',
      ]);

      double deactivationThreshold = 500000; // default
      double? firstWarningThreshold;
      double? finalWarningThreshold;

      for (final setting in settingsResponse as List) {
        final key = setting['setting_key'] as String;
        final value = double.tryParse(setting['setting_value'].toString()) ?? 0;

        if (key == 'auto_deactivation_threshold') {
          deactivationThreshold = value;
        } else if (key == 'first_warning_threshold') {
          firstWarningThreshold = value;
        } else if (key == 'final_warning_threshold') {
          finalWarningThreshold = value;
        }
      }

      // Check if approaching deactivation
      bool approachingDeactivation = false;
      if (firstWarningThreshold != null && balance >= firstWarningThreshold) {
        approachingDeactivation = true;
      }

      return PenaltyBalanceModel(
        balance: balance,
        unpaidPenaltiesCount: penalties.length,
        oldestPenaltyDate: oldestPenaltyDate,
        approachingDeactivation: approachingDeactivation,
        deactivationThreshold: deactivationThreshold,
        firstWarningThreshold: firstWarningThreshold,
        finalWarningThreshold: finalWarningThreshold,
      );
    } catch (e) {
      throw Exception('Failed to fetch penalty balance: $e');
    }
  }

  /// Get list of penalties for a user with optional filters
  Future<List<PenaltyModel>> getUserPenalties({
    required String userId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      dynamic query = _supabaseClient
          .from('penalties')
          .select()
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (startDate != null) {
        query = query.gte('date_incurred', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date_incurred', endDate.toIso8601String());
      }

      query = query.order('date_incurred', ascending: false);

      final response = await query;

      return (response as List)
          .map((json) => PenaltyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch penalties: $e');
    }
  }

  /// Get a specific penalty by ID
  Future<PenaltyModel> getPenaltyById(String penaltyId) async {
    try {
      final response = await _supabaseClient
          .from('penalties')
          .select()
          .eq('id', penaltyId)
          .single();

      return PenaltyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch penalty: $e');
    }
  }

  /// Get unpaid penalties ordered by date (FIFO - oldest first)
  Future<List<PenaltyModel>> getUnpaidPenaltiesForPayment(String userId) async {
    try {
      final response = await _supabaseClient
          .from('penalties')
          .select()
          .eq('user_id', userId)
          .inFilter('status', ['unpaid', 'partially_paid'])
          .order('date_incurred', ascending: true); // Oldest first (FIFO)

      return (response as List)
          .map((json) => PenaltyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch unpaid penalties: $e');
    }
  }

  /// Waive a penalty
  Future<void> waivePenalty({
    required String penaltyId,
    required String waivedBy,
    required String reason,
  }) async {
    try {
      await _supabaseClient.from('penalties').update({
        'status': 'waived',
        'waived_by': waivedBy,
        'waived_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', penaltyId);

      // Log audit trail
      await _logAuditTrail(
        action: 'penalty_waived',
        performedBy: waivedBy,
        entityType: 'penalty',
        entityId: penaltyId,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to waive penalty: $e');
    }
  }

  /// Create manual penalty
  Future<PenaltyModel> createManualPenalty({
    required String userId,
    required double amount,
    required DateTime dateIncurred,
    required String reason,
    required String createdBy,
  }) async {
    try {
      final response = await _supabaseClient
          .from('penalties')
          .insert({
            'user_id': userId,
            'report_id': null, // Manual penalty has no report
            'amount': amount,
            'date_incurred': dateIncurred.toIso8601String(),
            'status': 'unpaid',
            'paid_amount': 0,
          })
          .select()
          .single();

      // Log audit trail
      await _logAuditTrail(
        action: 'manual_penalty_created',
        performedBy: createdBy,
        entityType: 'penalty',
        entityId: response['id'],
        reason: reason,
      );

      return PenaltyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create manual penalty: $e');
    }
  }

  /// Update penalty amount
  Future<void> updatePenaltyAmount({
    required String penaltyId,
    required double newAmount,
    required String reason,
    required String updatedBy,
  }) async {
    try {
      // Get old amount for audit log
      final oldPenalty = await getPenaltyById(penaltyId);

      await _supabaseClient.from('penalties').update({
        'amount': newAmount,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', penaltyId);

      // Log audit trail
      await _logAuditTrail(
        action: 'penalty_amount_updated',
        performedBy: updatedBy,
        entityType: 'penalty',
        entityId: penaltyId,
        reason: reason,
        oldValue: {'amount': oldPenalty.amount},
        newValue: {'amount': newAmount},
      );
    } catch (e) {
      throw Exception('Failed to update penalty amount: $e');
    }
  }

  /// Remove penalty
  Future<void> removePenalty({
    required String penaltyId,
    required String reason,
    required String removedBy,
  }) async {
    try {
      // Get penalty data for audit log before deletion
      final penalty = await getPenaltyById(penaltyId);

      await _supabaseClient.from('penalties').delete().eq('id', penaltyId);

      // Log audit trail
      await _logAuditTrail(
        action: 'penalty_removed',
        performedBy: removedBy,
        entityType: 'penalty',
        entityId: penaltyId,
        reason: reason,
        oldValue: {'amount': penalty.amount, 'date_incurred': penalty.dateIncurred.toIso8601String()},
      );
    } catch (e) {
      throw Exception('Failed to remove penalty: $e');
    }
  }

  /// Calculate daily penalties (call the database function)
  /// This should be called daily at 12:00 PM via a scheduled task
  /// Returns a map with execution results
  Future<Map<String, dynamic>> calculateDailyPenalties() async {
    try {
      final response = await _supabaseClient.rpc('calculate_daily_penalties');

      if (response == null) {
        throw Exception('No response from penalty calculation function');
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to calculate daily penalties: $e');
    }
  }

  /// Calculate daily penalties with logging
  /// This version saves execution results to penalty_calculation_log table
  Future<Map<String, dynamic>> calculateDailyPenaltiesWithLogging() async {
    try {
      final response = await _supabaseClient.rpc('calculate_daily_penalties_with_logging');

      if (response == null) {
        throw Exception('No response from penalty calculation function');
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to calculate daily penalties: $e');
    }
  }

  /// Log audit trail for penalty actions
  Future<void> _logAuditTrail({
    required String action,
    required String performedBy,
    required String entityType,
    required String entityId,
    required String reason,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
  }) async {
    try {
      await _supabaseClient.from('audit_logs').insert({
        'action': action,
        'performed_by': performedBy,
        'entity_type': entityType,
        'entity_id': entityId,
        'old_value': oldValue,
        'new_value': newValue,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Don't throw - audit log failure shouldn't break the main operation
      print('Warning: Failed to log audit trail: $e');
    }
  }
}
