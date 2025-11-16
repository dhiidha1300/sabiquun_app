// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_report_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserReportSummaryModel _$UserReportSummaryModelFromJson(
  Map<String, dynamic> json,
) {
  return _UserReportSummaryModel.fromJson(json);
}

/// @nodoc
mixin _$UserReportSummaryModel {
  String get userId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;
  String get membershipStatus => throw _privateConstructorUsedError;
  DateTime? get memberSince => throw _privateConstructorUsedError;
  int get todayDeeds => throw _privateConstructorUsedError;
  int get todayTarget => throw _privateConstructorUsedError;
  bool get hasSubmittedToday => throw _privateConstructorUsedError;
  DateTime? get lastReportTime => throw _privateConstructorUsedError;
  double get complianceRate => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get totalReports => throw _privateConstructorUsedError;
  double get currentBalance => throw _privateConstructorUsedError;
  bool get isAtRisk => throw _privateConstructorUsedError;
  int get daysWithoutReport => throw _privateConstructorUsedError;

  /// Serializes this UserReportSummaryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserReportSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserReportSummaryModelCopyWith<UserReportSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserReportSummaryModelCopyWith<$Res> {
  factory $UserReportSummaryModelCopyWith(
    UserReportSummaryModel value,
    $Res Function(UserReportSummaryModel) then,
  ) = _$UserReportSummaryModelCopyWithImpl<$Res, UserReportSummaryModel>;
  @useResult
  $Res call({
    String userId,
    String fullName,
    String email,
    String? phoneNumber,
    String? profilePhotoUrl,
    String membershipStatus,
    DateTime? memberSince,
    int todayDeeds,
    int todayTarget,
    bool hasSubmittedToday,
    DateTime? lastReportTime,
    double complianceRate,
    int currentStreak,
    int totalReports,
    double currentBalance,
    bool isAtRisk,
    int daysWithoutReport,
  });
}

/// @nodoc
class _$UserReportSummaryModelCopyWithImpl<
  $Res,
  $Val extends UserReportSummaryModel
>
    implements $UserReportSummaryModelCopyWith<$Res> {
  _$UserReportSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserReportSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? fullName = null,
    Object? email = null,
    Object? phoneNumber = freezed,
    Object? profilePhotoUrl = freezed,
    Object? membershipStatus = null,
    Object? memberSince = freezed,
    Object? todayDeeds = null,
    Object? todayTarget = null,
    Object? hasSubmittedToday = null,
    Object? lastReportTime = freezed,
    Object? complianceRate = null,
    Object? currentStreak = null,
    Object? totalReports = null,
    Object? currentBalance = null,
    Object? isAtRisk = null,
    Object? daysWithoutReport = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            profilePhotoUrl: freezed == profilePhotoUrl
                ? _value.profilePhotoUrl
                : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            membershipStatus: null == membershipStatus
                ? _value.membershipStatus
                : membershipStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            memberSince: freezed == memberSince
                ? _value.memberSince
                : memberSince // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            todayDeeds: null == todayDeeds
                ? _value.todayDeeds
                : todayDeeds // ignore: cast_nullable_to_non_nullable
                      as int,
            todayTarget: null == todayTarget
                ? _value.todayTarget
                : todayTarget // ignore: cast_nullable_to_non_nullable
                      as int,
            hasSubmittedToday: null == hasSubmittedToday
                ? _value.hasSubmittedToday
                : hasSubmittedToday // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastReportTime: freezed == lastReportTime
                ? _value.lastReportTime
                : lastReportTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            complianceRate: null == complianceRate
                ? _value.complianceRate
                : complianceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            totalReports: null == totalReports
                ? _value.totalReports
                : totalReports // ignore: cast_nullable_to_non_nullable
                      as int,
            currentBalance: null == currentBalance
                ? _value.currentBalance
                : currentBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            isAtRisk: null == isAtRisk
                ? _value.isAtRisk
                : isAtRisk // ignore: cast_nullable_to_non_nullable
                      as bool,
            daysWithoutReport: null == daysWithoutReport
                ? _value.daysWithoutReport
                : daysWithoutReport // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserReportSummaryModelImplCopyWith<$Res>
    implements $UserReportSummaryModelCopyWith<$Res> {
  factory _$$UserReportSummaryModelImplCopyWith(
    _$UserReportSummaryModelImpl value,
    $Res Function(_$UserReportSummaryModelImpl) then,
  ) = __$$UserReportSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String fullName,
    String email,
    String? phoneNumber,
    String? profilePhotoUrl,
    String membershipStatus,
    DateTime? memberSince,
    int todayDeeds,
    int todayTarget,
    bool hasSubmittedToday,
    DateTime? lastReportTime,
    double complianceRate,
    int currentStreak,
    int totalReports,
    double currentBalance,
    bool isAtRisk,
    int daysWithoutReport,
  });
}

