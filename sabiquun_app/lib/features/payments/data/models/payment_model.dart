import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/constants/payment_status.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const PaymentModel._();

  const factory PaymentModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required double amount,
    @JsonKey(name: 'payment_method_id') required String paymentMethodId,
    @JsonKey(name: 'reference_number') String? referenceNumber,
    required String status,
    @JsonKey(name: 'reviewed_by') String? reviewedBy,
    @JsonKey(name: 'reviewed_at') DateTime? reviewedAt,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'payment_method_name') String? paymentMethodName,
    @JsonKey(name: 'reviewer_name') String? reviewerName,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

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
