// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalyticsModelImpl _$$AnalyticsModelImplFromJson(Map<String, dynamic> json) =>
    _$AnalyticsModelImpl(
      userMetrics: UserMetricsModel.fromJson(
        json['userMetrics'] as Map<String, dynamic>,
      ),
      deedMetrics: DeedMetricsModel.fromJson(
        json['deedMetrics'] as Map<String, dynamic>,
      ),
      financialMetrics: FinancialMetricsModel.fromJson(
        json['financialMetrics'] as Map<String, dynamic>,
      ),
      engagementMetrics: EngagementMetricsModel.fromJson(
        json['engagementMetrics'] as Map<String, dynamic>,
      ),
      excuseMetrics: ExcuseMetricsModel.fromJson(
        json['excuseMetrics'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$AnalyticsModelImplToJson(
  _$AnalyticsModelImpl instance,
) => <String, dynamic>{
  'userMetrics': instance.userMetrics,
  'deedMetrics': instance.deedMetrics,
  'financialMetrics': instance.financialMetrics,
  'engagementMetrics': instance.engagementMetrics,
  'excuseMetrics': instance.excuseMetrics,
};

_$UserMetricsModelImpl _$$UserMetricsModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserMetricsModelImpl(
  pendingUsers: (json['pending_users'] as num).toInt(),
  activeUsers: (json['active_users'] as num).toInt(),
  suspendedUsers: (json['suspended_users'] as num).toInt(),
  deactivatedUsers: (json['deactivated_users'] as num).toInt(),
  newMembers: (json['new_members'] as num).toInt(),
  exclusiveMembers: (json['exclusive_members'] as num).toInt(),
  legacyMembers: (json['legacy_members'] as num).toInt(),
  usersAtRisk: (json['users_at_risk'] as num).toInt(),
  newRegistrationsThisWeek: (json['new_registrations_this_week'] as num)
      .toInt(),
);

Map<String, dynamic> _$$UserMetricsModelImplToJson(
  _$UserMetricsModelImpl instance,
) => <String, dynamic>{
  'pending_users': instance.pendingUsers,
  'active_users': instance.activeUsers,
  'suspended_users': instance.suspendedUsers,
  'deactivated_users': instance.deactivatedUsers,
  'new_members': instance.newMembers,
  'exclusive_members': instance.exclusiveMembers,
  'legacy_members': instance.legacyMembers,
  'users_at_risk': instance.usersAtRisk,
  'new_registrations_this_week': instance.newRegistrationsThisWeek,
};

_$DeedMetricsModelImpl _$$DeedMetricsModelImplFromJson(
  Map<String, dynamic> json,
) => _$DeedMetricsModelImpl(
  totalDeedsToday: (json['total_deeds_today'] as num).toInt(),
  totalDeedsWeek: (json['total_deeds_week'] as num).toInt(),
  totalDeedsMonth: (json['total_deeds_month'] as num).toInt(),
  totalDeedsAllTime: (json['total_deeds_all_time'] as num).toInt(),
  averagePerUserToday: (json['average_per_user_today'] as num).toDouble(),
  averagePerUserWeek: (json['average_per_user_week'] as num).toDouble(),
  averagePerUserMonth: (json['average_per_user_month'] as num).toDouble(),
  complianceRateToday: (json['compliance_rate_today'] as num).toDouble(),
  complianceRateWeek: (json['compliance_rate_week'] as num).toDouble(),
  complianceRateMonth: (json['compliance_rate_month'] as num).toDouble(),
  usersCompletedToday: (json['users_completed_today'] as num).toInt(),
  totalActiveUsers: (json['total_active_users'] as num).toInt(),
  faraidComplianceRate: (json['faraid_compliance_rate'] as num).toDouble(),
  sunnahComplianceRate: (json['sunnah_compliance_rate'] as num).toDouble(),
  topPerformers: (json['top_performers'] as List<dynamic>)
      .map((e) => TopPerformerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  usersNeedingAttention: (json['users_needing_attention'] as List<dynamic>)
      .map((e) => UserNeedingAttentionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  deedComplianceByType:
      (json['deed_compliance_by_type'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
);

Map<String, dynamic> _$$DeedMetricsModelImplToJson(
  _$DeedMetricsModelImpl instance,
) => <String, dynamic>{
  'total_deeds_today': instance.totalDeedsToday,
  'total_deeds_week': instance.totalDeedsWeek,
  'total_deeds_month': instance.totalDeedsMonth,
  'total_deeds_all_time': instance.totalDeedsAllTime,
  'average_per_user_today': instance.averagePerUserToday,
  'average_per_user_week': instance.averagePerUserWeek,
  'average_per_user_month': instance.averagePerUserMonth,
  'compliance_rate_today': instance.complianceRateToday,
  'compliance_rate_week': instance.complianceRateWeek,
  'compliance_rate_month': instance.complianceRateMonth,
  'users_completed_today': instance.usersCompletedToday,
  'total_active_users': instance.totalActiveUsers,
  'faraid_compliance_rate': instance.faraidComplianceRate,
  'sunnah_compliance_rate': instance.sunnahComplianceRate,
  'top_performers': instance.topPerformers,
  'users_needing_attention': instance.usersNeedingAttention,
  'deed_compliance_by_type': instance.deedComplianceByType,
};

_$TopPerformerModelImpl _$$TopPerformerModelImplFromJson(
  Map<String, dynamic> json,
) => _$TopPerformerModelImpl(
  userId: json['user_id'] as String,
  userName: json['user_name'] as String,
  averageDeeds: (json['average_deeds'] as num).toDouble(),
);

Map<String, dynamic> _$$TopPerformerModelImplToJson(
  _$TopPerformerModelImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'user_name': instance.userName,
  'average_deeds': instance.averageDeeds,
};

_$UserNeedingAttentionModelImpl _$$UserNeedingAttentionModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserNeedingAttentionModelImpl(
  userId: json['user_id'] as String,
  userName: json['user_name'] as String,
  averageDeeds: (json['average_deeds'] as num).toDouble(),
);

Map<String, dynamic> _$$UserNeedingAttentionModelImplToJson(
  _$UserNeedingAttentionModelImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'user_name': instance.userName,
  'average_deeds': instance.averageDeeds,
};

_$FinancialMetricsModelImpl _$$FinancialMetricsModelImplFromJson(
  Map<String, dynamic> json,
) => _$FinancialMetricsModelImpl(
  penaltiesIncurredThisMonth: (json['penalties_incurred_this_month'] as num)
      .toDouble(),
  penaltiesIncurredAllTime: (json['penalties_incurred_all_time'] as num)
      .toDouble(),
  paymentsReceivedThisMonth: (json['payments_received_this_month'] as num)
      .toDouble(),
  paymentsReceivedAllTime: (json['payments_received_all_time'] as num)
      .toDouble(),
  outstandingBalance: (json['outstanding_balance'] as num).toDouble(),
  pendingPaymentsCount: (json['pending_payments_count'] as num).toInt(),
  pendingPaymentsAmount: (json['pending_payments_amount'] as num).toDouble(),
);

Map<String, dynamic> _$$FinancialMetricsModelImplToJson(
  _$FinancialMetricsModelImpl instance,
) => <String, dynamic>{
  'penalties_incurred_this_month': instance.penaltiesIncurredThisMonth,
  'penalties_incurred_all_time': instance.penaltiesIncurredAllTime,
  'payments_received_this_month': instance.paymentsReceivedThisMonth,
  'payments_received_all_time': instance.paymentsReceivedAllTime,
  'outstanding_balance': instance.outstandingBalance,
  'pending_payments_count': instance.pendingPaymentsCount,
  'pending_payments_amount': instance.pendingPaymentsAmount,
};

_$EngagementMetricsModelImpl _$$EngagementMetricsModelImplFromJson(
  Map<String, dynamic> json,
) => _$EngagementMetricsModelImpl(
  dailyActiveUsers: (json['daily_active_users'] as num).toInt(),
  totalActiveUsers: (json['total_active_users'] as num).toInt(),
  reportSubmissionRate: (json['report_submission_rate'] as num).toDouble(),
  averageSubmissionTime: json['average_submission_time'] as String,
  notificationOpenRate: (json['notification_open_rate'] as num).toDouble(),
  averageResponseTimeMinutes: (json['average_response_time_minutes'] as num)
      .toInt(),
);

Map<String, dynamic> _$$EngagementMetricsModelImplToJson(
  _$EngagementMetricsModelImpl instance,
) => <String, dynamic>{
  'daily_active_users': instance.dailyActiveUsers,
  'total_active_users': instance.totalActiveUsers,
  'report_submission_rate': instance.reportSubmissionRate,
  'average_submission_time': instance.averageSubmissionTime,
  'notification_open_rate': instance.notificationOpenRate,
  'average_response_time_minutes': instance.averageResponseTimeMinutes,
};

_$ExcuseMetricsModelImpl _$$ExcuseMetricsModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExcuseMetricsModelImpl(
  pendingExcuses: (json['pending_excuses'] as num).toInt(),
  approvalRate: (json['approval_rate'] as num).toDouble(),
  excusesByReason: Map<String, int>.from(json['excuses_by_reason'] as Map),
);

Map<String, dynamic> _$$ExcuseMetricsModelImplToJson(
  _$ExcuseMetricsModelImpl instance,
) => <String, dynamic>{
  'pending_excuses': instance.pendingExcuses,
  'approval_rate': instance.approvalRate,
  'excuses_by_reason': instance.excusesByReason,
};