/// @nodoc
class __$$UserReportSummaryModelImplCopyWithImpl<$Res>
    extends
        _$UserReportSummaryModelCopyWithImpl<$Res, _$UserReportSummaryModelImpl>
    implements _$$UserReportSummaryModelImplCopyWith<$Res> {
  __$$UserReportSummaryModelImplCopyWithImpl(
    _$UserReportSummaryModelImpl _value,
    $Res Function(_$UserReportSummaryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserReportSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? fullName = null,
    Object? email = null,
    Object? phoneNumber = freezed,
    Object? profilePhotoUrl = freezed,
    Object? membershipStatus = null,
    Object? memberSince = freezed,
    Object? todayDeeds = null,
    Object? todayTarget = null,
    Object? hasSubmittedToday = null,
    Object? lastReportTime = freezed,
    Object? complianceRate = null,
    Object? currentStreak = null,
    Object? totalReports = null,
    Object? currentBalance = null,
    Object? isAtRisk = null,
    Object? daysWithoutReport = null,
  }) {
    return _then(
      _$UserReportSummaryModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        profilePhotoUrl: freezed == profilePhotoUrl
            ? _value.profilePhotoUrl
            : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        membershipStatus: null == membershipStatus
            ? _value.membershipStatus
            : membershipStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        memberSince: freezed == memberSince
            ? _value.memberSince
            : memberSince // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        todayDeeds: null == todayDeeds
            ? _value.todayDeeds
            : todayDeeds // ignore: cast_nullable_to_non_nullable
                  as int,
        todayTarget: null == todayTarget
            ? _value.todayTarget
            : todayTarget // ignore: cast_nullable_to_non_nullable
                  as int,
        hasSubmittedToday: null == hasSubmittedToday
            ? _value.hasSubmittedToday
            : hasSubmittedToday // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastReportTime: freezed == lastReportTime
            ? _value.lastReportTime
            : lastReportTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        complianceRate: null == complianceRate
            ? _value.complianceRate
            : complianceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        totalReports: null == totalReports
            ? _value.totalReports
            : totalReports // ignore: cast_nullable_to_non_nullable
                  as int,
        currentBalance: null == currentBalance
            ? _value.currentBalance
            : currentBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        isAtRisk: null == isAtRisk
            ? _value.isAtRisk
            : isAtRisk // ignore: cast_nullable_to_non_nullable
                  as bool,
        daysWithoutReport: null == daysWithoutReport
            ? _value.daysWithoutReport
            : daysWithoutReport // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserReportSummaryModelImpl extends _UserReportSummaryModel {
  const _$UserReportSummaryModelImpl({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
    required this.membershipStatus,
    this.memberSince,
    required this.todayDeeds,
    required this.todayTarget,
    required this.hasSubmittedToday,
    this.lastReportTime,
    required this.complianceRate,
    required this.currentStreak,
    required this.totalReports,
    required this.currentBalance,
    required this.isAtRisk,
    required this.daysWithoutReport,
  }) : super._();

  factory _$UserReportSummaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserReportSummaryModelImplFromJson(json);

  @override
  final String userId;
  @override
  final String fullName;
  @override
  final String email;
  @override
  final String? phoneNumber;
  @override
  final String? profilePhotoUrl;
  @override
  final String membershipStatus;
  @override
  final DateTime? memberSince;
  @override
  final int todayDeeds;
  @override
  final int todayTarget;
  @override
  final bool hasSubmittedToday;
  @override
  final DateTime? lastReportTime;
  @override
  final double complianceRate;
  @override
  final int currentStreak;
  @override
  final int totalReports;
  @override
  final double currentBalance;
  @override
  final bool isAtRisk;
  @override
  final int daysWithoutReport;

  @override
  String toString() {
    return 'UserReportSummaryModel(userId: $userId, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, profilePhotoUrl: $profilePhotoUrl, membershipStatus: $membershipStatus, memberSince: $memberSince, todayDeeds: $todayDeeds, todayTarget: $todayTarget, hasSubmittedToday: $hasSubmittedToday, lastReportTime: $lastReportTime, complianceRate: $complianceRate, currentStreak: $currentStreak, totalReports: $totalReports, currentBalance: $currentBalance, isAtRisk: $isAtRisk, daysWithoutReport: $daysWithoutReport)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserReportSummaryModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl) &&
            (identical(other.membershipStatus, membershipStatus) ||
                other.membershipStatus == membershipStatus) &&
            (identical(other.memberSince, memberSince) ||
                other.memberSince == memberSince) &&
            (identical(other.todayDeeds, todayDeeds) ||
                other.todayDeeds == todayDeeds) &&
            (identical(other.todayTarget, todayTarget) ||
                other.todayTarget == todayTarget) &&
            (identical(other.hasSubmittedToday, hasSubmittedToday) ||
                other.hasSubmittedToday == hasSubmittedToday) &&
            (identical(other.lastReportTime, lastReportTime) ||
                other.lastReportTime == lastReportTime) &&
            (identical(other.complianceRate, complianceRate) ||
                other.complianceRate == complianceRate) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.totalReports, totalReports) ||
                other.totalReports == totalReports) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.isAtRisk, isAtRisk) ||
                other.isAtRisk == isAtRisk) &&
            (identical(other.daysWithoutReport, daysWithoutReport) ||
                other.daysWithoutReport == daysWithoutReport));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    fullName,
    email,
    phoneNumber,
    profilePhotoUrl,
    membershipStatus,
    memberSince,
    todayDeeds,
    todayTarget,
    hasSubmittedToday,
    lastReportTime,
    complianceRate,
    currentStreak,
    totalReports,
    currentBalance,
    isAtRisk,
    daysWithoutReport,
  );

  /// Create a copy of UserReportSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserReportSummaryModelImplCopyWith<_$UserReportSummaryModelImpl>
  get copyWith =>
      __$$UserReportSummaryModelImplCopyWithImpl<_$UserReportSummaryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserReportSummaryModelImplToJson(this);
  }
}

