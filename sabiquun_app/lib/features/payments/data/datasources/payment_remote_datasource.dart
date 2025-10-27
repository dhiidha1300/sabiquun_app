import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';
import '../models/payment_method_model.dart';
import '../models/penalty_payment_model.dart';

class PaymentRemoteDataSource {
  final SupabaseClient _supabaseClient;

  PaymentRemoteDataSource(this._supabaseClient);

  /// Get all active payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await _supabaseClient
          .from('payment_methods')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => PaymentMethodModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch payment methods: $e');
    }
  }

  /// Submit a new payment
  Future<PaymentModel> submitPayment({
    required String userId,
    required double amount,
    required String paymentMethodId,
    String? referenceNumber,
  }) async {
    try {
      final response = await _supabaseClient
          .from('payments')
          .insert({
            'user_id': userId,
            'amount': amount,
            'payment_method_id': paymentMethodId,
            'reference_number': referenceNumber,
            'status': 'pending',
          })
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit payment: $e');
    }
  }

  /// Get payment history for a user
  Future<List<PaymentModel>> getPaymentHistory({
    required String userId,
    String? status,
  }) async {
    try {
      dynamic query = _supabaseClient
          .from('payments')
          .select('''
            *,
            payment_methods!inner(display_name),
            users!payments_reviewed_by_fkey(name)
          ''')
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      query = query.order('created_at', ascending: false);

      final response = await query;

      return (response as List).map((json) {
        // Flatten the joined data
        final flatJson = Map<String, dynamic>.from(json);
        if (json['payment_methods'] != null) {
          flatJson['payment_method_name'] = json['payment_methods']['display_name'];
        }
        if (json['users'] != null) {
          flatJson['reviewer_name'] = json['users']['name'];
        }
        flatJson.remove('payment_methods');
        flatJson.remove('users');

        return PaymentModel.fromJson(flatJson);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch payment history: $e');
    }
  }

  /// Get a specific payment by ID
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final response = await _supabaseClient
          .from('payments')
          .select('''
            *,
            payment_methods!inner(display_name),
            users!payments_reviewed_by_fkey(name)
          ''')
          .eq('id', paymentId)
          .single();

      // Flatten the joined data
      final flatJson = Map<String, dynamic>.from(response);
      if (response['payment_methods'] != null) {
        flatJson['payment_method_name'] = response['payment_methods']['display_name'];
      }
      if (response['users'] != null) {
        flatJson['reviewer_name'] = response['users']['name'];
      }
      flatJson.remove('payment_methods');
      flatJson.remove('users');

      return PaymentModel.fromJson(flatJson);
    } catch (e) {
      throw Exception('Failed to fetch payment: $e');
    }
  }

  /// Get all pending payments (Admin/Cashier)
  Future<List<PaymentModel>> getPendingPayments() async {
    try {
      final response = await _supabaseClient
          .from('payments')
          .select('''
            *,
            users!payments_user_id_fkey(name),
            payment_methods!inner(display_name)
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: true); // Oldest first

      return (response as List).map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['payment_methods'] != null) {
          flatJson['payment_method_name'] = json['payment_methods']['display_name'];
        }
        flatJson.remove('payment_methods');
        flatJson.remove('users');

        return PaymentModel.fromJson(flatJson);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending payments: $e');
    }
  }

  /// Approve a payment and apply it to penalties using FIFO
  /// This is the CRITICAL FIFO IMPLEMENTATION
  Future<void> approvePayment({
    required String paymentId,
    required String reviewedBy,
  }) async {
    try {
      // Get payment details
      final paymentResponse = await _supabaseClient
          .from('payments')
          .select()
          .eq('id', paymentId)
          .single();

      final userId = paymentResponse['user_id'] as String;
      double remainingAmount = (paymentResponse['amount'] as num).toDouble();

      // Get unpaid penalties ordered by date (FIFO - oldest first)
      final penaltiesResponse = await _supabaseClient
          .from('penalties')
          .select()
          .eq('user_id', userId)
          .inFilter('status', ['unpaid', 'partially_paid'])
          .order('date_incurred', ascending: true); // FIFO: Oldest first

      final penalties = penaltiesResponse as List;

      // Apply payment to penalties using FIFO
      for (final penaltyJson in penalties) {
        if (remainingAmount <= 0) break;

        final penaltyId = penaltyJson['id'];
        final penaltyAmount = (penaltyJson['amount'] as num).toDouble();
        final paidAmount = (penaltyJson['paid_amount'] as num).toDouble();
        final penaltyRemaining = penaltyAmount - paidAmount;

        // Calculate how much to apply to this penalty
        final amountToApply = remainingAmount >= penaltyRemaining
            ? penaltyRemaining
            : remainingAmount;

        // Create penalty_payment record (junction table)
        await _supabaseClient.from('penalty_payments').insert({
          'payment_id': paymentId,
          'penalty_id': penaltyId,
          'amount_applied': amountToApply,
        });

        // Update penalty
        final newPaidAmount = paidAmount + amountToApply;
        String newStatus;
        if (newPaidAmount >= penaltyAmount) {
          newStatus = 'paid';
        } else if (newPaidAmount > 0) {
          newStatus = 'partially_paid';
        } else {
          newStatus = 'unpaid';
        }

        await _supabaseClient.from('penalties').update({
          'paid_amount': newPaidAmount,
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', penaltyId);

        remainingAmount -= amountToApply;
      }

      // Update payment status to approved
      await _supabaseClient.from('payments').update({
        'status': 'approved',
        'reviewed_by': reviewedBy,
        'reviewed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', paymentId);

      // Log audit trail
      await _logAuditTrail(
        action: 'payment_approved',
        performedBy: reviewedBy,
        entityType: 'payment',
        entityId: paymentId,
        reason: 'Payment approved and applied to penalties using FIFO',
      );

      // TODO: Send notification to user
    } catch (e) {
      throw Exception('Failed to approve payment: $e');
    }
  }

  /// Reject a payment
  Future<void> rejectPayment({
    required String paymentId,
    required String reviewedBy,
    required String reason,
  }) async {
    try {
      await _supabaseClient.from('payments').update({
        'status': 'rejected',
        'reviewed_by': reviewedBy,
        'reviewed_at': DateTime.now().toIso8601String(),
        'rejection_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', paymentId);

      // Log audit trail
      await _logAuditTrail(
        action: 'payment_rejected',
        performedBy: reviewedBy,
        entityType: 'payment',
        entityId: paymentId,
        reason: reason,
      );

      // TODO: Send notification to user
    } catch (e) {
      throw Exception('Failed to reject payment: $e');
    }
  }

  /// Get penalty payment links for a payment
  Future<List<PenaltyPaymentModel>> getPenaltyPayments(String paymentId) async {
    try {
      final response = await _supabaseClient
          .from('penalty_payments')
          .select()
          .eq('payment_id', paymentId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => PenaltyPaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch penalty payments: $e');
    }
  }

  /// Manual balance clearing (Admin/Cashier)
  Future<void> manualBalanceClear({
    required String userId,
    required double amount,
    required String reason,
    required String clearedBy,
  }) async {
    try {
      // Create a manual payment record
      final paymentResponse = await _supabaseClient
          .from('payments')
          .insert({
            'user_id': userId,
            'amount': amount,
            'payment_method_id': null, // Manual clearing has no method
            'reference_number': 'MANUAL_CLEAR',
            'status': 'approved',
            'reviewed_by': clearedBy,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final paymentId = paymentResponse['id'];

      // Apply to penalties using FIFO (same logic as approvePayment)
      double remainingAmount = amount;

      final penaltiesResponse = await _supabaseClient
          .from('penalties')
          .select()
          .eq('user_id', userId)
          .inFilter('status', ['unpaid', 'partially_paid'])
          .order('date_incurred', ascending: true);

      final penalties = penaltiesResponse as List;

      for (final penaltyJson in penalties) {
        if (remainingAmount <= 0) break;

        final penaltyId = penaltyJson['id'];
        final penaltyAmount = (penaltyJson['amount'] as num).toDouble();
        final paidAmount = (penaltyJson['paid_amount'] as num).toDouble();
        final penaltyRemaining = penaltyAmount - paidAmount;

        final amountToApply = remainingAmount >= penaltyRemaining
            ? penaltyRemaining
            : remainingAmount;

        await _supabaseClient.from('penalty_payments').insert({
          'payment_id': paymentId,
          'penalty_id': penaltyId,
          'amount_applied': amountToApply,
        });

        final newPaidAmount = paidAmount + amountToApply;
        String newStatus;
        if (newPaidAmount >= penaltyAmount) {
          newStatus = 'paid';
        } else if (newPaidAmount > 0) {
          newStatus = 'partially_paid';
        } else {
          newStatus = 'unpaid';
        }

        await _supabaseClient.from('penalties').update({
          'paid_amount': newPaidAmount,
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', penaltyId);

        remainingAmount -= amountToApply;
      }

      // Log audit trail
      await _logAuditTrail(
        action: 'manual_balance_clear',
        performedBy: clearedBy,
        entityType: 'payment',
        entityId: paymentId,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to clear balance manually: $e');
    }
  }

  // Payment Method Management
  Future<PaymentMethodModel> createPaymentMethod({
    required String name,
    required String displayName,
    required int sortOrder,
  }) async {
    try {
      final response = await _supabaseClient
          .from('payment_methods')
          .insert({
            'name': name,
            'display_name': displayName,
            'sort_order': sortOrder,
            'is_active': true,
          })
          .select()
          .single();

      return PaymentMethodModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create payment method: $e');
    }
  }

  Future<void> updatePaymentMethod({
    required String methodId,
    required String displayName,
    required bool isActive,
    required int sortOrder,
  }) async {
    try {
      await _supabaseClient.from('payment_methods').update({
        'display_name': displayName,
        'is_active': isActive,
        'sort_order': sortOrder,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', methodId);
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  Future<void> deletePaymentMethod(String methodId) async {
    try {
      await _supabaseClient
          .from('payment_methods')
          .delete()
          .eq('id', methodId);
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  /// Log audit trail
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
      print('Warning: Failed to log audit trail: $e');
    }
  }
}
