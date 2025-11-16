import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/achievement_tag_entity.dart';

part 'achievement_tag_model.freezed.dart';
part 'achievement_tag_model.g.dart';

@freezed
class AchievementTagModel with _$AchievementTagModel {
  const factory AchievementTagModel({
    required String id,
    required String name,
    String? description,
    required String icon,
    Map<String, dynamic>? criteria,
    required bool autoAssign,
    required int activeUserCount,
    required DateTime createdAt,
  }) = _AchievementTagModel;

  const AchievementTagModel._();

  factory AchievementTagModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementTagModelFromJson(json);

  AchievementTagEntity toEntity() {
    return AchievementTagEntity(
      id: id,
      name: name,
      description: description,
      icon: icon,
      criteria: criteria,
      autoAssign: autoAssign,
      activeUserCount: activeUserCount,
      createdAt: createdAt,
    );
  }
}
