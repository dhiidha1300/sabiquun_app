// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SystemSettingsModel _$SystemSettingsModelFromJson(Map<String, dynamic> json) {
  return _SystemSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$SystemSettingsModel {
  @JsonKey(name: 'daily_deed_target')
  int get dailyDeedTarget => throw _privateConstructorUsedError;
  @JsonKey(name: 'penalty_per_deed')
  double get penaltyPerDeed => throw _privateConstructorUsedError;
  @JsonKey(name: 'grace_period_hours')
  int get gracePeriodHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'training_period_days')
  int get trainingPeriodDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'auto_deactivation_threshold')
  double get autoDeactivationThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'warning_thresholds')
  List<double> get warningThresholds => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_name')
  String get organizationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'receipt_footer_text')
  String get receiptFooterText => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_api_key')
  String? get emailApiKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_domain')
  String? get emailDomain => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_sender_email')
  String? get emailSenderEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_sender_name')
  String? get emailSenderName => throw _privateConstructorUsedError;
  @JsonKey(name: 'fcm_server_key')
  String? get fcmServerKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'app_version')
  String get appVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'minimum_required_version')
  String get minimumRequiredVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'force_update')
  bool get forceUpdate => throw _privateConstructorUsedError;
  @JsonKey(name: 'update_title')
  String? get updateTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'update_message')
  String? get updateMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'ios_min_version')
  String? get iosMinVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'android_min_version')
  String? get androidMinVersion => throw _privateConstructorUsedError;

  /// Serializes this SystemSettingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemSettingsModelCopyWith<SystemSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemSettingsModelCopyWith<$Res> {
  factory $SystemSettingsModelCopyWith(
    SystemSettingsModel value,
    $Res Function(SystemSettingsModel) then,
  ) = _$SystemSettingsModelCopyWithImpl<$Res, SystemSettingsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'daily_deed_target') int dailyDeedTarget,
    @JsonKey(name: 'penalty_per_deed') double penaltyPerDeed,
    @JsonKey(name: 'grace_period_hours') int gracePeriodHours,
    @JsonKey(name: 'training_period_days') int trainingPeriodDays,
    @JsonKey(name: 'auto_deactivation_threshold')
    double autoDeactivationThreshold,
    @JsonKey(name: 'warning_thresholds') List<double> warningThresholds,
    @JsonKey(name: 'organization_name') String organizationName,
    @JsonKey(name: 'receipt_footer_text') String receiptFooterText,
    @JsonKey(name: 'email_api_key') String? emailApiKey,
    @JsonKey(name: 'email_domain') String? emailDomain,
    @JsonKey(name: 'email_sender_email') String? emailSenderEmail,
    @JsonKey(name: 'email_sender_name') String? emailSenderName,
    @JsonKey(name: 'fcm_server_key') String? fcmServerKey,
    @JsonKey(name: 'app_version') String appVersion,
    @JsonKey(name: 'minimum_required_version') String minimumRequiredVersion,
    @JsonKey(name: 'force_update') bool forceUpdate,
    @JsonKey(name: 'update_title') String? updateTitle,
    @JsonKey(name: 'update_message') String? updateMessage,
    @JsonKey(name: 'ios_min_version') String? iosMinVersion,
    @JsonKey(name: 'android_min_version') String? androidMinVersion,
  });
}

