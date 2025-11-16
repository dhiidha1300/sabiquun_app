import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';

part 'leaderboard_entry_model.freezed.dart';
part 'leaderboard_entry_model.g.dart';

@freezed
class LeaderboardEntryModel with _$LeaderboardEntryModel {
  const factory LeaderboardEntryModel({
    required int rank,
    required String userId,
    required String fullName,
    String? profilePhotoUrl,
    required String membershipStatus,
    required double averageDeeds,
    required double complianceRate,
    required List<String> achievementTags,
    required bool hasFajrChampion,
    required int currentStreak,
  }) = _LeaderboardEntryModel;

  const LeaderboardEntryModel._();

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryModelFromJson(json);

  LeaderboardEntryEntity toEntity() {
    return LeaderboardEntryEntity(
      rank: rank,
      userId: userId,
      fullName: fullName,
      profilePhotoUrl: profilePhotoUrl,
      membershipStatus: membershipStatus,
      averageDeeds: averageDeeds,
      complianceRate: complianceRate,
      achievementTags: achievementTags,
      hasFajrChampion: hasFajrChampion,
      currentStreak: currentStreak,
    );
  }
}
