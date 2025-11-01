import 'package:equatable/equatable.dart';
import '../../../../core/constants/payment_status.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String paymentMethodId;
  final String? referenceNumber;
  final PaymentStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined data (optional)
  final String? paymentMethodName;
  final String? reviewerName;
  final String? userName;
  final String? userEmail;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentMethodId,
    this.referenceNumber,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
    this.paymentMethodName,
    this.reviewerName,
    this.userName,
    this.userEmail,
  });

  /// Get formatted amount string
  String get formattedAmount => '${amount.toStringAsFixed(0)} Shillings';

  /// Check if payment can be cancelled (only pending payments)
  bool get canBeCancelled => status.isPending;

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        paymentMethodId,
        referenceNumber,
        status,
        reviewedBy,
        reviewedAt,
        rejectionReason,
        createdAt,
        updatedAt,
        paymentMethodName,
        reviewerName,
        userName,
        userEmail,
      ];
}
