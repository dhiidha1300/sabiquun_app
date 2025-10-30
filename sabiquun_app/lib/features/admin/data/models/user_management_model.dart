import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_management_entity.dart';
import '../../../../core/constants/user_role.dart';
import '../../../../core/constants/account_status.dart';

part 'user_management_model.freezed.dart';
part 'user_management_model.g.dart';

@freezed
class UserManagementModel with _$UserManagementModel {
  const UserManagementModel._();

  const factory UserManagementModel({
    required String id,
    required String email,
    required String name,
    String? phone,
    @JsonKey(name: 'photo_url') String? photoUrl,
    required String role,
    @JsonKey(name: 'account_status') required String accountStatus,
    @JsonKey(name: 'membership_status') required String membershipStatus,
    @JsonKey(name: 'excuse_mode') @Default(false) bool excuseMode,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'approved_by') String? approvedBy,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'current_balance') @Default(0.0) double currentBalance,
    @JsonKey(name: 'total_reports') @Default(0) int totalReports,
    @JsonKey(name: 'compliance_rate') @Default(0.0) double complianceRate,
    @JsonKey(name: 'last_report_date') DateTime? lastReportDate,
  }) = _UserManagementModel;

  factory UserManagementModel.fromJson(Map<String, dynamic> json) =>
      _$UserManagementModelFromJson(json);

  UserManagementEntity toEntity() {
    return UserManagementEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      role: UserRole.fromString(role),
      accountStatus: AccountStatus.fromString(accountStatus),
      membershipStatus: membershipStatus,
      excuseMode: excuseMode,
      createdAt: createdAt,
      approvedBy: approvedBy,
      approvedAt: approvedAt,
      updatedAt: updatedAt,
      currentBalance: currentBalance,
      totalReports: totalReports,
      complianceRate: complianceRate,
      lastReportDate: lastReportDate,
    );
  }
}
