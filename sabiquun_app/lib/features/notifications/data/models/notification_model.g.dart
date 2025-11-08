// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  notificationTemplateId: json['notification_template_id'] as String?,
  title: json['title'] as String,
  body: json['body'] as String,
  notificationType: json['notification_type'] as String,
  isRead: json['is_read'] as bool,
  sentAt: DateTime.parse(json['sent_at'] as String),
  readAt: json['read_at'] == null
      ? null
      : DateTime.parse(json['read_at'] as String),
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'notification_template_id': instance.notificationTemplateId,
  'title': instance.title,
  'body': instance.body,
  'notification_type': instance.notificationType,
  'is_read': instance.isRead,
  'sent_at': instance.sentAt.toIso8601String(),
  'read_at': instance.readAt?.toIso8601String(),
  'data': instance.data,
};
