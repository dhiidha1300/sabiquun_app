import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/rest_day_entity.dart';

part 'rest_day_model.freezed.dart';

@freezed
class RestDayModel with _$RestDayModel {
  const factory RestDayModel({
    required String id,
    required DateTime date,
    DateTime? endDate,
    required String description,
    @JsonKey(name: 'is_recurring') required bool isRecurring,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _RestDayModel;

  factory RestDayModel.fromJson(Map<String, dynamic> json) {
    return RestDayModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] ?? json['rest_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      description: json['description'] as String,
      isRecurring: json['is_recurring'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

extension RestDayModelX on RestDayModel {
  RestDayEntity toEntity() {
    return RestDayEntity(
      id: id,
      date: date,
      endDate: endDate,
      description: description,
      isRecurring: isRecurring,
      createdAt: createdAt,
    );
  }
}
