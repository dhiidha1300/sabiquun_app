// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardEntryModelImpl _$$LeaderboardEntryModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardEntryModelImpl(
  rank: (json['rank'] as num).toInt(),
  userId: json['userId'] as String,
  fullName: json['fullName'] as String,
  profilePhotoUrl: json['profilePhotoUrl'] as String?,
  membershipStatus: json['membershipStatus'] as String,
  averageDeeds: (json['averageDeeds'] as num).toDouble(),
  complianceRate: (json['complianceRate'] as num).toDouble(),
  achievementTags: (json['achievementTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  hasFajrChampion: json['hasFajrChampion'] as bool,
  currentStreak: (json['currentStreak'] as num).toInt(),
);

Map<String, dynamic> _$$LeaderboardEntryModelImplToJson(
  _$LeaderboardEntryModelImpl instance,
) => <String, dynamic>{
  'rank': instance.rank,
  'userId': instance.userId,
  'fullName': instance.fullName,
  'profilePhotoUrl': instance.profilePhotoUrl,
  'membershipStatus': instance.membershipStatus,
  'averageDeeds': instance.averageDeeds,
  'complianceRate': instance.complianceRate,
  'achievementTags': instance.achievementTags,
  'hasFajrChampion': instance.hasFajrChampion,
  'currentStreak': instance.currentStreak,
};
