// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SystemSettingsModelImpl _$$SystemSettingsModelImplFromJson(
  Map<String, dynamic> json,
) => _$SystemSettingsModelImpl(
  dailyDeedTarget: (json['daily_deed_target'] as num).toInt(),
  penaltyPerDeed: (json['penalty_per_deed'] as num).toDouble(),
  gracePeriodHours: (json['grace_period_hours'] as num).toInt(),
  trainingPeriodDays: (json['training_period_days'] as num).toInt(),
  autoDeactivationThreshold: (json['auto_deactivation_threshold'] as num)
      .toDouble(),
  warningThresholds: (json['warning_thresholds'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  organizationName: json['organization_name'] as String,
  receiptFooterText: json['receipt_footer_text'] as String,
  emailApiKey: json['email_api_key'] as String?,
  emailDomain: json['email_domain'] as String?,
  emailSenderEmail: json['email_sender_email'] as String?,
  emailSenderName: json['email_sender_name'] as String?,
  fcmServerKey: json['fcm_server_key'] as String?,
  appVersion: json['app_version'] as String,
  minimumRequiredVersion: json['minimum_required_version'] as String,
  forceUpdate: json['force_update'] as bool,
  updateTitle: json['update_title'] as String?,
  updateMessage: json['update_message'] as String?,
  iosMinVersion: json['ios_min_version'] as String?,
  androidMinVersion: json['android_min_version'] as String?,
);

Map<String, dynamic> _$$SystemSettingsModelImplToJson(
  _$SystemSettingsModelImpl instance,
) => <String, dynamic>{
  'daily_deed_target': instance.dailyDeedTarget,
  'penalty_per_deed': instance.penaltyPerDeed,
  'grace_period_hours': instance.gracePeriodHours,
  'training_period_days': instance.trainingPeriodDays,
  'auto_deactivation_threshold': instance.autoDeactivationThreshold,
  'warning_thresholds': instance.warningThresholds,
  'organization_name': instance.organizationName,
  'receipt_footer_text': instance.receiptFooterText,
  'email_api_key': instance.emailApiKey,
  'email_domain': instance.emailDomain,
  'email_sender_email': instance.emailSenderEmail,
  'email_sender_name': instance.emailSenderName,
  'fcm_server_key': instance.fcmServerKey,
  'app_version': instance.appVersion,
  'minimum_required_version': instance.minimumRequiredVersion,
  'force_update': instance.forceUpdate,
  'update_title': instance.updateTitle,
  'update_message': instance.updateMessage,
  'ios_min_version': instance.iosMinVersion,
  'android_min_version': instance.androidMinVersion,
};
