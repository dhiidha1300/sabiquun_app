import 'package:equatable/equatable.dart';

/// Entity representing comprehensive system analytics
class AnalyticsEntity extends Equatable {
  final UserMetrics userMetrics;
  final DeedMetrics deedMetrics;
  final FinancialMetrics financialMetrics;
  final EngagementMetrics engagementMetrics;
  final ExcuseMetrics excuseMetrics;

  const AnalyticsEntity({
    required this.userMetrics,
    required this.deedMetrics,
    required this.financialMetrics,
    required this.engagementMetrics,
    required this.excuseMetrics,
  });

  @override
  List<Object?> get props => [
        userMetrics,
        deedMetrics,
        financialMetrics,
        engagementMetrics,
        excuseMetrics,
      ];
}

/// User-related metrics
class UserMetrics extends Equatable {
  final int pendingUsers;
  final int activeUsers;
  final int suspendedUsers;
  final int deactivatedUsers;
  final int newMembers;
  final int exclusiveMembers;
  final int legacyMembers;
  final int usersAtRisk; // Balance > 400k
  final int newRegistrationsThisWeek;

  const UserMetrics({
    required this.pendingUsers,
    required this.activeUsers,
    required this.suspendedUsers,
    required this.deactivatedUsers,
    required this.newMembers,
    required this.exclusiveMembers,
    required this.legacyMembers,
    required this.usersAtRisk,
    required this.newRegistrationsThisWeek,
  });

  int get totalUsers =>
      pendingUsers + activeUsers + suspendedUsers + deactivatedUsers;

  @override
  List<Object?> get props => [
        pendingUsers,
        activeUsers,
        suspendedUsers,
        deactivatedUsers,
        newMembers,
        exclusiveMembers,
        legacyMembers,
        usersAtRisk,
        newRegistrationsThisWeek,
      ];
}

/// Deed-related metrics
class DeedMetrics extends Equatable {
  final int totalDeedsToday;
  final int totalDeedsWeek;
  final int totalDeedsMonth;
  final int totalDeedsAllTime;
  final double averagePerUserToday;
  final double averagePerUserWeek;
  final double averagePerUserMonth;
  final double complianceRateToday;
  final double complianceRateWeek;
  final double complianceRateMonth;
  final int usersCompletedToday;
  final int totalActiveUsers;
  final double faraidComplianceRate;
  final double sunnahComplianceRate;
  final List<TopPerformer> topPerformers;
  final List<UserNeedingAttention> usersNeedingAttention;
  final Map<String, double> deedComplianceByType; // deed_name -> completion %

  const DeedMetrics({
    required this.totalDeedsToday,
    required this.totalDeedsWeek,
    required this.totalDeedsMonth,
    required this.totalDeedsAllTime,
    required this.averagePerUserToday,
    required this.averagePerUserWeek,
    required this.averagePerUserMonth,
    required this.complianceRateToday,
    required this.complianceRateWeek,
    required this.complianceRateMonth,
    required this.usersCompletedToday,
    required this.totalActiveUsers,
    required this.faraidComplianceRate,
    required this.sunnahComplianceRate,
    required this.topPerformers,
    required this.usersNeedingAttention,
    required this.deedComplianceByType,
  });

  String get formattedComplianceRateToday =>
      '${(complianceRateToday * 100).toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        totalDeedsToday,
        totalDeedsWeek,
        totalDeedsMonth,
        totalDeedsAllTime,
        averagePerUserToday,
        averagePerUserWeek,
        averagePerUserMonth,
        complianceRateToday,
        complianceRateWeek,
        complianceRateMonth,
        usersCompletedToday,
        totalActiveUsers,
        faraidComplianceRate,
        sunnahComplianceRate,
        topPerformers,
        usersNeedingAttention,
        deedComplianceByType,
      ];
}

class TopPerformer extends Equatable {
  final String userId;
  final String userName;
  final double averageDeeds;

  const TopPerformer({
    required this.userId,
    required this.userName,
    required this.averageDeeds,
  });

  @override
  List<Object?> get props => [userId, userName, averageDeeds];
}

class UserNeedingAttention extends Equatable {
  final String userId;
  final String userName;
  final double averageDeeds;

  const UserNeedingAttention({
    required this.userId,
    required this.userName,
    required this.averageDeeds,
  });

  @override
  List<Object?> get props => [userId, userName, averageDeeds];
}

/// Financial metrics
class FinancialMetrics extends Equatable {
  final double penaltiesIncurredThisMonth;
  final double penaltiesIncurredAllTime;
  final double paymentsReceivedThisMonth;
  final double paymentsReceivedAllTime;
  final double outstandingBalance;
  final int pendingPaymentsCount;
  final double pendingPaymentsAmount;

  const FinancialMetrics({
    required this.penaltiesIncurredThisMonth,
    required this.penaltiesIncurredAllTime,
    required this.paymentsReceivedThisMonth,
    required this.paymentsReceivedAllTime,
    required this.outstandingBalance,
    required this.pendingPaymentsCount,
    required this.pendingPaymentsAmount,
  });

  String get formattedOutstandingBalance =>
      '${outstandingBalance.toStringAsFixed(0)} Shillings';

  @override
  List<Object?> get props => [
        penaltiesIncurredThisMonth,
        penaltiesIncurredAllTime,
        paymentsReceivedThisMonth,
        paymentsReceivedAllTime,
        outstandingBalance,
        pendingPaymentsCount,
        pendingPaymentsAmount,
      ];
}

/// Engagement metrics
class EngagementMetrics extends Equatable {
  final int dailyActiveUsers;
  final int totalActiveUsers;
  final double reportSubmissionRate;
  final String averageSubmissionTime;
  final double notificationOpenRate;
  final int averageResponseTimeMinutes;

  const EngagementMetrics({
    required this.dailyActiveUsers,
    required this.totalActiveUsers,
    required this.reportSubmissionRate,
    required this.averageSubmissionTime,
    required this.notificationOpenRate,
    required this.averageResponseTimeMinutes,
  });

  String get dauPercentage =>
      '${((dailyActiveUsers / totalActiveUsers) * 100).toStringAsFixed(0)}%';

  String get formattedReportSubmissionRate =>
      '${(reportSubmissionRate * 100).toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [
        dailyActiveUsers,
        totalActiveUsers,
        reportSubmissionRate,
        averageSubmissionTime,
        notificationOpenRate,
        averageResponseTimeMinutes,
      ];
}

/// Excuse metrics
class ExcuseMetrics extends Equatable {
  final int pendingExcuses;
  final double approvalRate;
  final Map<String, int> excusesByReason; // reason -> count

  const ExcuseMetrics({
    required this.pendingExcuses,
    required this.approvalRate,
    required this.excusesByReason,
  });

  String? get mostCommonReason {
    if (excusesByReason.isEmpty) return null;
    final sorted = excusesByReason.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  int? get mostCommonReasonCount {
    if (excusesByReason.isEmpty) return null;
    final sorted = excusesByReason.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.value;
  }

  @override
  List<Object?> get props => [
        pendingExcuses,
        approvalRate,
        excusesByReason,
      ];
}
