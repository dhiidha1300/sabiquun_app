import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/penalty_payment_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Loading state
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// Payment methods loaded
class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodEntity> methods;

  const PaymentMethodsLoaded(this.methods);

  @override
  List<Object?> get props => [methods];
}

/// Payment submitted successfully
class PaymentSubmitted extends PaymentState {
  final PaymentEntity payment;

  const PaymentSubmitted(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Payment history loaded
class PaymentHistoryLoaded extends PaymentState {
  final List<PaymentEntity> payments;
  final String? appliedFilter;

  const PaymentHistoryLoaded({
    required this.payments,
    this.appliedFilter,
  });

  @override
  List<Object?> get props => [payments, appliedFilter];
}

/// Pending payments loaded (Admin/Cashier)
class PendingPaymentsLoaded extends PaymentState {
  final List<PaymentEntity> payments;

  const PendingPaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

/// Recent approved payments loaded (Cashier/Admin)
class RecentApprovedPaymentsLoaded extends PaymentState {
  final List<PaymentEntity> payments;

  const RecentApprovedPaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

/// All reviewed payments loaded (approved/rejected) for Admin/Cashier
class AllReviewedPaymentsLoaded extends PaymentState {
  final List<PaymentEntity> payments;

  const AllReviewedPaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

/// Payment approved successfully
class PaymentApproved extends PaymentState {
  final String paymentId;

  const PaymentApproved(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

/// Payment rejected successfully
class PaymentRejected extends PaymentState {
  final String paymentId;

  const PaymentRejected(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

/// Penalty payments loaded
class PenaltyPaymentsLoaded extends PaymentState {
  final List<PenaltyPaymentEntity> penaltyPayments;

  const PenaltyPaymentsLoaded(this.penaltyPayments);

  @override
  List<Object?> get props => [penaltyPayments];
}

/// Balance cleared manually
class BalanceCleared extends PaymentState {
  final String userId;
  final double amount;

  const BalanceCleared({
    required this.userId,
    required this.amount,
  });

  @override
  List<Object?> get props => [userId, amount];
}

/// Error state
class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
