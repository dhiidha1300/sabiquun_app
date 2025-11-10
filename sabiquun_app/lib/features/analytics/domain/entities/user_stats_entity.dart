/// Entity representing user statistics
class UserStatsEntity {
  final String userId;
  final int totalReportsSubmitted;
  final int currentStreak;
  final int longestStreak;
  final int thisMonthReports;
  final int lastMonthReports;
  final int thisYearReports;
  final double completionRate;
  final int totalPenalties;
  final double totalPenaltyAmount;
  final int totalExcuses;
  final int approvedExcuses;
  final int rejectedExcuses;
  final DateTime lastReportDate;
  final DateTime? lastUpdated;

  const UserStatsEntity({
    required this.userId,
    required this.totalReportsSubmitted,
    required this.currentStreak,
    required this.longestStreak,
    required this.thisMonthReports,
    required this.lastMonthReports,
    required this.thisYearReports,
    required this.completionRate,
    required this.totalPenalties,
    required this.totalPenaltyAmount,
    required this.totalExcuses,
    required this.approvedExcuses,
    required this.rejectedExcuses,
    required this.lastReportDate,
    this.lastUpdated,
  });

  bool get hasActiveStreak => currentStreak > 0;
  bool get isNewUser => totalReportsSubmitted < 7;

  String get streakStatus {
    if (currentStreak == 0) return 'No active streak';
    if (currentStreak == 1) return '1 day streak';
    return '$currentStreak days streak';
  }

  String get performanceLevel {
    if (completionRate >= 90) return 'Excellent';
    if (completionRate >= 75) return 'Good';
    if (completionRate >= 50) return 'Fair';
    return 'Needs Improvement';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserStatsEntity &&
        other.userId == userId &&
        other.totalReportsSubmitted == totalReportsSubmitted &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.thisMonthReports == thisMonthReports &&
        other.completionRate == completionRate;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        totalReportsSubmitted.hashCode ^
        currentStreak.hashCode ^
        longestStreak.hashCode ^
        thisMonthReports.hashCode ^
        completionRate.hashCode;
  }
}
