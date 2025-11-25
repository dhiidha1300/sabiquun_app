import 'package:equatable/equatable.dart';

/// Supervisor events
abstract class SupervisorEvent extends Equatable {
  const SupervisorEvent();

  @override
  List<Object?> get props => [];
}

/// Load all user reports
class LoadUserReportsRequested extends SupervisorEvent {
  final String? searchQuery;
  final String? membershipStatus;
  final String? complianceFilter;
  final String? reportStatus;
  final String? sortBy;

  const LoadUserReportsRequested({
    this.searchQuery,
    this.membershipStatus,
    this.complianceFilter,
    this.reportStatus,
    this.sortBy,
  });

  @override
  List<Object?> get props => [
        searchQuery,
        membershipStatus,
        complianceFilter,
        reportStatus,
        sortBy,
      ];
}

/// Load leaderboard
class LoadLeaderboardRequested extends SupervisorEvent {
  final String period; // 'daily', 'weekly', 'monthly', 'all-time'
  final int limit;

  const LoadLeaderboardRequested({
    required this.period,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [period, limit];
}

/// Load users at risk
class LoadUsersAtRiskRequested extends SupervisorEvent {
  final double balanceThreshold;

  const LoadUsersAtRiskRequested({
    this.balanceThreshold = 100000,
  });

  @override
  List<Object?> get props => [balanceThreshold];
}

/// Load user detail
class LoadUserDetailRequested extends SupervisorEvent {
  final String userId;

  const LoadUserDetailRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Load achievement tags
class LoadAchievementTagsRequested extends SupervisorEvent {
  const LoadAchievementTagsRequested();
}

/// Assign achievement tag
class AssignAchievementTagRequested extends SupervisorEvent {
  final String tagId;
  final String userId;

  const AssignAchievementTagRequested({
    required this.tagId,
    required this.userId,
  });

  @override
  List<Object?> get props => [tagId, userId];
}

/// Remove achievement tag
class RemoveAchievementTagRequested extends SupervisorEvent {
  final String tagId;
  final String userId;

  const RemoveAchievementTagRequested({
    required this.tagId,
    required this.userId,
  });

  @override
  List<Object?> get props => [tagId, userId];
}

/// Create achievement tag
class CreateAchievementTagRequested extends SupervisorEvent {
  final String name;
  final String? description;
  final String icon;
  final Map<String, dynamic>? criteria;
  final bool autoAssign;

  const CreateAchievementTagRequested({
    required this.name,
    this.description,
    required this.icon,
    this.criteria,
    required this.autoAssign,
  });

  @override
  List<Object?> get props => [name, description, icon, criteria, autoAssign];
}

/// Update achievement tag
class UpdateAchievementTagRequested extends SupervisorEvent {
  final String tagId;
  final String? name;
  final String? description;
  final String? icon;
  final Map<String, dynamic>? criteria;
  final bool? autoAssign;

  const UpdateAchievementTagRequested({
    required this.tagId,
    this.name,
    this.description,
    this.icon,
    this.criteria,
    this.autoAssign,
  });

  @override
  List<Object?> get props => [tagId, name, description, icon, criteria, autoAssign];
}

/// Delete achievement tag
class DeleteAchievementTagRequested extends SupervisorEvent {
  final String tagId;

  const DeleteAchievementTagRequested({required this.tagId});

  @override
  List<Object?> get props => [tagId];
}

/// Load detailed user report with date range
class LoadDetailedUserReportRequested extends SupervisorEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadDetailedUserReportRequested({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Export user report
class ExportUserReportRequested extends SupervisorEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String format; // 'pdf' or 'excel'

  const ExportUserReportRequested({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.format,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate, format];
}

/// Load daily deeds for date range
class LoadDailyDeedsRequested extends SupervisorEvent {
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? userIds;

  const LoadDailyDeedsRequested({
    required this.startDate,
    required this.endDate,
    this.userIds,
  });

  @override
  List<Object?> get props => [startDate, endDate, userIds];
}