/// @nodoc
class _$SystemSettingsModelCopyWithImpl<$Res, $Val extends SystemSettingsModel>
    implements $SystemSettingsModelCopyWith<$Res> {
  _$SystemSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyDeedTarget = null,
    Object? penaltyPerDeed = null,
    Object? gracePeriodHours = null,
    Object? trainingPeriodDays = null,
    Object? autoDeactivationThreshold = null,
    Object? warningThresholds = null,
    Object? organizationName = null,
    Object? receiptFooterText = null,
    Object? emailApiKey = freezed,
    Object? emailDomain = freezed,
    Object? emailSenderEmail = freezed,
    Object? emailSenderName = freezed,
    Object? fcmServerKey = freezed,
    Object? appVersion = null,
    Object? minimumRequiredVersion = null,
    Object? forceUpdate = null,
    Object? updateTitle = freezed,
    Object? updateMessage = freezed,
    Object? iosMinVersion = freezed,
    Object? androidMinVersion = freezed,
  }) {
    return _then(
      _value.copyWith(
            dailyDeedTarget: null == dailyDeedTarget
                ? _value.dailyDeedTarget
                : dailyDeedTarget // ignore: cast_nullable_to_non_nullable
                      as int,
            penaltyPerDeed: null == penaltyPerDeed
                ? _value.penaltyPerDeed
                : penaltyPerDeed // ignore: cast_nullable_to_non_nullable
                      as double,
            gracePeriodHours: null == gracePeriodHours
                ? _value.gracePeriodHours
                : gracePeriodHours // ignore: cast_nullable_to_non_nullable
                      as int,
            trainingPeriodDays: null == trainingPeriodDays
                ? _value.trainingPeriodDays
                : trainingPeriodDays // ignore: cast_nullable_to_non_nullable
                      as int,
            autoDeactivationThreshold: null == autoDeactivationThreshold
                ? _value.autoDeactivationThreshold
                : autoDeactivationThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            warningThresholds: null == warningThresholds
                ? _value.warningThresholds
                : warningThresholds // ignore: cast_nullable_to_non_nullable
                      as List<double>,
            organizationName: null == organizationName
                ? _value.organizationName
                : organizationName // ignore: cast_nullable_to_non_nullable
                      as String,
            receiptFooterText: null == receiptFooterText
                ? _value.receiptFooterText
                : receiptFooterText // ignore: cast_nullable_to_non_nullable
                      as String,
            emailApiKey: freezed == emailApiKey
                ? _value.emailApiKey
                : emailApiKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailDomain: freezed == emailDomain
                ? _value.emailDomain
                : emailDomain // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailSenderEmail: freezed == emailSenderEmail
                ? _value.emailSenderEmail
                : emailSenderEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailSenderName: freezed == emailSenderName
                ? _value.emailSenderName
                : emailSenderName // ignore: cast_nullable_to_non_nullable
                      as String?,
            fcmServerKey: freezed == fcmServerKey
                ? _value.fcmServerKey
                : fcmServerKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            appVersion: null == appVersion
                ? _value.appVersion
                : appVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            minimumRequiredVersion: null == minimumRequiredVersion
                ? _value.minimumRequiredVersion
                : minimumRequiredVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            forceUpdate: null == forceUpdate
                ? _value.forceUpdate
                : forceUpdate // ignore: cast_nullable_to_non_nullable
                      as bool,
            updateTitle: freezed == updateTitle
                ? _value.updateTitle
                : updateTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            updateMessage: freezed == updateMessage
                ? _value.updateMessage
                : updateMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            iosMinVersion: freezed == iosMinVersion
                ? _value.iosMinVersion
                : iosMinVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            androidMinVersion: freezed == androidMinVersion
                ? _value.androidMinVersion
                : androidMinVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SystemSettingsModelImplCopyWith<$Res>
    implements $SystemSettingsModelCopyWith<$Res> {
  factory _$$SystemSettingsModelImplCopyWith(
    _$SystemSettingsModelImpl value,
    $Res Function(_$SystemSettingsModelImpl) then,
  ) = __$$SystemSettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'daily_deed_target') int dailyDeedTarget,
    @JsonKey(name: 'penalty_per_deed') double penaltyPerDeed,
    @JsonKey(name: 'grace_period_hours') int gracePeriodHours,
    @JsonKey(name: 'training_period_days') int trainingPeriodDays,
    @JsonKey(name: 'auto_deactivation_threshold')
    double autoDeactivationThreshold,
    @JsonKey(name: 'warning_thresholds') List<double> warningThresholds,
    @JsonKey(name: 'organization_name') String organizationName,
    @JsonKey(name: 'receipt_footer_text') String receiptFooterText,
    @JsonKey(name: 'email_api_key') String? emailApiKey,
    @JsonKey(name: 'email_domain') String? emailDomain,
    @JsonKey(name: 'email_sender_email') String? emailSenderEmail,
    @JsonKey(name: 'email_sender_name') String? emailSenderName,
    @JsonKey(name: 'fcm_server_key') String? fcmServerKey,
    @JsonKey(name: 'app_version') String appVersion,
    @JsonKey(name: 'minimum_required_version') String minimumRequiredVersion,
    @JsonKey(name: 'force_update') bool forceUpdate,
    @JsonKey(name: 'update_title') String? updateTitle,
    @JsonKey(name: 'update_message') String? updateMessage,
    @JsonKey(name: 'ios_min_version') String? iosMinVersion,
    @JsonKey(name: 'android_min_version') String? androidMinVersion,
  });
}

