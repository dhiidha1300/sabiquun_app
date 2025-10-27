import 'package:equatable/equatable.dart';
import '../../../../core/constants/penalty_status.dart';

class PenaltyEntity extends Equatable {
  final String id;
  final String userId;
  final String? reportId;
  final double amount;
  final DateTime dateIncurred;
  final PenaltyStatus status;
  final double paidAmount;
  final String? waivedBy;
  final String? waivedReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? missedDeeds;

  const PenaltyEntity({
    required this.id,
    required this.userId,
    this.reportId,
    required this.amount,
    required this.dateIncurred,
    required this.status,
    required this.paidAmount,
    this.waivedBy,
    this.waivedReason,
    required this.createdAt,
    required this.updatedAt,
    this.missedDeeds,
  });

  /// Calculate remaining unpaid amount
  double get remainingAmount => amount - paidAmount;

  /// Check if penalty has outstanding balance
  bool get hasOutstandingBalance => remainingAmount > 0 && !status.isWaived;

  /// Check if penalty is fully paid
  bool get isFullyPaid => paidAmount >= amount || status.isPaid;

  /// Get formatted amount string
  String get formattedAmount => '${amount.toStringAsFixed(0)} Shillings';

  /// Get formatted remaining amount string
  String get formattedRemainingAmount => '${remainingAmount.toStringAsFixed(0)} Shillings';

  /// Get formatted paid amount string
  String get formattedPaidAmount => '${paidAmount.toStringAsFixed(0)} Shillings';

  /// Get payment progress percentage (0-100)
  double get paymentProgress => amount > 0 ? (paidAmount / amount * 100).clamp(0, 100) : 0;

  @override
  List<Object?> get props => [
        id,
        userId,
        reportId,
        amount,
        dateIncurred,
        status,
        paidAmount,
        waivedBy,
        waivedReason,
        createdAt,
        updatedAt,
        missedDeeds,
      ];
}
