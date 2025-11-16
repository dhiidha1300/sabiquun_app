// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_report_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserReportSummaryModelImpl _$$UserReportSummaryModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserReportSummaryModelImpl(
  userId: json['userId'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  profilePhotoUrl: json['profilePhotoUrl'] as String?,
  membershipStatus: json['membershipStatus'] as String,
  memberSince: json['memberSince'] == null
      ? null
      : DateTime.parse(json['memberSince'] as String),
  todayDeeds: (json['todayDeeds'] as num).toInt(),
  todayTarget: (json['todayTarget'] as num).toInt(),
  hasSubmittedToday: json['hasSubmittedToday'] as bool,
  lastReportTime: json['lastReportTime'] == null
      ? null
      : DateTime.parse(json['lastReportTime'] as String),
  complianceRate: (json['complianceRate'] as num).toDouble(),
  currentStreak: (json['currentStreak'] as num).toInt(),
  totalReports: (json['totalReports'] as num).toInt(),
  currentBalance: (json['currentBalance'] as num).toDouble(),
  isAtRisk: json['isAtRisk'] as bool,
  daysWithoutReport: (json['daysWithoutReport'] as num).toInt(),
);

Map<String, dynamic> _$$UserReportSummaryModelImplToJson(
  _$UserReportSummaryModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'profilePhotoUrl': instance.profilePhotoUrl,
  'membershipStatus': instance.membershipStatus,
  'memberSince': instance.memberSince?.toIso8601String(),
  'todayDeeds': instance.todayDeeds,
  'todayTarget': instance.todayTarget,
  'hasSubmittedToday': instance.hasSubmittedToday,
  'lastReportTime': instance.lastReportTime?.toIso8601String(),
  'complianceRate': instance.complianceRate,
  'currentStreak': instance.currentStreak,
  'totalReports': instance.totalReports,
  'currentBalance': instance.currentBalance,
  'isAtRisk': instance.isAtRisk,
  'daysWithoutReport': instance.daysWithoutReport,
};
