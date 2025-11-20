import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/detailed_report_entity.dart';

part 'detailed_report_model.freezed.dart';
part 'detailed_report_model.g.dart';

/// Model for a single deed entry with its template details
@freezed
class DeedDetailModel with _$DeedDetailModel {
  const factory DeedDetailModel({
    required String deedName,
    required String deedKey,
    required String category, // 'faraid' or 'sunnah'
    required String valueType, // 'binary' or 'fractional'
    required double deedValue, // 0, 1, or 0.0-1.0 for fractional
    required int sortOrder,
  }) = _DeedDetailModel;

  const DeedDetailModel._();

  factory DeedDetailModel.fromJson(Map<String, dynamic> json) =>
      _$DeedDetailModelFromJson(json);

  DeedDetailEntity toEntity() {
    return DeedDetailEntity(
      deedName: deedName,
      deedKey: deedKey,
      category: category,
      valueType: valueType,
      deedValue: deedValue,
      sortOrder: sortOrder,
    );
  }
}

/// Model for a single day's report with all deed entries
@freezed
class DailyReportDetailModel with _$DailyReportDetailModel {
  const factory DailyReportDetailModel({
    required DateTime reportDate,
    required String status, // 'draft' or 'submitted'
    required double totalDeeds,
    required double faraidCount,
    required double sunnahCount,
    required List<DeedDetailModel> deedEntries,
    DateTime? submittedAt,
  }) = _DailyReportDetailModel;

  const DailyReportDetailModel._();

  factory DailyReportDetailModel.fromJson(Map<String, dynamic> json) =>
      _$DailyReportDetailModelFromJson(json);

  DailyReportDetailEntity toEntity() {
    return DailyReportDetailEntity(
      reportDate: reportDate,
      status: status,
      totalDeeds: totalDeeds,
      faraidCount: faraidCount,
      sunnahCount: sunnahCount,
      deedEntries: deedEntries.map((e) => e.toEntity()).toList(),
      submittedAt: submittedAt,
    );
  }
}

/// Model for detailed user report with all daily reports in a date range
@freezed
class DetailedUserReportModel with _$DetailedUserReportModel {
  const factory DetailedUserReportModel({
    // User Information
    required String userId,
    required String fullName,
    required String email,
    String? phoneNumber,
    String? profilePhotoUrl,
    required String membershipStatus,
    DateTime? memberSince,

    // Date Range
    required DateTime startDate,
    required DateTime endDate,

    // Summary Statistics
    required int totalReportsInRange,
    required double averageDeeds,
    required double complianceRate,
    required double faraidCompliance,
    required double sunnahCompliance,
    required double currentBalance,

    // Daily Reports
    required List<DailyReportDetailModel> dailyReports,

    // Achievement Tags
    required List<String> achievementTags,
  }) = _DetailedUserReportModel;

  const DetailedUserReportModel._();

  factory DetailedUserReportModel.fromJson(Map<String, dynamic> json) =>
      _$DetailedUserReportModelFromJson(json);

  DetailedUserReportEntity toEntity() {
    return DetailedUserReportEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePhotoUrl: profilePhotoUrl,
      membershipStatus: membershipStatus,
      memberSince: memberSince,
      startDate: startDate,
      endDate: endDate,
      totalReportsInRange: totalReportsInRange,
      averageDeeds: averageDeeds,
      complianceRate: complianceRate,
      faraidCompliance: faraidCompliance,
      sunnahCompliance: sunnahCompliance,
      currentBalance: currentBalance,
      dailyReports: dailyReports.map((e) => e.toEntity()).toList(),
      achievementTags: achievementTags,
    );
  }
}
