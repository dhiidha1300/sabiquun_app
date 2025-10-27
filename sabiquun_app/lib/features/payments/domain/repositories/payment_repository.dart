import '../entities/payment_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/penalty_payment_entity.dart';

abstract class PaymentRepository {
  /// Get all active payment methods
  Future<List<PaymentMethodEntity>> getPaymentMethods();

  /// Submit a new payment
  Future<PaymentEntity> submitPayment({
    required String userId,
    required double amount,
    required String paymentMethodId,
    String? referenceNumber,
  });

  /// Get payment history for a user
  Future<List<PaymentEntity>> getPaymentHistory({
    required String userId,
    String? status,
  });

  /// Get a specific payment by ID
  Future<PaymentEntity> getPaymentById(String paymentId);

  /// Get all pending payments (Admin/Cashier)
  Future<List<PaymentEntity>> getPendingPayments();

  /// Approve a payment and apply it to penalties using FIFO
  Future<void> approvePayment({
    required String paymentId,
    required String reviewedBy,
  });

  /// Reject a payment
  Future<void> rejectPayment({
    required String paymentId,
    required String reviewedBy,
    required String reason,
  });

  /// Get penalty payment links for a payment
  Future<List<PenaltyPaymentEntity>> getPenaltyPayments(String paymentId);

  /// Manual balance clearing (Admin/Cashier)
  Future<void> manualBalanceClear({
    required String userId,
    required double amount,
    required String reason,
    required String clearedBy,
  });

  // Payment Method Management (Admin only)
  Future<PaymentMethodEntity> createPaymentMethod({
    required String name,
    required String displayName,
    required int sortOrder,
  });

  Future<void> updatePaymentMethod({
    required String methodId,
    required String displayName,
    required bool isActive,
    required int sortOrder,
  });

  Future<void> deletePaymentMethod(String methodId);
}