/// @nodoc
class __$$SystemSettingsModelImplCopyWithImpl<$Res>
    extends _$SystemSettingsModelCopyWithImpl<$Res, _$SystemSettingsModelImpl>
    implements _$$SystemSettingsModelImplCopyWith<$Res> {
  __$$SystemSettingsModelImplCopyWithImpl(
    _$SystemSettingsModelImpl _value,
    $Res Function(_$SystemSettingsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyDeedTarget = null,
    Object? penaltyPerDeed = null,
    Object? gracePeriodHours = null,
    Object? trainingPeriodDays = null,
    Object? autoDeactivationThreshold = null,
    Object? warningThresholds = null,
    Object? organizationName = null,
    Object? receiptFooterText = null,
    Object? emailApiKey = freezed,
    Object? emailDomain = freezed,
    Object? emailSenderEmail = freezed,
    Object? emailSenderName = freezed,
    Object? fcmServerKey = freezed,
    Object? appVersion = null,
    Object? minimumRequiredVersion = null,
    Object? forceUpdate = null,
    Object? updateTitle = freezed,
    Object? updateMessage = freezed,
    Object? iosMinVersion = freezed,
    Object? androidMinVersion = freezed,
  }) {
    return _then(
      _$SystemSettingsModelImpl(
        dailyDeedTarget: null == dailyDeedTarget
            ? _value.dailyDeedTarget
            : dailyDeedTarget // ignore: cast_nullable_to_non_nullable
                  as int,
        penaltyPerDeed: null == penaltyPerDeed
            ? _value.penaltyPerDeed
            : penaltyPerDeed // ignore: cast_nullable_to_non_nullable
                  as double,
        gracePeriodHours: null == gracePeriodHours
            ? _value.gracePeriodHours
            : gracePeriodHours // ignore: cast_nullable_to_non_nullable
                  as int,
        trainingPeriodDays: null == trainingPeriodDays
            ? _value.trainingPeriodDays
            : trainingPeriodDays // ignore: cast_nullable_to_non_nullable
                  as int,
        autoDeactivationThreshold: null == autoDeactivationThreshold
            ? _value.autoDeactivationThreshold
            : autoDeactivationThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        warningThresholds: null == warningThresholds
            ? _value._warningThresholds
            : warningThresholds // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        organizationName: null == organizationName
            ? _value.organizationName
            : organizationName // ignore: cast_nullable_to_non_nullable
                  as String,
        receiptFooterText: null == receiptFooterText
            ? _value.receiptFooterText
            : receiptFooterText // ignore: cast_nullable_to_non_nullable
                  as String,
        emailApiKey: freezed == emailApiKey
            ? _value.emailApiKey
            : emailApiKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailDomain: freezed == emailDomain
            ? _value.emailDomain
            : emailDomain // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailSenderEmail: freezed == emailSenderEmail
            ? _value.emailSenderEmail
            : emailSenderEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailSenderName: freezed == emailSenderName
            ? _value.emailSenderName
            : emailSenderName // ignore: cast_nullable_to_non_nullable
                  as String?,
        fcmServerKey: freezed == fcmServerKey
            ? _value.fcmServerKey
            : fcmServerKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        appVersion: null == appVersion
            ? _value.appVersion
            : appVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        minimumRequiredVersion: null == minimumRequiredVersion
            ? _value.minimumRequiredVersion
            : minimumRequiredVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        forceUpdate: null == forceUpdate
            ? _value.forceUpdate
            : forceUpdate // ignore: cast_nullable_to_non_nullable
                  as bool,
        updateTitle: freezed == updateTitle
            ? _value.updateTitle
            : updateTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        updateMessage: freezed == updateMessage
            ? _value.updateMessage
            : updateMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        iosMinVersion: freezed == iosMinVersion
            ? _value.iosMinVersion
            : iosMinVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        androidMinVersion: freezed == androidMinVersion
            ? _value.androidMinVersion
            : androidMinVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemSettingsModelImpl extends _SystemSettingsModel {
  const _$SystemSettingsModelImpl({
    @JsonKey(name: 'daily_deed_target') required this.dailyDeedTarget,
    @JsonKey(name: 'penalty_per_deed') required this.penaltyPerDeed,
    @JsonKey(name: 'grace_period_hours') required this.gracePeriodHours,
    @JsonKey(name: 'training_period_days') required this.trainingPeriodDays,
    @JsonKey(name: 'auto_deactivation_threshold')
    required this.autoDeactivationThreshold,
    @JsonKey(name: 'warning_thresholds')
    required final List<double> warningThresholds,
    @JsonKey(name: 'organization_name') required this.organizationName,
    @JsonKey(name: 'receipt_footer_text') required this.receiptFooterText,
    @JsonKey(name: 'email_api_key') this.emailApiKey,
    @JsonKey(name: 'email_domain') this.emailDomain,
    @JsonKey(name: 'email_sender_email') this.emailSenderEmail,
    @JsonKey(name: 'email_sender_name') this.emailSenderName,
    @JsonKey(name: 'fcm_server_key') this.fcmServerKey,
    @JsonKey(name: 'app_version') required this.appVersion,
    @JsonKey(name: 'minimum_required_version')
    required this.minimumRequiredVersion,
    @JsonKey(name: 'force_update') required this.forceUpdate,
    @JsonKey(name: 'update_title') this.updateTitle,
    @JsonKey(name: 'update_message') this.updateMessage,
    @JsonKey(name: 'ios_min_version') this.iosMinVersion,
    @JsonKey(name: 'android_min_version') this.androidMinVersion,
  }) : _warningThresholds = warningThresholds,
       super._();

  factory _$SystemSettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemSettingsModelImplFromJson(json);

  @override
  @JsonKey(name: 'daily_deed_target')
  final int dailyDeedTarget;
  @override
  @JsonKey(name: 'penalty_per_deed')
  final double penaltyPerDeed;
  @override
  @JsonKey(name: 'grace_period_hours')
  final int gracePeriodHours;
  @override
  @JsonKey(name: 'training_period_days')
  final int trainingPeriodDays;
  @override
  @JsonKey(name: 'auto_deactivation_threshold')
  final double autoDeactivationThreshold;
  final List<double> _warningThresholds;
  @override
  @JsonKey(name: 'warning_thresholds')
  List<double> get warningThresholds {
    if (_warningThresholds is EqualUnmodifiableListView)
      return _warningThresholds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warningThresholds);
  }

  @override
  @JsonKey(name: 'organization_name')
  final String organizationName;
  @override
  @JsonKey(name: 'receipt_footer_text')
  final String receiptFooterText;
  @override
  @JsonKey(name: 'email_api_key')
  final String? emailApiKey;
  @override
  @JsonKey(name: 'email_domain')
  final String? emailDomain;
  @override
  @JsonKey(name: 'email_sender_email')
  final String? emailSenderEmail;
  @override
  @JsonKey(name: 'email_sender_name')
  final String? emailSenderName;
  @override
  @JsonKey(name: 'fcm_server_key')
  final String? fcmServerKey;
  @override
  @JsonKey(name: 'app_version')
  final String appVersion;
  @override
  @JsonKey(name: 'minimum_required_version')
  final String minimumRequiredVersion;
  @override
  @JsonKey(name: 'force_update')
  final bool forceUpdate;
  @override
  @JsonKey(name: 'update_title')
  final String? updateTitle;
  @override
  @JsonKey(name: 'update_message')
  final String? updateMessage;
  @override
  @JsonKey(name: 'ios_min_version')
  final String? iosMinVersion;
  @override
  @JsonKey(name: 'android_min_version')
  final String? androidMinVersion;

  @override
  String toString() {
    return 'SystemSettingsModel(dailyDeedTarget: $dailyDeedTarget, penaltyPerDeed: $penaltyPerDeed, gracePeriodHours: $gracePeriodHours, trainingPeriodDays: $trainingPeriodDays, autoDeactivationThreshold: $autoDeactivationThreshold, warningThresholds: $warningThresholds, organizationName: $organizationName, receiptFooterText: $receiptFooterText, emailApiKey: $emailApiKey, emailDomain: $emailDomain, emailSenderEmail: $emailSenderEmail, emailSenderName: $emailSenderName, fcmServerKey: $fcmServerKey, appVersion: $appVersion, minimumRequiredVersion: $minimumRequiredVersion, forceUpdate: $forceUpdate, updateTitle: $updateTitle, updateMessage: $updateMessage, iosMinVersion: $iosMinVersion, androidMinVersion: $androidMinVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemSettingsModelImpl &&
            (identical(other.dailyDeedTarget, dailyDeedTarget) ||
                other.dailyDeedTarget == dailyDeedTarget) &&
            (identical(other.penaltyPerDeed, penaltyPerDeed) ||
                other.penaltyPerDeed == penaltyPerDeed) &&
            (identical(other.gracePeriodHours, gracePeriodHours) ||
                other.gracePeriodHours == gracePeriodHours) &&
            (identical(other.trainingPeriodDays, trainingPeriodDays) ||
                other.trainingPeriodDays == trainingPeriodDays) &&
            (identical(
                  other.autoDeactivationThreshold,
                  autoDeactivationThreshold,
                ) ||
                other.autoDeactivationThreshold == autoDeactivationThreshold) &&
            const DeepCollectionEquality().equals(
              other._warningThresholds,
              _warningThresholds,
            ) &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName) &&
            (identical(other.receiptFooterText, receiptFooterText) ||
                other.receiptFooterText == receiptFooterText) &&
            (identical(other.emailApiKey, emailApiKey) ||
                other.emailApiKey == emailApiKey) &&
            (identical(other.emailDomain, emailDomain) ||
                other.emailDomain == emailDomain) &&
            (identical(other.emailSenderEmail, emailSenderEmail) ||
                other.emailSenderEmail == emailSenderEmail) &&
            (identical(other.emailSenderName, emailSenderName) ||
                other.emailSenderName == emailSenderName) &&
            (identical(other.fcmServerKey, fcmServerKey) ||
                other.fcmServerKey == fcmServerKey) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.minimumRequiredVersion, minimumRequiredVersion) ||
                other.minimumRequiredVersion == minimumRequiredVersion) &&
            (identical(other.forceUpdate, forceUpdate) ||
                other.forceUpdate == forceUpdate) &&
            (identical(other.updateTitle, updateTitle) ||
                other.updateTitle == updateTitle) &&
            (identical(other.updateMessage, updateMessage) ||
                other.updateMessage == updateMessage) &&
            (identical(other.iosMinVersion, iosMinVersion) ||
                other.iosMinVersion == iosMinVersion) &&
            (identical(other.androidMinVersion, androidMinVersion) ||
                other.androidMinVersion == androidMinVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    dailyDeedTarget,
    penaltyPerDeed,
    gracePeriodHours,
    trainingPeriodDays,
    autoDeactivationThreshold,
    const DeepCollectionEquality().hash(_warningThresholds),
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
  ]);

  /// Create a copy of SystemSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemSettingsModelImplCopyWith<_$SystemSettingsModelImpl> get copyWith =>
      __$$SystemSettingsModelImplCopyWithImpl<_$SystemSettingsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemSettingsModelImplToJson(this);
  }
}

