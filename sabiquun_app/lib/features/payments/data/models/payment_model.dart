import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/constants/payment_status.dart';

part 'payment_model.freezed.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const PaymentModel._();

  const factory PaymentModel({
    required String id,
    required String userId,
    required double amount,
    required String paymentMethodId,
    String? referenceNumber,
    String? paymentType,
    required String status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? paymentMethodName,
    String? reviewerName,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethodId: json['payment_method'] as String,
      referenceNumber: json['reference_number'] as String?,
      paymentType: json['payment_type'] as String?,
      status: json['status'] as String,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      paymentMethodName: json['payment_method_name'] as String?,
      reviewerName: json['reviewer_name'] as String?,
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      userId: userId,
      amount: amount,
      paymentMethodId: paymentMethodId,
      referenceNumber: referenceNumber,
      status: PaymentStatus.fromString(status),
      reviewedBy: reviewedBy,
      reviewedAt: reviewedAt,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      paymentMethodName: paymentMethodName,
      reviewerName: reviewerName,
    );
  }
}
