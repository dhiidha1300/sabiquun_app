import 'package:equatable/equatable.dart';

/// User report summary for supervisor dashboard
class UserReportSummaryEntity extends Equatable {
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final String membershipStatus;
  final DateTime? memberSince;

  // Today's report data
  final int todayDeeds;
  final int todayTarget;
  final bool hasSubmittedToday;
  final DateTime? lastReportTime;

  // Overall statistics
  final double complianceRate;
  final int currentStreak;
  final int totalReports;
  final double currentBalance;

  // Risk indicators
  final bool isAtRisk;
  final int daysWithoutReport;

  const UserReportSummaryEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
    required this.membershipStatus,
    this.memberSince,
    required this.todayDeeds,
    required this.todayTarget,
    required this.hasSubmittedToday,
    this.lastReportTime,
    required this.complianceRate,
    required this.currentStreak,
    required this.totalReports,
    required this.currentBalance,
    required this.isAtRisk,
    required this.daysWithoutReport,
  });

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        phoneNumber,
        profilePhotoUrl,
        membershipStatus,
        memberSince,
        todayDeeds,
        todayTarget,
        hasSubmittedToday,
        lastReportTime,
        complianceRate,
        currentStreak,
        totalReports,
        currentBalance,
        isAtRisk,
        daysWithoutReport,
      ];
}
