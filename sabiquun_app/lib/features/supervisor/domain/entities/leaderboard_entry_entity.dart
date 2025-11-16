import 'package:equatable/equatable.dart';

/// Leaderboard entry entity
class LeaderboardEntryEntity extends Equatable {
  final int rank;
  final String userId;
  final String fullName;
  final String? profilePhotoUrl;
  final String membershipStatus;
  final double averageDeeds;
  final double complianceRate;
  final List<String> achievementTags;
  final bool hasFajrChampion;
  final int currentStreak;

  const LeaderboardEntryEntity({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.profilePhotoUrl,
    required this.membershipStatus,
    required this.averageDeeds,
    required this.complianceRate,
    required this.achievementTags,
    required this.hasFajrChampion,
    required this.currentStreak,
  });

  @override
  List<Object?> get props => [
        rank,
        userId,
        fullName,
        profilePhotoUrl,
        membershipStatus,
        averageDeeds,
        complianceRate,
        achievementTags,
        hasFajrChampion,
        currentStreak,
      ];
}