abstract class _SystemSettingsModel extends SystemSettingsModel {
  const factory _SystemSettingsModel({
    @JsonKey(name: 'daily_deed_target') required final int dailyDeedTarget,
    @JsonKey(name: 'penalty_per_deed') required final double penaltyPerDeed,
    @JsonKey(name: 'grace_period_hours') required final int gracePeriodHours,
    @JsonKey(name: 'training_period_days')
    required final int trainingPeriodDays,
    @JsonKey(name: 'auto_deactivation_threshold')
    required final double autoDeactivationThreshold,
    @JsonKey(name: 'warning_thresholds')
    required final List<double> warningThresholds,
    @JsonKey(name: 'organization_name') required final String organizationName,
    @JsonKey(name: 'receipt_footer_text')
    required final String receiptFooterText,
    @JsonKey(name: 'email_api_key') final String? emailApiKey,
    @JsonKey(name: 'email_domain') final String? emailDomain,
    @JsonKey(name: 'email_sender_email') final String? emailSenderEmail,
    @JsonKey(name: 'email_sender_name') final String? emailSenderName,
    @JsonKey(name: 'fcm_server_key') final String? fcmServerKey,
    @JsonKey(name: 'app_version') required final String appVersion,
    @JsonKey(name: 'minimum_required_version')
    required final String minimumRequiredVersion,
    @JsonKey(name: 'force_update') required final bool forceUpdate,
    @JsonKey(name: 'update_title') final String? updateTitle,
    @JsonKey(name: 'update_message') final String? updateMessage,
    @JsonKey(name: 'ios_min_version') final String? iosMinVersion,
    @JsonKey(name: 'android_min_version') final String? androidMinVersion,
  }) = _$SystemSettingsModelImpl;
  const _SystemSettingsModel._() : super._();

