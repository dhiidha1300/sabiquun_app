import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sabiquun_app/features/notifications/domain/entities/notification_entity.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'notification_template_id') String? notificationTemplateId,
    required String title,
    required String body,
    @JsonKey(name: 'notification_type') required String notificationType,
    @JsonKey(name: 'is_read') required bool isRead,
    @JsonKey(name: 'sent_at') required DateTime sentAt,
    @JsonKey(name: 'read_at') DateTime? readAt,
    Map<String, dynamic>? data,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Convert to domain entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      notificationTemplateId: notificationTemplateId,
      title: title,
      body: body,
      notificationType: notificationType,
      isRead: isRead,
      sentAt: sentAt,
      readAt: readAt,
      data: data,
    );
  }

  /// Create from domain entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      notificationTemplateId: entity.notificationTemplateId,
      title: entity.title,
      body: entity.body,
      notificationType: entity.notificationType,
      isRead: entity.isRead,
      sentAt: entity.sentAt,
      readAt: entity.readAt,
      data: entity.data,
    );
  }
}
