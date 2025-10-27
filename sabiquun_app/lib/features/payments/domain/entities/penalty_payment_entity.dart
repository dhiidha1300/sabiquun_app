import 'package:equatable/equatable.dart';

/// Represents the link between a payment and penalties it was applied to (FIFO)
class PenaltyPaymentEntity extends Equatable {
  final String id;
  final String paymentId;
  final String penaltyId;
  final double amountApplied;
  final DateTime createdAt;

  const PenaltyPaymentEntity({
    required this.id,
    required this.paymentId,
    required this.penaltyId,
    required this.amountApplied,
    required this.createdAt,
  });

  /// Get formatted amount string
  String get formattedAmount => '${amountApplied.toStringAsFixed(0)} Shillings';

  @override
  List<Object?> get props => [
        id,
        paymentId,
        penaltyId,
        amountApplied,
        createdAt,
      ];
}
