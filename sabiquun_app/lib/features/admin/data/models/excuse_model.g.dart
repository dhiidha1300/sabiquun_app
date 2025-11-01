// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'excuse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExcuseModelImpl _$$ExcuseModelImplFromJson(Map<String, dynamic> json) =>
    _$ExcuseModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      reportDate: DateTime.parse(json['report_date'] as String),
      excuseType: json['excuse_type'] as String,
      description: json['description'] as String?,
      affectedDeeds: json['affected_deeds'] as Map<String, dynamic>,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedBy: json['reviewed_by'] as String?,
      reviewerName: json['reviewer_name'] as String?,
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at'] as String),
      rejectionReason: json['rejection_reason'] as String?,
    );

Map<String, dynamic> _$$ExcuseModelImplToJson(_$ExcuseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'user_name': instance.userName,
      'report_date': instance.reportDate.toIso8601String(),
      'excuse_type': instance.excuseType,
      'description': instance.description,
      'affected_deeds': instance.affectedDeeds,
      'status': instance.status,
      'submitted_at': instance.submittedAt.toIso8601String(),
      'reviewed_by': instance.reviewedBy,
      'reviewer_name': instance.reviewerName,
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'rejection_reason': instance.rejectionReason,
    };
