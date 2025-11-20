import 'package:equatable/equatable.dart';

/// Entity for a single deed entry with its template details
class DeedDetailEntity extends Equatable {
  final String deedName;
  final String deedKey;
  final String category; // 'faraid' or 'sunnah'
  final String valueType; // 'binary' or 'fractional'
  final double deedValue; // 0, 1, or 0.0-1.0 for fractional
  final int sortOrder;

  const DeedDetailEntity({
    required this.deedName,
    required this.deedKey,
    required this.category,
    required this.valueType,
    required this.deedValue,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [
        deedName,
        deedKey,
        category,
        valueType,
        deedValue,
        sortOrder,
      ];
}

/// Entity for a single day's report with all deed entries
class DailyReportDetailEntity extends Equatable {
  final DateTime reportDate;
  final String status; // 'draft' or 'submitted'
  final double totalDeeds;
  final double faraidCount;
  final double sunnahCount;
  final List<DeedDetailEntity> deedEntries;
  final DateTime? submittedAt;

  const DailyReportDetailEntity({
    required this.reportDate,
    required this.status,
    required this.totalDeeds,
    required this.faraidCount,
    required this.sunnahCount,
    required this.deedEntries,
    this.submittedAt,
  });

  @override
  List<Object?> get props => [
        reportDate,
        status,
        totalDeeds,
        faraidCount,
        sunnahCount,
        deedEntries,
        submittedAt,
      ];
}

/// Entity for detailed user report with all daily reports in a date range
class DetailedUserReportEntity extends Equatable {
  // User Information
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final String membershipStatus;
  final DateTime? memberSince;

  // Date Range
  final DateTime startDate;
  final DateTime endDate;

  // Summary Statistics
  final int totalReportsInRange;
  final double averageDeeds;
  final double complianceRate;
  final double faraidCompliance;
  final double sunnahCompliance;
  final double currentBalance;

  // Daily Reports
  final List<DailyReportDetailEntity> dailyReports;

  // Achievement Tags
  final List<String> achievementTags;

  const DetailedUserReportEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
    required this.membershipStatus,
    this.memberSince,
    required this.startDate,
    required this.endDate,
    required this.totalReportsInRange,
    required this.averageDeeds,
    required this.complianceRate,
    required this.faraidCompliance,
    required this.sunnahCompliance,
    required this.currentBalance,
    required this.dailyReports,
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
        startDate,
        endDate,
        totalReportsInRange,
        averageDeeds,
        complianceRate,
        faraidCompliance,
        sunnahCompliance,
        currentBalance,
        dailyReports,
        achievementTags,
      ];
}
