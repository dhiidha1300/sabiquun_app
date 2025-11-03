import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_template_model.freezed.dart';
part 'notification_template_model.g.dart';

@freezed
class NotificationTemplateModel with _$NotificationTemplateModel {
  const factory NotificationTemplateModel({
    required String id,
    @JsonKey(name: 'template_key') required String templateKey,
    required String title,
    required String body,
    @JsonKey(name: 'email_subject') String? emailSubject,
    @JsonKey(name: 'email_body') String? emailBody,
    @JsonKey(name: 'notification_type') required String notificationType,
    @JsonKey(name: 'is_enabled') required bool isEnabled,
    @JsonKey(name: 'is_system_default') required bool isSystemDefault,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _NotificationTemplateModel;

  factory NotificationTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationTemplateModelFromJson(json);
}
