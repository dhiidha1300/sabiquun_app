import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/analytics_entity.dart';

part 'analytics_model.freezed.dart';
part 'analytics_model.g.dart';

@freezed
class AnalyticsModel with _$AnalyticsModel {
  const AnalyticsModel._();

  const factory AnalyticsModel({
    required UserMetricsModel userMetrics,
    required DeedMetricsModel deedMetrics,
    required FinancialMetricsModel financialMetrics,
    required EngagementMetricsModel engagementMetrics,
    required ExcuseMetricsModel excuseMetrics,
  }) = _AnalyticsModel;

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsModelFromJson(json);

  AnalyticsEntity toEntity() {
    return AnalyticsEntity(
      userMetrics: userMetrics.toEntity(),
      deedMetrics: deedMetrics.toEntity(),
      financialMetrics: financialMetrics.toEntity(),
      engagementMetrics: engagementMetrics.toEntity(),
      excuseMetrics: excuseMetrics.toEntity(),
    );
  }
}

@freezed
class UserMetricsModel with _$UserMetricsModel {
  const UserMetricsModel._();

  const factory UserMetricsModel({
    @JsonKey(name: 'pending_users') required int pendingUsers,
    @JsonKey(name: 'active_users') required int activeUsers,
    @JsonKey(name: 'suspended_users') required int suspendedUsers,
    @JsonKey(name: 'deactivated_users') required int deactivatedUsers,
    @JsonKey(name: 'new_members') required int newMembers,
    @JsonKey(name: 'exclusive_members') required int exclusiveMembers,
    @JsonKey(name: 'legacy_members') required int legacyMembers,
    @JsonKey(name: 'users_at_risk') required int usersAtRisk,
    @JsonKey(name: 'new_registrations_this_week')
    required int newRegistrationsThisWeek,
  }) = _UserMetricsModel;

  factory UserMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$UserMetricsModelFromJson(json);

  UserMetrics toEntity() {
    return UserMetrics(
      pendingUsers: pendingUsers,
      activeUsers: activeUsers,
      suspendedUsers: suspendedUsers,
      deactivatedUsers: deactivatedUsers,
      newMembers: newMembers,
      exclusiveMembers: exclusiveMembers,
      legacyMembers: legacyMembers,
      usersAtRisk: usersAtRisk,
      newRegistrationsThisWeek: newRegistrationsThisWeek,
    );
  }
}

@freezed
class DeedMetricsModel with _$DeedMetricsModel {
  const DeedMetricsModel._();

  const factory DeedMetricsModel({
    @JsonKey(name: 'total_deeds_today') required int totalDeedsToday,
    @JsonKey(name: 'total_deeds_week') required int totalDeedsWeek,
    @JsonKey(name: 'total_deeds_month') required int totalDeedsMonth,
    @JsonKey(name: 'total_deeds_all_time') required int totalDeedsAllTime,
    @JsonKey(name: 'average_per_user_today') required double averagePerUserToday,
    @JsonKey(name: 'average_per_user_week') required double averagePerUserWeek,
    @JsonKey(name: 'average_per_user_month') required double averagePerUserMonth,
    @JsonKey(name: 'compliance_rate_today') required double complianceRateToday,
    @JsonKey(name: 'compliance_rate_week') required double complianceRateWeek,
    @JsonKey(name: 'compliance_rate_month') required double complianceRateMonth,
    @JsonKey(name: 'users_completed_today') required int usersCompletedToday,
    @JsonKey(name: 'total_active_users') required int totalActiveUsers,
    @JsonKey(name: 'faraid_compliance_rate')
    required double faraidComplianceRate,
    @JsonKey(name: 'sunnah_compliance_rate')
    required double sunnahComplianceRate,
    @JsonKey(name: 'top_performers') required List<TopPerformerModel> topPerformers,
    @JsonKey(name: 'users_needing_attention')
    required List<UserNeedingAttentionModel> usersNeedingAttention,
    @JsonKey(name: 'deed_compliance_by_type')
    required Map<String, double> deedComplianceByType,
  }) = _DeedMetricsModel;

  factory DeedMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$DeedMetricsModelFromJson(json);

  DeedMetrics toEntity() {
    return DeedMetrics(
      totalDeedsToday: totalDeedsToday,
      totalDeedsWeek: totalDeedsWeek,
      totalDeedsMonth: totalDeedsMonth,
      totalDeedsAllTime: totalDeedsAllTime,
      averagePerUserToday: averagePerUserToday,
      averagePerUserWeek: averagePerUserWeek,
      averagePerUserMonth: averagePerUserMonth,
      complianceRateToday: complianceRateToday,
      complianceRateWeek: complianceRateWeek,
      complianceRateMonth: complianceRateMonth,
      usersCompletedToday: usersCompletedToday,
      totalActiveUsers: totalActiveUsers,
      faraidComplianceRate: faraidComplianceRate,
      sunnahComplianceRate: sunnahComplianceRate,
      topPerformers: topPerformers.map((m) => m.toEntity()).toList(),
      usersNeedingAttention:
          usersNeedingAttention.map((m) => m.toEntity()).toList(),
      deedComplianceByType: deedComplianceByType,
    );
  }
}

