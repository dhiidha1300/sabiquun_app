// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty_balance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PenaltyBalanceModelImpl _$$PenaltyBalanceModelImplFromJson(
  Map<String, dynamic> json,
) => _$PenaltyBalanceModelImpl(
  balance: (json['balance'] as num).toDouble(),
  unpaidPenaltiesCount: (json['unpaid_penalties_count'] as num).toInt(),
  oldestPenaltyDate: json['oldest_penalty_date'] == null
      ? null
      : DateTime.parse(json['oldest_penalty_date'] as String),
  approachingDeactivation: json['approaching_deactivation'] as bool,
  deactivationThreshold: (json['deactivation_threshold'] as num).toDouble(),
  firstWarningThreshold: (json['first_warning_threshold'] as num?)?.toDouble(),
  finalWarningThreshold: (json['final_warning_threshold'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$PenaltyBalanceModelImplToJson(
  _$PenaltyBalanceModelImpl instance,
) => <String, dynamic>{
  'balance': instance.balance,
  'unpaid_penalties_count': instance.unpaidPenaltiesCount,
  'oldest_penalty_date': instance.oldestPenaltyDate?.toIso8601String(),
  'approaching_deactivation': instance.approachingDeactivation,
  'deactivation_threshold': instance.deactivationThreshold,
  'first_warning_threshold': instance.firstWarningThreshold,
  'final_warning_threshold': instance.finalWarningThreshold,
};
