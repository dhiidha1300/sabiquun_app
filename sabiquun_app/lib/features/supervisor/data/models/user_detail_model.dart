import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_detail_entity.dart';

part 'user_detail_model.freezed.dart';
part 'user_detail_model.g.dart';

@freezed
class UserDetailModel with _$UserDetailModel {
  const factory UserDetailModel({
    required String userId,
    required String fullName,
    required String email,
    String? phoneNumber,
    String? profilePhotoUrl,
    required String membershipStatus,
    DateTime? memberSince,
    required String status,
    required double overallCompliance,
    required double currentBalance,
    required int totalReports,
    required int currentStreak,
    required int longestStreak,
    DateTime? lastReportDate,
    required int deedsThisWeek,
    required int deedsThisMonth,
    required double faraidCompliance,
    required double sunnahCompliance,
    required List<String> achievementTags,
  }) = _UserDetailModel;

  const UserDetailModel._();

  factory UserDetailModel.fromJson(Map<String, dynamic> json) =>
      _$UserDetailModelFromJson(json);

  UserDetailEntity toEntity() {
    return UserDetailEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePhotoUrl: profilePhotoUrl,
      membershipStatus: membershipStatus,
      memberSince: memberSince,
      status: status,
      overallCompliance: overallCompliance,
      currentBalance: currentBalance,
      totalReports: totalReports,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastReportDate: lastReportDate,
      deedsThisWeek: deedsThisWeek,
      deedsThisMonth: deedsThisMonth,
      faraidCompliance: faraidCompliance,
      sunnahCompliance: sunnahCompliance,
      achievementTags: achievementTags,
    );
  }
}