abstract class _UserReportSummaryModel extends UserReportSummaryModel {
  const factory _UserReportSummaryModel({
    required final String userId,
    required final String fullName,
    required final String email,
    final String? phoneNumber,
    final String? profilePhotoUrl,
    required final String membershipStatus,
    final DateTime? memberSince,
    required final int todayDeeds,
    required final int todayTarget,
    required final bool hasSubmittedToday,
    final DateTime? lastReportTime,
    required final double complianceRate,
    required final int currentStreak,
    required final int totalReports,
    required final double currentBalance,
    required final bool isAtRisk,
    required final int daysWithoutReport,
  }) = _$UserReportSummaryModelImpl;
  const _UserReportSummaryModel._() : super._();

  factory _UserReportSummaryModel.fromJson(Map<String, dynamic> json) =
      _$UserReportSummaryModelImpl.fromJson;

  @override
  String get userId;
  @override
  String get fullName;
  @override
  String get email;
  @override
  String? get phoneNumber;
  @override
  String? get profilePhotoUrl;
  @override
  String get membershipStatus;
  @override
  DateTime? get memberSince;
  @override
  int get todayDeeds;
  @override
  int get todayTarget;
  @override
  bool get hasSubmittedToday;
  @override
  DateTime? get lastReportTime;
  @override
  double get complianceRate;
  @override
  int get currentStreak;
  @override
  int get totalReports;
  @override
  double get currentBalance;
  @override
  bool get isAtRisk;
  @override
  int get daysWithoutReport;

  /// Create a copy of UserReportSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserReportSummaryModelImplCopyWith<_$UserReportSummaryModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