  factory _SystemSettingsModel.fromJson(Map<String, dynamic> json) =
      _$SystemSettingsModelImpl.fromJson;

  @override
  @JsonKey(name: 'daily_deed_target')
  int get dailyDeedTarget;
  @override
  @JsonKey(name: 'penalty_per_deed')
  double get penaltyPerDeed;
  @override
  @JsonKey(name: 'grace_period_hours')
  int get gracePeriodHours;
  @override
  @JsonKey(name: 'training_period_days')
  int get trainingPeriodDays;
  @override
  @JsonKey(name: 'auto_deactivation_threshold')
  double get autoDeactivationThreshold;
  @override
  @JsonKey(name: 'warning_thresholds')
  List<double> get warningThresholds;
  @override
  @JsonKey(name: 'organization_name')
  String get organizationName;
  @override
  @JsonKey(name: 'receipt_footer_text')
  String get receiptFooterText;
  @override
  @JsonKey(name: 'email_api_key')
  String? get emailApiKey;
  @override
  @JsonKey(name: 'email_domain')
  String? get emailDomain;
  @override
  @JsonKey(name: 'email_sender_email')
  String? get emailSenderEmail;
  @override
  @JsonKey(name: 'email_sender_name')
  String? get emailSenderName;
  @override
  @JsonKey(name: 'fcm_server_key')
  String? get fcmServerKey;
  @override
  @JsonKey(name: 'app_version')
  String get appVersion;
  @override
  @JsonKey(name: 'minimum_required_version')
  String get minimumRequiredVersion;
  @override
  @JsonKey(name: 'force_update')
  bool get forceUpdate;
  @override
  @JsonKey(name: 'update_title')
  String? get updateTitle;
  @override
  @JsonKey(name: 'update_message')
  String? get updateMessage;
  @override
  @JsonKey(name: 'ios_min_version')
  String? get iosMinVersion;
  @override
  @JsonKey(name: 'android_min_version')
  String? get androidMinVersion;

  /// Create a copy of SystemSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemSettingsModelImplCopyWith<_$SystemSettingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
