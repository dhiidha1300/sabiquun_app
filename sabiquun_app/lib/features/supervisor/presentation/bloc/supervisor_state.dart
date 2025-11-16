import 'package:equatable/equatable.dart';
import '../../domain/entities/user_report_summary_entity.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/entities/achievement_tag_entity.dart';
import '../../domain/entities/user_detail_entity.dart';

/// Supervisor states
abstract class SupervisorState extends Equatable {
  const SupervisorState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SupervisorInitial extends SupervisorState {
  const SupervisorInitial();
}

/// Loading state
class SupervisorLoading extends SupervisorState {
  const SupervisorLoading();
}

/// User reports loaded
class UserReportsLoaded extends SupervisorState {
  final List<UserReportSummaryEntity> userReports;

  const UserReportsLoaded({required this.userReports});

  @override
  List<Object?> get props => [userReports];
}

/// Leaderboard loaded
class LeaderboardLoaded extends SupervisorState {
  final List<LeaderboardEntryEntity> leaderboard;
  final String period;

  const LeaderboardLoaded({
    required this.leaderboard,
    required this.period,
  });

  @override
  List<Object?> get props => [leaderboard, period];
}

/// Users at risk loaded
class UsersAtRiskLoaded extends SupervisorState {
  final List<UserReportSummaryEntity> usersAtRisk;

  const UsersAtRiskLoaded({required this.usersAtRisk});

  @override
  List<Object?> get props => [usersAtRisk];
}

/// User detail loaded
class UserDetailLoaded extends SupervisorState {
  final UserDetailEntity userDetail;

  const UserDetailLoaded({required this.userDetail});

  @override
  List<Object?> get props => [userDetail];
}

/// Achievement tags loaded
class AchievementTagsLoaded extends SupervisorState {
  final List<AchievementTagEntity> tags;

  const AchievementTagsLoaded({required this.tags});

  @override
  List<Object?> get props => [tags];
}

/// Achievement tag assigned
class AchievementTagAssigned extends SupervisorState {
  final String message;

  const AchievementTagAssigned({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Achievement tag removed
class AchievementTagRemoved extends SupervisorState {
  final String message;

  const AchievementTagRemoved({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Achievement tag created
class AchievementTagCreated extends SupervisorState {
  final AchievementTagEntity tag;

  const AchievementTagCreated({required this.tag});

  @override
  List<Object?> get props => [tag];
}

/// Achievement tag updated
class AchievementTagUpdated extends SupervisorState {
  final AchievementTagEntity tag;

  const AchievementTagUpdated({required this.tag});

  @override
  List<Object?> get props => [tag];
}

/// Achievement tag deleted
class AchievementTagDeleted extends SupervisorState {
  final String message;

  const AchievementTagDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state
class SupervisorError extends SupervisorState {
  final String message;

  const SupervisorError({required this.message});

  @override
  List<Object?> get props => [message];
}
