// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationTemplateModelImpl _$$NotificationTemplateModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationTemplateModelImpl(
  id: json['id'] as String,
  templateKey: json['template_key'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  emailSubject: json['email_subject'] as String?,
  emailBody: json['email_body'] as String?,
  notificationType: json['notification_type'] as String,
  isEnabled: json['is_enabled'] as bool,
  isSystemDefault: json['is_system_default'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$NotificationTemplateModelImplToJson(
  _$NotificationTemplateModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'template_key': instance.templateKey,
  'title': instance.title,
  'body': instance.body,
  'email_subject': instance.emailSubject,
  'email_body': instance.emailBody,
  'notification_type': instance.notificationType,
  'is_enabled': instance.isEnabled,
  'is_system_default': instance.isSystemDefault,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
