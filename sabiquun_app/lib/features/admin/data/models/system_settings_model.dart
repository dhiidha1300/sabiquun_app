import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/system_settings_entity.dart';

part 'system_settings_model.freezed.dart';
part 'system_settings_model.g.dart';

@freezed
class SystemSettingsModel with _$SystemSettingsModel {
  const SystemSettingsModel._();

  const factory SystemSettingsModel({
    @JsonKey(name: 'daily_deed_target') required int dailyDeedTarget,
    @JsonKey(name: 'penalty_per_deed') required double penaltyPerDeed,
    @JsonKey(name: 'grace_period_hours') required int gracePeriodHours,
    @JsonKey(name: 'training_period_days') required int trainingPeriodDays,
    @JsonKey(name: 'auto_deactivation_threshold')
    required double autoDeactivationThreshold,
    @JsonKey(name: 'warning_thresholds') required List<double> warningThresholds,
    @JsonKey(name: 'organization_name') required String organizationName,
    @JsonKey(name: 'receipt_footer_text') required String receiptFooterText,
    @JsonKey(name: 'email_api_key') String? emailApiKey,
    @JsonKey(name: 'email_domain') String? emailDomain,
    @JsonKey(name: 'email_sender_email') String? emailSenderEmail,
    @JsonKey(name: 'email_sender_name') String? emailSenderName,
    @JsonKey(name: 'fcm_server_key') String? fcmServerKey,
    @JsonKey(name: 'app_version') required String appVersion,
    @JsonKey(name: 'minimum_required_version') required String minimumRequiredVersion,
    @JsonKey(name: 'force_update') required bool forceUpdate,
    @JsonKey(name: 'update_title') String? updateTitle,
    @JsonKey(name: 'update_message') String? updateMessage,
    @JsonKey(name: 'ios_min_version') String? iosMinVersion,
    @JsonKey(name: 'android_min_version') String? androidMinVersion,
  }) = _SystemSettingsModel;

  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SystemSettingsModelFromJson(json);

  /// Create model from key-value map (settings table format)
  factory SystemSettingsModel.fromSettingsMap(Map<String, dynamic> settingsMap) {
    return SystemSettingsModel(
      dailyDeedTarget: int.parse(settingsMap['daily_deed_target']?.toString() ?? '10'),
      penaltyPerDeed: double.parse(settingsMap['penalty_per_deed']?.toString() ?? '5000'),
      gracePeriodHours: int.parse(settingsMap['grace_period_hours']?.toString() ?? '2'),
      trainingPeriodDays: int.parse(settingsMap['training_period_days']?.toString() ?? '30'),
      autoDeactivationThreshold: double.parse(
          settingsMap['auto_deactivation_threshold']?.toString() ?? '400000'),
      warningThresholds: _parseWarningThresholds(settingsMap['warning_thresholds']),
      organizationName: settingsMap['organization_name']?.toString() ?? 'Sabiquun',
      receiptFooterText: settingsMap['receipt_footer_text']?.toString() ??
          'Thank you for your payment',
      emailApiKey: settingsMap['email_api_key']?.toString(),
      emailDomain: settingsMap['email_domain']?.toString(),
      emailSenderEmail: settingsMap['email_sender_email']?.toString(),
      emailSenderName: settingsMap['email_sender_name']?.toString(),
      fcmServerKey: settingsMap['fcm_server_key']?.toString(),
      appVersion: settingsMap['app_version']?.toString() ?? '1.0.0',
      minimumRequiredVersion:
          settingsMap['minimum_required_version']?.toString() ?? '1.0.0',
      forceUpdate: settingsMap['force_update']?.toString().toLowerCase() == 'true',
      updateTitle: settingsMap['update_title']?.toString(),
      updateMessage: settingsMap['update_message']?.toString(),
      iosMinVersion: settingsMap['ios_min_version']?.toString(),
      androidMinVersion: settingsMap['android_min_version']?.toString(),
    );
  }

  /// Parse warning thresholds from string or list
  static List<double> _parseWarningThresholds(dynamic value) {
    if (value == null) return [200000, 350000];
    if (value is List) {
      return value.map((e) => double.parse(e.toString())).toList();
    }
    if (value is String) {
      // Handle JSON array string like "[200000, 350000]"
      try {
        final cleaned = value.replaceAll('[', '').replaceAll(']', '');
        return cleaned
            .split(',')
            .map((e) => double.parse(e.trim()))
            .toList();
      } catch (e) {
        return [200000, 350000];
      }
    }
    return [200000, 350000];
  }

  SystemSettingsEntity toEntity() {
    return SystemSettingsEntity(
      dailyDeedTarget: dailyDeedTarget,
      penaltyPerDeed: penaltyPerDeed,
      gracePeriodHours: gracePeriodHours,
      trainingPeriodDays: trainingPeriodDays,
      autoDeactivationThreshold: autoDeactivationThreshold,
      warningThresholds: warningThresholds,
      organizationName: organizationName,
      receiptFooterText: receiptFooterText,
      emailApiKey: emailApiKey,
      emailDomain: emailDomain,
      emailSenderEmail: emailSenderEmail,
      emailSenderName: emailSenderName,
      fcmServerKey: fcmServerKey,
      appVersion: appVersion,
      minimumRequiredVersion: minimumRequiredVersion,
      forceUpdate: forceUpdate,
      updateTitle: updateTitle,
      updateMessage: updateMessage,
      iosMinVersion: iosMinVersion,
      androidMinVersion: androidMinVersion,
    );
  }

  /// Convert to map for database update
  Map<String, dynamic> toSettingsMap() {
    return {
      'daily_deed_target': dailyDeedTarget.toString(),
      'penalty_per_deed': penaltyPerDeed.toString(),
      'grace_period_hours': gracePeriodHours.toString(),
      'training_period_days': trainingPeriodDays.toString(),
      'auto_deactivation_threshold': autoDeactivationThreshold.toString(),
      'warning_thresholds': warningThresholds.toString(),
      'organization_name': organizationName,
      'receipt_footer_text': receiptFooterText,
      if (emailApiKey != null) 'email_api_key': emailApiKey!,
      if (emailDomain != null) 'email_domain': emailDomain!,
      if (emailSenderEmail != null) 'email_sender_email': emailSenderEmail!,
      if (emailSenderName != null) 'email_sender_name': emailSenderName!,
      if (fcmServerKey != null) 'fcm_server_key': fcmServerKey!,
      'app_version': appVersion,
      'minimum_required_version': minimumRequiredVersion,
      'force_update': forceUpdate.toString(),
      if (updateTitle != null) 'update_title': updateTitle!,
      if (updateMessage != null) 'update_message': updateMessage!,
      if (iosMinVersion != null) 'ios_min_version': iosMinVersion!,
      if (androidMinVersion != null) 'android_min_version': androidMinVersion!,
    };
  }
}