@freezed
class TopPerformerModel with _$TopPerformerModel {
  const TopPerformerModel._();

  const factory TopPerformerModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') required String userName,
    @JsonKey(name: 'average_deeds') required double averageDeeds,
  }) = _TopPerformerModel;

  factory TopPerformerModel.fromJson(Map<String, dynamic> json) =>
      _$TopPerformerModelFromJson(json);

  TopPerformer toEntity() {
    return TopPerformer(
      userId: userId,
      userName: userName,
      averageDeeds: averageDeeds,
    );
  }
}

@freezed
class UserNeedingAttentionModel with _$UserNeedingAttentionModel {
  const UserNeedingAttentionModel._();

  const factory UserNeedingAttentionModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') required String userName,
    @JsonKey(name: 'average_deeds') required double averageDeeds,
  }) = _UserNeedingAttentionModel;

  factory UserNeedingAttentionModel.fromJson(Map<String, dynamic> json) =>
      _$UserNeedingAttentionModelFromJson(json);

  UserNeedingAttention toEntity() {
    return UserNeedingAttention(
      userId: userId,
      userName: userName,
      averageDeeds: averageDeeds,
    );
  }
}

@freezed
class FinancialMetricsModel with _$FinancialMetricsModel {
  const FinancialMetricsModel._();

  const factory FinancialMetricsModel({
    @JsonKey(name: 'penalties_incurred_this_month')
    required double penaltiesIncurredThisMonth,
    @JsonKey(name: 'penalties_incurred_all_time')
    required double penaltiesIncurredAllTime,
    @JsonKey(name: 'payments_received_this_month')
    required double paymentsReceivedThisMonth,
    @JsonKey(name: 'payments_received_all_time')
    required double paymentsReceivedAllTime,
    @JsonKey(name: 'outstanding_balance') required double outstandingBalance,
    @JsonKey(name: 'pending_payments_count') required int pendingPaymentsCount,
    @JsonKey(name: 'pending_payments_amount')
    required double pendingPaymentsAmount,
  }) = _FinancialMetricsModel;

  factory FinancialMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialMetricsModelFromJson(json);

  FinancialMetrics toEntity() {
    return FinancialMetrics(
      penaltiesIncurredThisMonth: penaltiesIncurredThisMonth,
      penaltiesIncurredAllTime: penaltiesIncurredAllTime,
      paymentsReceivedThisMonth: paymentsReceivedThisMonth,
      paymentsReceivedAllTime: paymentsReceivedAllTime,
      outstandingBalance: outstandingBalance,
      pendingPaymentsCount: pendingPaymentsCount,
      pendingPaymentsAmount: pendingPaymentsAmount,
    );
  }
}

@freezed
class EngagementMetricsModel with _$EngagementMetricsModel {
  const EngagementMetricsModel._();

  const factory EngagementMetricsModel({
    @JsonKey(name: 'daily_active_users') required int dailyActiveUsers,
    @JsonKey(name: 'total_active_users') required int totalActiveUsers,
    @JsonKey(name: 'report_submission_rate')
    required double reportSubmissionRate,
    @JsonKey(name: 'average_submission_time')
    required String averageSubmissionTime,
    @JsonKey(name: 'notification_open_rate')
    required double notificationOpenRate,
    @JsonKey(name: 'average_response_time_minutes')
    required int averageResponseTimeMinutes,
  }) = _EngagementMetricsModel;

  factory EngagementMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$EngagementMetricsModelFromJson(json);

  EngagementMetrics toEntity() {
    return EngagementMetrics(
      dailyActiveUsers: dailyActiveUsers,
      totalActiveUsers: totalActiveUsers,
      reportSubmissionRate: reportSubmissionRate,
      averageSubmissionTime: averageSubmissionTime,
      notificationOpenRate: notificationOpenRate,
      averageResponseTimeMinutes: averageResponseTimeMinutes,
    );
  }
}

@freezed
class ExcuseMetricsModel with _$ExcuseMetricsModel {
  const ExcuseMetricsModel._();

  const factory ExcuseMetricsModel({
    @JsonKey(name: 'pending_excuses') required int pendingExcuses,
    @JsonKey(name: 'approval_rate') required double approvalRate,
    @JsonKey(name: 'excuses_by_reason') required Map<String, int> excusesByReason,
  }) = _ExcuseMetricsModel;

  factory ExcuseMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$ExcuseMetricsModelFromJson(json);

  ExcuseMetrics toEntity() {
    return ExcuseMetrics(
      pendingExcuses: pendingExcuses,
      approvalRate: approvalRate,
      excusesByReason: excusesByReason,
    );
  }
}
