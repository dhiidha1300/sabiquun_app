// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationScheduleModelImpl _$$NotificationScheduleModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationScheduleModelImpl(
  id: json['id'] as String,
  notificationTemplateId: json['notification_template_id'] as String,
  scheduledTime: json['scheduled_time'] as String,
  frequency: json['frequency'] as String,
  daysOfWeek: (json['days_of_week'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  conditions: json['conditions'] as Map<String, dynamic>?,
  isActive: json['is_active'] as bool,
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$NotificationScheduleModelImplToJson(
  _$NotificationScheduleModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'notification_template_id': instance.notificationTemplateId,
  'scheduled_time': instance.scheduledTime,
  'frequency': instance.frequency,
  'days_of_week': instance.daysOfWeek,
  'conditions': instance.conditions,
  'is_active': instance.isActive,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
