import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_report_summary_entity.dart';

part 'user_report_summary_model.freezed.dart';
part 'user_report_summary_model.g.dart';

@freezed
class UserReportSummaryModel with _$UserReportSummaryModel {
  const factory UserReportSummaryModel({
    required String userId,
    required String fullName,
    required String email,
    String? phoneNumber,
    String? profilePhotoUrl,
    required String membershipStatus,
    DateTime? memberSince,
    required int todayDeeds,
    required int todayTarget,
    required bool hasSubmittedToday,
    DateTime? lastReportTime,
    required double complianceRate,
    required int currentStreak,
    required int totalReports,
    required double currentBalance,
    required bool isAtRisk,
    required int daysWithoutReport,
    @Default({}) Map<String, Map<String, int>> weeklyDeeds,
  }) = _UserReportSummaryModel;

  const UserReportSummaryModel._();

  factory UserReportSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$UserReportSummaryModelFromJson(json);

  UserReportSummaryEntity toEntity() {
    return UserReportSummaryEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePhotoUrl: profilePhotoUrl,
      membershipStatus: membershipStatus,
      memberSince: memberSince,
      todayDeeds: todayDeeds,
      todayTarget: todayTarget,
      hasSubmittedToday: hasSubmittedToday,
      lastReportTime: lastReportTime,
      complianceRate: complianceRate,
      currentStreak: currentStreak,
      totalReports: totalReports,
      currentBalance: currentBalance,
      isAtRisk: isAtRisk,
      daysWithoutReport: daysWithoutReport,
      weeklyDeeds: weeklyDeeds,
    );
  }
}
