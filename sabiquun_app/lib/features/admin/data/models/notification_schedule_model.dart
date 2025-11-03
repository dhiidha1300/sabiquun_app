import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_schedule_model.freezed.dart';
part 'notification_schedule_model.g.dart';

@freezed
class NotificationScheduleModel with _$NotificationScheduleModel {
  const factory NotificationScheduleModel({
    required String id,
    @JsonKey(name: 'notification_template_id') required String notificationTemplateId,
    @JsonKey(name: 'scheduled_time') required String scheduledTime,
    required String frequency,
    @JsonKey(name: 'days_of_week') List<int>? daysOfWeek,
    Map<String, dynamic>? conditions,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _NotificationScheduleModel;

  factory NotificationScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationScheduleModelFromJson(json);
}
