// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementTagModelImpl _$$AchievementTagModelImplFromJson(
  Map<String, dynamic> json,
) => _$AchievementTagModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  icon: json['icon'] as String,
  criteria: json['criteria'] as Map<String, dynamic>?,
  autoAssign: json['autoAssign'] as bool,
  activeUserCount: (json['activeUserCount'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AchievementTagModelImplToJson(
  _$AchievementTagModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'icon': instance.icon,
  'criteria': instance.criteria,
  'autoAssign': instance.autoAssign,
  'activeUserCount': instance.activeUserCount,
  'createdAt': instance.createdAt.toIso8601String(),
};
