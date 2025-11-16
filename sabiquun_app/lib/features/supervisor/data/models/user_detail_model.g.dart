// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDetailModelImpl _$$UserDetailModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserDetailModelImpl(
  userId: json['userId'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  profilePhotoUrl: json['profilePhotoUrl'] as String?,
  membershipStatus: json['membershipStatus'] as String,
  memberSince: json['memberSince'] == null
      ? null
      : DateTime.parse(json['memberSince'] as String),
  status: json['status'] as String,
  overallCompliance: (json['overallCompliance'] as num).toDouble(),
  currentBalance: (json['currentBalance'] as num).toDouble(),
  totalReports: (json['totalReports'] as num).toInt(),
  currentStreak: (json['currentStreak'] as num).toInt(),
  longestStreak: (json['longestStreak'] as num).toInt(),
  lastReportDate: json['lastReportDate'] == null
      ? null
      : DateTime.parse(json['lastReportDate'] as String),
  deedsThisWeek: (json['deedsThisWeek'] as num).toInt(),
  deedsThisMonth: (json['deedsThisMonth'] as num).toInt(),
  faraidCompliance: (json['faraidCompliance'] as num).toDouble(),
  sunnahCompliance: (json['sunnahCompliance'] as num).toDouble(),
  achievementTags: (json['achievementTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$UserDetailModelImplToJson(
  _$UserDetailModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'profilePhotoUrl': instance.profilePhotoUrl,
  'membershipStatus': instance.membershipStatus,
  'memberSince': instance.memberSince?.toIso8601String(),
  'status': instance.status,
  'overallCompliance': instance.overallCompliance,
  'currentBalance': instance.currentBalance,
  'totalReports': instance.totalReports,
  'currentStreak': instance.currentStreak,
  'longestStreak': instance.longestStreak,
  'lastReportDate': instance.lastReportDate?.toIso8601String(),
  'deedsThisWeek': instance.deedsThisWeek,
  'deedsThisMonth': instance.deedsThisMonth,
  'faraidCompliance': instance.faraidCompliance,
  'sunnahCompliance': instance.sunnahCompliance,
  'achievementTags': instance.achievementTags,
};
