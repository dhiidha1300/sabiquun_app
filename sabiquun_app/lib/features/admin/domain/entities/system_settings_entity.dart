import 'package:equatable/equatable.dart';

/// Entity representing system-wide settings
class SystemSettingsEntity extends Equatable {
  // Deed & Penalty Configuration
  final int dailyDeedTarget;
  final double penaltyPerDeed;
  final int gracePeriodHours;
  final int trainingPeriodDays;
  final double autoDeactivationThreshold;
  final List<double> warningThresholds;

  // Payment Configuration
  final String organizationName;
  final String receiptFooterText;

  // Notification Configuration
  final String? emailApiKey;
  final String? emailDomain;
  final String? emailSenderEmail;
  final String? emailSenderName;
  final String? fcmServerKey;

  // App Version Control
  final String appVersion;
  final String minimumRequiredVersion;
  final bool forceUpdate;
  final String? updateTitle;
  final String? updateMessage;
  final String? iosMinVersion;
  final String? androidMinVersion;

  const SystemSettingsEntity({
    required this.dailyDeedTarget,
    required this.penaltyPerDeed,
    required this.gracePeriodHours,
    required this.trainingPeriodDays,
    required this.autoDeactivationThreshold,
    required this.warningThresholds,
    required this.organizationName,
    required this.receiptFooterText,
    this.emailApiKey,
    this.emailDomain,
    this.emailSenderEmail,
    this.emailSenderName,
    this.fcmServerKey,
    required this.appVersion,
    required this.minimumRequiredVersion,
    required this.forceUpdate,
    this.updateTitle,
    this.updateMessage,
    this.iosMinVersion,
    this.androidMinVersion,
  });

  /// Get formatted penalty per deed
  String get formattedPenaltyPerDeed => '${penaltyPerDeed.toStringAsFixed(0)} Shillings';

  /// Get formatted auto-deactivation threshold
  String get formattedAutoDeactivationThreshold =>
      '${autoDeactivationThreshold.toStringAsFixed(0)} Shillings';

  /// Get first warning threshold
  double? get firstWarningThreshold =>
      warningThresholds.isNotEmpty ? warningThresholds[0] : null;

  /// Get final warning threshold
  double? get finalWarningThreshold =>
      warningThresholds.length > 1 ? warningThresholds[1] : null;

  @override
  List<Object?> get props => [
        dailyDeedTarget,
        penaltyPerDeed,
        gracePeriodHours,
        trainingPeriodDays,
        autoDeactivationThreshold,
        warningThresholds,
        organizationName,
        receiptFooterText,
        emailApiKey,
        emailDomain,
        emailSenderEmail,
        emailSenderName,
        fcmServerKey,
        appVersion,
        minimumRequiredVersion,
        forceUpdate,
        updateTitle,
        updateMessage,
        iosMinVersion,
        androidMinVersion,
      ];
}
