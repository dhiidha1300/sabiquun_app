import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Load payment methods
class LoadPaymentMethodsRequested extends PaymentEvent {
  const LoadPaymentMethodsRequested();
}

/// Submit a new payment
class SubmitPaymentRequested extends PaymentEvent {
  final String userId;
  final double amount;
  final String paymentMethodId;
  final String paymentType; // 'full' or 'partial'
  final String? referenceNumber;

  const SubmitPaymentRequested({
    required this.userId,
    required this.amount,
    required this.paymentMethodId,
    required this.paymentType,
    this.referenceNumber,
  });

  @override
  List<Object?> get props => [userId, amount, paymentMethodId, paymentType, referenceNumber];
}

/// Load payment history
class LoadPaymentHistoryRequested extends PaymentEvent {
  final String userId;
  final String? statusFilter;

  const LoadPaymentHistoryRequested({
    required this.userId,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [userId, statusFilter];
}

/// Load recent approved payments (Cashier/Admin)
class LoadRecentApprovedPaymentsRequested extends PaymentEvent {
  final int limit;

  const LoadRecentApprovedPaymentsRequested({this.limit = 5});

  @override
  List<Object?> get props => [limit];
}

/// Load pending payments (Admin/Cashier)
class LoadPendingPaymentsRequested extends PaymentEvent {
  const LoadPendingPaymentsRequested();
}

/// Approve a payment
class ApprovePaymentRequested extends PaymentEvent {
  final String paymentId;
  final String reviewedBy;

  const ApprovePaymentRequested({
    required this.paymentId,
    required this.reviewedBy,
  });

  @override
  List<Object?> get props => [paymentId, reviewedBy];
}

/// Reject a payment
class RejectPaymentRequested extends PaymentEvent {
  final String paymentId;
  final String reviewedBy;
  final String reason;

  const RejectPaymentRequested({
    required this.paymentId,
    required this.reviewedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [paymentId, reviewedBy, reason];
}

/// Load penalty payments for a payment
class LoadPenaltyPaymentsRequested extends PaymentEvent {
  final String paymentId;

  const LoadPenaltyPaymentsRequested(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

/// Manual balance clear
class ManualBalanceClearRequested extends PaymentEvent {
  final String userId;
  final double amount;
  final String reason;
  final String clearedBy;

  const ManualBalanceClearRequested({
    required this.userId,
    required this.amount,
    required this.reason,
    required this.clearedBy,
  });

  @override
  List<Object?> get props => [userId, amount, reason, clearedBy];
}

/// Reset payment state
class ResetPaymentStateRequested extends PaymentEvent {
  const ResetPaymentStateRequested();
}
