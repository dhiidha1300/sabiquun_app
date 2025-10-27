// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PenaltyModelImpl _$$PenaltyModelImplFromJson(Map<String, dynamic> json) =>
    _$PenaltyModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reportId: json['report_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      dateIncurred: DateTime.parse(json['date_incurred'] as String),
      status: json['status'] as String,
      paidAmount: (json['paid_amount'] as num).toDouble(),
      waivedBy: json['waived_by'] as String?,
      waivedReason: json['waived_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      missedDeeds: (json['missed_deeds'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PenaltyModelImplToJson(_$PenaltyModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'report_id': instance.reportId,
      'amount': instance.amount,
      'date_incurred': instance.dateIncurred.toIso8601String(),
      'status': instance.status,
      'paid_amount': instance.paidAmount,
      'waived_by': instance.waivedBy,
      'waived_reason': instance.waivedReason,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'missed_deeds': instance.missedDeeds,
    };
