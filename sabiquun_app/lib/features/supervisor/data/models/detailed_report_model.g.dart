// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeedDetailModelImpl _$$DeedDetailModelImplFromJson(
  Map<String, dynamic> json,
) => _$DeedDetailModelImpl(
  deedName: json['deedName'] as String,
  deedKey: json['deedKey'] as String,
  category: json['category'] as String,
  valueType: json['valueType'] as String,
  deedValue: (json['deedValue'] as num).toDouble(),
  sortOrder: (json['sortOrder'] as num).toInt(),
);

Map<String, dynamic> _$$DeedDetailModelImplToJson(
  _$DeedDetailModelImpl instance,
) => <String, dynamic>{
  'deedName': instance.deedName,
  'deedKey': instance.deedKey,
  'category': instance.category,
  'valueType': instance.valueType,
  'deedValue': instance.deedValue,
  'sortOrder': instance.sortOrder,
};

_$DailyReportDetailModelImpl _$$DailyReportDetailModelImplFromJson(
  Map<String, dynamic> json,
) => _$DailyReportDetailModelImpl(
  reportDate: DateTime.parse(json['reportDate'] as String),
  status: json['status'] as String,
  totalDeeds: (json['totalDeeds'] as num).toDouble(),
  faraidCount: (json['faraidCount'] as num).toDouble(),
  sunnahCount: (json['sunnahCount'] as num).toDouble(),
  deedEntries: (json['deedEntries'] as List<dynamic>)
      .map((e) => DeedDetailModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
);

Map<String, dynamic> _$$DailyReportDetailModelImplToJson(
  _$DailyReportDetailModelImpl instance,
) => <String, dynamic>{
  'reportDate': instance.reportDate.toIso8601String(),
  'status': instance.status,
  'totalDeeds': instance.totalDeeds,
  'faraidCount': instance.faraidCount,
  'sunnahCount': instance.sunnahCount,
  'deedEntries': instance.deedEntries,
  'submittedAt': instance.submittedAt?.toIso8601String(),
};

_$DetailedUserReportModelImpl _$$DetailedUserReportModelImplFromJson(
  Map<String, dynamic> json,
) => _$DetailedUserReportModelImpl(
  userId: json['userId'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  profilePhotoUrl: json['profilePhotoUrl'] as String?,
  membershipStatus: json['membershipStatus'] as String,
  memberSince: json['memberSince'] == null
      ? null
      : DateTime.parse(json['memberSince'] as String),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  totalReportsInRange: (json['totalReportsInRange'] as num).toInt(),
  averageDeeds: (json['averageDeeds'] as num).toDouble(),
  complianceRate: (json['complianceRate'] as num).toDouble(),
  faraidCompliance: (json['faraidCompliance'] as num).toDouble(),
  sunnahCompliance: (json['sunnahCompliance'] as num).toDouble(),
  currentBalance: (json['currentBalance'] as num).toDouble(),
  dailyReports: (json['dailyReports'] as List<dynamic>)
      .map((e) => DailyReportDetailModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  achievementTags: (json['achievementTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$DetailedUserReportModelImplToJson(
  _$DetailedUserReportModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'profilePhotoUrl': instance.profilePhotoUrl,
  'membershipStatus': instance.membershipStatus,
  'memberSince': instance.memberSince?.toIso8601String(),
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'totalReportsInRange': instance.totalReportsInRange,
  'averageDeeds': instance.averageDeeds,
  'complianceRate': instance.complianceRate,
  'faraidCompliance': instance.faraidCompliance,
  'sunnahCompliance': instance.sunnahCompliance,
  'currentBalance': instance.currentBalance,
  'dailyReports': instance.dailyReports,
  'achievementTags': instance.achievementTags,
};
