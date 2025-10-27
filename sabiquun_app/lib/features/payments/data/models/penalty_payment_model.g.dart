// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PenaltyPaymentModelImpl _$$PenaltyPaymentModelImplFromJson(
  Map<String, dynamic> json,
) => _$PenaltyPaymentModelImpl(
  id: json['id'] as String,
  paymentId: json['payment_id'] as String,
  penaltyId: json['penalty_id'] as String,
  amountApplied: (json['amount_applied'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$PenaltyPaymentModelImplToJson(
  _$PenaltyPaymentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'payment_id': instance.paymentId,
  'penalty_id': instance.penaltyId,
  'amount_applied': instance.amountApplied,
  'created_at': instance.createdAt.toIso8601String(),
};
