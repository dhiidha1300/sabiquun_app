// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserManagementModelImpl _$$UserManagementModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserManagementModelImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  photoUrl: json['photo_url'] as String?,
  role: json['role'] as String,
  accountStatus: json['account_status'] as String,
  membershipStatus: json['membership_status'] as String,
  excuseMode: json['excuse_mode'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  approvedBy: json['approved_by'] as String?,
  approvedAt: json['approved_at'] == null
      ? null
      : DateTime.parse(json['approved_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
  totalReports: (json['total_reports'] as num?)?.toInt() ?? 0,
  complianceRate: (json['compliance_rate'] as num?)?.toDouble() ?? 0.0,
  lastReportDate: json['last_report_date'] == null
      ? null
      : DateTime.parse(json['last_report_date'] as String),
);

Map<String, dynamic> _$$UserManagementModelImplToJson(
  _$UserManagementModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'phone': instance.phone,
  'photo_url': instance.photoUrl,
  'role': instance.role,
  'account_status': instance.accountStatus,
  'membership_status': instance.membershipStatus,
  'excuse_mode': instance.excuseMode,
  'created_at': instance.createdAt.toIso8601String(),
  'approved_by': instance.approvedBy,
  'approved_at': instance.approvedAt?.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'current_balance': instance.currentBalance,
  'total_reports': instance.totalReports,
  'compliance_rate': instance.complianceRate,
  'last_report_date': instance.lastReportDate?.toIso8601String(),
};
