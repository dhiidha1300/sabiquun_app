import 'package:equatable/equatable.dart';
import '../../../penalties/domain/entities/penalty_entity.dart';

/// Represents a single penalty payment application in FIFO order
class PenaltyPaymentApplication extends Equatable {
  final PenaltyEntity penalty;
  final double amountApplied;
  final double remainingAfter;

  const PenaltyPaymentApplication({
    required this.penalty,
    required this.amountApplied,
    required this.remainingAfter,
  });

  /// Check if this penalty is fully paid by this application
  bool get isFullyPaid => remainingAfter <= 0;

  /// Get formatted amount applied
  String get formattedAmountApplied =>
      '${amountApplied.toStringAsFixed(0)} Shillings';

  /// Get formatted remaining amount
  String get formattedRemainingAfter =>
      '${remainingAfter.toStringAsFixed(0)} Shillings';

  @override
  List<Object?> get props => [penalty, amountApplied, remainingAfter];
}

/// Represents the complete FIFO payment distribution
class FifoPaymentDistribution extends Equatable {
  final double paymentAmount;
  final double currentBalance;
  final List<PenaltyPaymentApplication> applications;
  final double remainingPaymentAmount;

  const FifoPaymentDistribution({
    required this.paymentAmount,
    required this.currentBalance,
    required this.applications,
    required this.remainingPaymentAmount,
  });

  /// Calculate new balance after payment
  double get newBalance => currentBalance - (paymentAmount - remainingPaymentAmount);

  /// Get formatted new balance
  String get formattedNewBalance => '${newBalance.toStringAsFixed(0)} Shillings';

  /// Get formatted current balance
  String get formattedCurrentBalance =>
      '${currentBalance.toStringAsFixed(0)} Shillings';

  /// Get formatted payment amount
  String get formattedPaymentAmount =>
      '${paymentAmount.toStringAsFixed(0)} Shillings';

  /// Get total amount actually applied
  double get totalApplied => paymentAmount - remainingPaymentAmount;

  /// Get formatted total applied
  String get formattedTotalApplied =>
      '${totalApplied.toStringAsFixed(0)} Shillings';

  /// Check if payment fully covers all penalties
  bool get coversAllPenalties => remainingPaymentAmount > 0;

  @override
  List<Object?> get props => [
        paymentAmount,
        currentBalance,
        applications,
        remainingPaymentAmount,
      ];

  /// Calculate FIFO distribution for a payment
  static FifoPaymentDistribution calculate({
    required double paymentAmount,
    required double currentBalance,
    required List<PenaltyEntity> unpaidPenalties,
  }) {
    double remainingPayment = paymentAmount;
    final List<PenaltyPaymentApplication> applications = [];

    // Sort penalties by date (FIFO - oldest first)
    final sortedPenalties = List<PenaltyEntity>.from(unpaidPenalties)
      ..sort((a, b) => a.dateIncurred.compareTo(b.dateIncurred));

    for (final penalty in sortedPenalties) {
      if (remainingPayment <= 0) {
        break;
      }

      final unpaidAmount = penalty.remainingAmount;
      if (unpaidAmount <= 0) {
        continue; // Skip if already fully paid
      }

      final amountToApply = remainingPayment >= unpaidAmount
          ? unpaidAmount
          : remainingPayment;

      final remainingAfterApplication = unpaidAmount - amountToApply;

      applications.add(PenaltyPaymentApplication(
        penalty: penalty,
        amountApplied: amountToApply,
        remainingAfter: remainingAfterApplication,
      ));

      remainingPayment -= amountToApply;
    }

    return FifoPaymentDistribution(
      paymentAmount: paymentAmount,
      currentBalance: currentBalance,
      applications: applications,
      remainingPaymentAmount: remainingPayment,
    );
  }
}
