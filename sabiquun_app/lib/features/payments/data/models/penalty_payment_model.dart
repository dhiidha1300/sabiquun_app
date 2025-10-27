import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/penalty_payment_entity.dart';

part 'penalty_payment_model.freezed.dart';
part 'penalty_payment_model.g.dart';

@freezed
class PenaltyPaymentModel with _$PenaltyPaymentModel {
  const PenaltyPaymentModel._();

  const factory PenaltyPaymentModel({
    required String id,
    @JsonKey(name: 'payment_id') required String paymentId,
    @JsonKey(name: 'penalty_id') required String penaltyId,
    @JsonKey(name: 'amount_applied') required double amountApplied,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PenaltyPaymentModel;

  factory PenaltyPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PenaltyPaymentModelFromJson(json);

  PenaltyPaymentEntity toEntity() {
    return PenaltyPaymentEntity(
      id: id,
      paymentId: paymentId,
      penaltyId: penaltyId,
      amountApplied: amountApplied,
      createdAt: createdAt,
    );
  }
}
