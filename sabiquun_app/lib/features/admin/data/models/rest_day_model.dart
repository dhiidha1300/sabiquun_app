import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/rest_day_entity.dart';

part 'rest_day_model.freezed.dart';
part 'rest_day_model.g.dart';

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

  factory RestDayModel.fromJson(Map<String, dynamic> json) =>
      _$RestDayModelFromJson(json);
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
