import 'package:sabiquun_app/features/analytics/domain/entities/user_stats_entity.dart';

class UserStatsModel extends UserStatsEntity {
  const UserStatsModel({
    required super.userId,
    required super.totalReportsSubmitted,
    required super.currentStreak,
    required super.longestStreak,
    required super.thisMonthReports,
    required super.lastMonthReports,
    required super.thisYearReports,
    required super.completionRate,
    required super.totalPenalties,
    required super.totalPenaltyAmount,
    required super.totalExcuses,
    required super.approvedExcuses,
    required super.rejectedExcuses,
    required super.lastReportDate,
    super.lastUpdated,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['user_id'] as String,
      totalReportsSubmitted: (json['total_reports_submitted'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      thisMonthReports: (json['this_month_reports'] as num?)?.toInt() ?? 0,
      lastMonthReports: (json['last_month_reports'] as num?)?.toInt() ?? 0,
      thisYearReports: (json['this_year_reports'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      totalPenalties: (json['total_penalties'] as num?)?.toInt() ?? 0,
      totalPenaltyAmount: (json['total_penalty_amount'] as num?)?.toDouble() ?? 0.0,
      totalExcuses: (json['total_excuses'] as num?)?.toInt() ?? 0,
      approvedExcuses: (json['approved_excuses'] as num?)?.toInt() ?? 0,
      rejectedExcuses: (json['rejected_excuses'] as num?)?.toInt() ?? 0,
      lastReportDate: DateTime.parse(json['last_report_date'] as String),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_reports_submitted': totalReportsSubmitted,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'this_month_reports': thisMonthReports,
      'last_month_reports': lastMonthReports,
      'this_year_reports': thisYearReports,
      'completion_rate': completionRate,
      'total_penalties': totalPenalties,
      'total_penalty_amount': totalPenaltyAmount,
      'total_excuses': totalExcuses,
      'approved_excuses': approvedExcuses,
      'rejected_excuses': rejectedExcuses,
      'last_report_date': lastReportDate.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  UserStatsEntity toEntity() {
    return UserStatsEntity(
      userId: userId,
      totalReportsSubmitted: totalReportsSubmitted,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      thisMonthReports: thisMonthReports,
      lastMonthReports: lastMonthReports,
      thisYearReports: thisYearReports,
      completionRate: completionRate,
      totalPenalties: totalPenalties,
      totalPenaltyAmount: totalPenaltyAmount,
      totalExcuses: totalExcuses,
      approvedExcuses: approvedExcuses,
      rejectedExcuses: rejectedExcuses,
      lastReportDate: lastReportDate,
      lastUpdated: lastUpdated,
    );
  }
}
