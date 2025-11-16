import 'package:equatable/equatable.dart';

/// Detailed user information for supervisor view
class UserDetailEntity extends Equatable {
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final String membershipStatus;
  final DateTime? memberSince;
  final String status;

  // Statistics
  final double overallCompliance;
  final double currentBalance;
  final int totalReports;
  final int currentStreak;
  final int longestStreak;

  // Recent activity
  final DateTime? lastReportDate;
  final int deedsThisWeek;
  final int deedsThisMonth;
  final double faraidCompliance;
  final double sunnahCompliance;

  // Tags and achievements
  final List<String> achievementTags;

  const UserDetailEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
    required this.membershipStatus,
    this.memberSince,
    required this.status,
    required this.overallCompliance,
    required this.currentBalance,
    required this.totalReports,
    required this.currentStreak,
    required this.longestStreak,
    this.lastReportDate,
    required this.deedsThisWeek,
    required this.deedsThisMonth,
    required this.faraidCompliance,
    required this.sunnahCompliance,
    required this.achievementTags,
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
        status,
        overallCompliance,
        currentBalance,
        totalReports,
        currentStreak,
        longestStreak,
        lastReportDate,
        deedsThisWeek,
        deedsThisMonth,
        faraidCompliance,
        sunnahCompliance,
        achievementTags,
      ];
}
