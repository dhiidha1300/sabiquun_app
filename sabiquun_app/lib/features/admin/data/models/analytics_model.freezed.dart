// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnalyticsModel _$AnalyticsModelFromJson(Map<String, dynamic> json) {
  return _AnalyticsModel.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsModel {
  UserMetricsModel get userMetrics => throw _privateConstructorUsedError;
  DeedMetricsModel get deedMetrics => throw _privateConstructorUsedError;
  FinancialMetricsModel get financialMetrics =>
      throw _privateConstructorUsedError;
  EngagementMetricsModel get engagementMetrics =>
      throw _privateConstructorUsedError;
  ExcuseMetricsModel get excuseMetrics => throw _privateConstructorUsedError;

  /// Serializes this AnalyticsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalyticsModelCopyWith<AnalyticsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsModelCopyWith<$Res> {
  factory $AnalyticsModelCopyWith(
    AnalyticsModel value,
    $Res Function(AnalyticsModel) then,
  ) = _$AnalyticsModelCopyWithImpl<$Res, AnalyticsModel>;
  @useResult
  $Res call({
    UserMetricsModel userMetrics,
    DeedMetricsModel deedMetrics,
    FinancialMetricsModel financialMetrics,
    EngagementMetricsModel engagementMetrics,
    ExcuseMetricsModel excuseMetrics,
  });

  $UserMetricsModelCopyWith<$Res> get userMetrics;
  $DeedMetricsModelCopyWith<$Res> get deedMetrics;
  $FinancialMetricsModelCopyWith<$Res> get financialMetrics;
  $EngagementMetricsModelCopyWith<$Res> get engagementMetrics;
  $ExcuseMetricsModelCopyWith<$Res> get excuseMetrics;
}

/// @nodoc
class _$AnalyticsModelCopyWithImpl<$Res, $Val extends AnalyticsModel>
    implements $AnalyticsModelCopyWith<$Res> {
  _$AnalyticsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userMetrics = null,
    Object? deedMetrics = null,
    Object? financialMetrics = null,
    Object? engagementMetrics = null,
    Object? excuseMetrics = null,
  }) {
    return _then(
      _value.copyWith(
            userMetrics: null == userMetrics
                ? _value.userMetrics
                : userMetrics // ignore: cast_nullable_to_non_nullable
                      as UserMetricsModel,
            deedMetrics: null == deedMetrics
                ? _value.deedMetrics
                : deedMetrics // ignore: cast_nullable_to_non_nullable
                      as DeedMetricsModel,
            financialMetrics: null == financialMetrics
                ? _value.financialMetrics
                : financialMetrics // ignore: cast_nullable_to_non_nullable
                      as FinancialMetricsModel,
            engagementMetrics: null == engagementMetrics
                ? _value.engagementMetrics
                : engagementMetrics // ignore: cast_nullable_to_non_nullable
                      as EngagementMetricsModel,
            excuseMetrics: null == excuseMetrics
                ? _value.excuseMetrics
                : excuseMetrics // ignore: cast_nullable_to_non_nullable
                      as ExcuseMetricsModel,
          )
          as $Val,
    );
  }

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserMetricsModelCopyWith<$Res> get userMetrics {
    return $UserMetricsModelCopyWith<$Res>(_value.userMetrics, (value) {
      return _then(_value.copyWith(userMetrics: value) as $Val);
    });
  }

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeedMetricsModelCopyWith<$Res> get deedMetrics {
    return $DeedMetricsModelCopyWith<$Res>(_value.deedMetrics, (value) {
      return _then(_value.copyWith(deedMetrics: value) as $Val);
    });
  }

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FinancialMetricsModelCopyWith<$Res> get financialMetrics {
    return $FinancialMetricsModelCopyWith<$Res>(_value.financialMetrics, (
      value,
    ) {
      return _then(_value.copyWith(financialMetrics: value) as $Val);
    });
  }

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EngagementMetricsModelCopyWith<$Res> get engagementMetrics {
    return $EngagementMetricsModelCopyWith<$Res>(_value.engagementMetrics, (
      value,
    ) {
      return _then(_value.copyWith(engagementMetrics: value) as $Val);
    });
  }

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExcuseMetricsModelCopyWith<$Res> get excuseMetrics {
    return $ExcuseMetricsModelCopyWith<$Res>(_value.excuseMetrics, (value) {
      return _then(_value.copyWith(excuseMetrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnalyticsModelImplCopyWith<$Res>
    implements $AnalyticsModelCopyWith<$Res> {
  factory _$$AnalyticsModelImplCopyWith(
    _$AnalyticsModelImpl value,
    $Res Function(_$AnalyticsModelImpl) then,
  ) = __$$AnalyticsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    UserMetricsModel userMetrics,
    DeedMetricsModel deedMetrics,
    FinancialMetricsModel financialMetrics,
    EngagementMetricsModel engagementMetrics,
    ExcuseMetricsModel excuseMetrics,
  });

  @override
  $UserMetricsModelCopyWith<$Res> get userMetrics;
  @override
  $DeedMetricsModelCopyWith<$Res> get deedMetrics;
  @override
  $FinancialMetricsModelCopyWith<$Res> get financialMetrics;
  @override
  $EngagementMetricsModelCopyWith<$Res> get engagementMetrics;
  @override
  $ExcuseMetricsModelCopyWith<$Res> get excuseMetrics;
}

/// @nodoc
class __$$AnalyticsModelImplCopyWithImpl<$Res>
    extends _$AnalyticsModelCopyWithImpl<$Res, _$AnalyticsModelImpl>
    implements _$$AnalyticsModelImplCopyWith<$Res> {
  __$$AnalyticsModelImplCopyWithImpl(
    _$AnalyticsModelImpl _value,
    $Res Function(_$AnalyticsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userMetrics = null,
    Object? deedMetrics = null,
    Object? financialMetrics = null,
    Object? engagementMetrics = null,
    Object? excuseMetrics = null,
  }) {
    return _then(
      _$AnalyticsModelImpl(
        userMetrics: null == userMetrics
            ? _value.userMetrics
            : userMetrics // ignore: cast_nullable_to_non_nullable
                  as UserMetricsModel,
        deedMetrics: null == deedMetrics
            ? _value.deedMetrics
            : deedMetrics // ignore: cast_nullable_to_non_nullable
                  as DeedMetricsModel,
        financialMetrics: null == financialMetrics
            ? _value.financialMetrics
            : financialMetrics // ignore: cast_nullable_to_non_nullable
                  as FinancialMetricsModel,
        engagementMetrics: null == engagementMetrics
            ? _value.engagementMetrics
            : engagementMetrics // ignore: cast_nullable_to_non_nullable
                  as EngagementMetricsModel,
        excuseMetrics: null == excuseMetrics
            ? _value.excuseMetrics
            : excuseMetrics // ignore: cast_nullable_to_non_nullable
                  as ExcuseMetricsModel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsModelImpl extends _AnalyticsModel {
  const _$AnalyticsModelImpl({
    required this.userMetrics,
    required this.deedMetrics,
    required this.financialMetrics,
    required this.engagementMetrics,
    required this.excuseMetrics,
  }) : super._();

  factory _$AnalyticsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsModelImplFromJson(json);

  @override
  final UserMetricsModel userMetrics;
  @override
  final DeedMetricsModel deedMetrics;
  @override
  final FinancialMetricsModel financialMetrics;
  @override
  final EngagementMetricsModel engagementMetrics;
  @override
  final ExcuseMetricsModel excuseMetrics;

  @override
  String toString() {
    return 'AnalyticsModel(userMetrics: $userMetrics, deedMetrics: $deedMetrics, financialMetrics: $financialMetrics, engagementMetrics: $engagementMetrics, excuseMetrics: $excuseMetrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsModelImpl &&
            (identical(other.userMetrics, userMetrics) ||
                other.userMetrics == userMetrics) &&
            (identical(other.deedMetrics, deedMetrics) ||
                other.deedMetrics == deedMetrics) &&
            (identical(other.financialMetrics, financialMetrics) ||
                other.financialMetrics == financialMetrics) &&
            (identical(other.engagementMetrics, engagementMetrics) ||
                other.engagementMetrics == engagementMetrics) &&
            (identical(other.excuseMetrics, excuseMetrics) ||
                other.excuseMetrics == excuseMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userMetrics,
    deedMetrics,
    financialMetrics,
    engagementMetrics,
    excuseMetrics,
  );

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsModelImplCopyWith<_$AnalyticsModelImpl> get copyWith =>
      __$$AnalyticsModelImplCopyWithImpl<_$AnalyticsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsModelImplToJson(this);
  }
}

abstract class _AnalyticsModel extends AnalyticsModel {
  const factory _AnalyticsModel({
    required final UserMetricsModel userMetrics,
    required final DeedMetricsModel deedMetrics,
    required final FinancialMetricsModel financialMetrics,
    required final EngagementMetricsModel engagementMetrics,
    required final ExcuseMetricsModel excuseMetrics,
  }) = _$AnalyticsModelImpl;
  const _AnalyticsModel._() : super._();

  factory _AnalyticsModel.fromJson(Map<String, dynamic> json) =
      _$AnalyticsModelImpl.fromJson;

  @override
  UserMetricsModel get userMetrics;
  @override
  DeedMetricsModel get deedMetrics;
  @override
  FinancialMetricsModel get financialMetrics;
  @override
  EngagementMetricsModel get engagementMetrics;
  @override
  ExcuseMetricsModel get excuseMetrics;

  /// Create a copy of AnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsModelImplCopyWith<_$AnalyticsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserMetricsModel _$UserMetricsModelFromJson(Map<String, dynamic> json) {
  return _UserMetricsModel.fromJson(json);
}

/// @nodoc
mixin _$UserMetricsModel {
  @JsonKey(name: 'pending_users')
  int get pendingUsers => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_users')
  int get activeUsers => throw _privateConstructorUsedError;
  @JsonKey(name: 'suspended_users')
  int get suspendedUsers => throw _privateConstructorUsedError;
  @JsonKey(name: 'deactivated_users')
  int get deactivatedUsers => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_members')
  int get newMembers => throw _privateConstructorUsedError;
  @JsonKey(name: 'exclusive_members')
  int get exclusiveMembers => throw _privateConstructorUsedError;
  @JsonKey(name: 'legacy_members')
  int get legacyMembers => throw _privateConstructorUsedError;
  @JsonKey(name: 'users_at_risk')
  int get usersAtRisk => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_registrations_this_week')
  int get newRegistrationsThisWeek => throw _privateConstructorUsedError;

  /// Serializes this UserMetricsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserMetricsModelCopyWith<UserMetricsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserMetricsModelCopyWith<$Res> {
  factory $UserMetricsModelCopyWith(
    UserMetricsModel value,
    $Res Function(UserMetricsModel) then,
  ) = _$UserMetricsModelCopyWithImpl<$Res, UserMetricsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'pending_users') int pendingUsers,
    @JsonKey(name: 'active_users') int activeUsers,
    @JsonKey(name: 'suspended_users') int suspendedUsers,
    @JsonKey(name: 'deactivated_users') int deactivatedUsers,
    @JsonKey(name: 'new_members') int newMembers,
    @JsonKey(name: 'exclusive_members') int exclusiveMembers,
    @JsonKey(name: 'legacy_members') int legacyMembers,
    @JsonKey(name: 'users_at_risk') int usersAtRisk,
    @JsonKey(name: 'new_registrations_this_week') int newRegistrationsThisWeek,
  });
}

/// @nodoc
class _$UserMetricsModelCopyWithImpl<$Res, $Val extends UserMetricsModel>
    implements $UserMetricsModelCopyWith<$Res> {
  _$UserMetricsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pendingUsers = null,
    Object? activeUsers = null,
    Object? suspendedUsers = null,
    Object? deactivatedUsers = null,
    Object? newMembers = null,
    Object? exclusiveMembers = null,
    Object? legacyMembers = null,
    Object? usersAtRisk = null,
    Object? newRegistrationsThisWeek = null,
  }) {
    return _then(
      _value.copyWith(
            pendingUsers: null == pendingUsers
                ? _value.pendingUsers
                : pendingUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            activeUsers: null == activeUsers
                ? _value.activeUsers
                : activeUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            suspendedUsers: null == suspendedUsers
                ? _value.suspendedUsers
                : suspendedUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            deactivatedUsers: null == deactivatedUsers
                ? _value.deactivatedUsers
                : deactivatedUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            newMembers: null == newMembers
                ? _value.newMembers
                : newMembers // ignore: cast_nullable_to_non_nullable
                      as int,
            exclusiveMembers: null == exclusiveMembers
                ? _value.exclusiveMembers
                : exclusiveMembers // ignore: cast_nullable_to_non_nullable
                      as int,
            legacyMembers: null == legacyMembers
                ? _value.legacyMembers
                : legacyMembers // ignore: cast_nullable_to_non_nullable
                      as int,
            usersAtRisk: null == usersAtRisk
                ? _value.usersAtRisk
                : usersAtRisk // ignore: cast_nullable_to_non_nullable
                      as int,
            newRegistrationsThisWeek: null == newRegistrationsThisWeek
                ? _value.newRegistrationsThisWeek
                : newRegistrationsThisWeek // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserMetricsModelImplCopyWith<$Res>
    implements $UserMetricsModelCopyWith<$Res> {
  factory _$$UserMetricsModelImplCopyWith(
    _$UserMetricsModelImpl value,
    $Res Function(_$UserMetricsModelImpl) then,
  ) = __$$UserMetricsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pending_users') int pendingUsers,
    @JsonKey(name: 'active_users') int activeUsers,
    @JsonKey(name: 'suspended_users') int suspendedUsers,
    @JsonKey(name: 'deactivated_users') int deactivatedUsers,
    @JsonKey(name: 'new_members') int newMembers,
    @JsonKey(name: 'exclusive_members') int exclusiveMembers,
    @JsonKey(name: 'legacy_members') int legacyMembers,
    @JsonKey(name: 'users_at_risk') int usersAtRisk,
    @JsonKey(name: 'new_registrations_this_week') int newRegistrationsThisWeek,
  });
}

/// @nodoc
class __$$UserMetricsModelImplCopyWithImpl<$Res>
    extends _$UserMetricsModelCopyWithImpl<$Res, _$UserMetricsModelImpl>
    implements _$$UserMetricsModelImplCopyWith<$Res> {
  __$$UserMetricsModelImplCopyWithImpl(
    _$UserMetricsModelImpl _value,
    $Res Function(_$UserMetricsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pendingUsers = null,
    Object? activeUsers = null,
    Object? suspendedUsers = null,
    Object? deactivatedUsers = null,
    Object? newMembers = null,
    Object? exclusiveMembers = null,
    Object? legacyMembers = null,
    Object? usersAtRisk = null,
    Object? newRegistrationsThisWeek = null,
  }) {
    return _then(
      _$UserMetricsModelImpl(
        pendingUsers: null == pendingUsers
            ? _value.pendingUsers
            : pendingUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        activeUsers: null == activeUsers
            ? _value.activeUsers
            : activeUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        suspendedUsers: null == suspendedUsers
            ? _value.suspendedUsers
            : suspendedUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        deactivatedUsers: null == deactivatedUsers
            ? _value.deactivatedUsers
            : deactivatedUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        newMembers: null == newMembers
            ? _value.newMembers
            : newMembers // ignore: cast_nullable_to_non_nullable
                  as int,
        exclusiveMembers: null == exclusiveMembers
            ? _value.exclusiveMembers
            : exclusiveMembers // ignore: cast_nullable_to_non_nullable
                  as int,
        legacyMembers: null == legacyMembers
            ? _value.legacyMembers
            : legacyMembers // ignore: cast_nullable_to_non_nullable
                  as int,
        usersAtRisk: null == usersAtRisk
            ? _value.usersAtRisk
            : usersAtRisk // ignore: cast_nullable_to_non_nullable
                  as int,
        newRegistrationsThisWeek: null == newRegistrationsThisWeek
            ? _value.newRegistrationsThisWeek
            : newRegistrationsThisWeek // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserMetricsModelImpl extends _UserMetricsModel {
  const _$UserMetricsModelImpl({
    @JsonKey(name: 'pending_users') required this.pendingUsers,
    @JsonKey(name: 'active_users') required this.activeUsers,
    @JsonKey(name: 'suspended_users') required this.suspendedUsers,
    @JsonKey(name: 'deactivated_users') required this.deactivatedUsers,
    @JsonKey(name: 'new_members') required this.newMembers,
    @JsonKey(name: 'exclusive_members') required this.exclusiveMembers,
    @JsonKey(name: 'legacy_members') required this.legacyMembers,
    @JsonKey(name: 'users_at_risk') required this.usersAtRisk,
    @JsonKey(name: 'new_registrations_this_week')
    required this.newRegistrationsThisWeek,
  }) : super._();

  factory _$UserMetricsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserMetricsModelImplFromJson(json);

  @override
  @JsonKey(name: 'pending_users')
  final int pendingUsers;
  @override
  @JsonKey(name: 'active_users')
  final int activeUsers;
  @override
  @JsonKey(name: 'suspended_users')
  final int suspendedUsers;
  @override
  @JsonKey(name: 'deactivated_users')
  final int deactivatedUsers;
  @override
  @JsonKey(name: 'new_members')
  final int newMembers;
  @override
  @JsonKey(name: 'exclusive_members')
  final int exclusiveMembers;
  @override
  @JsonKey(name: 'legacy_members')
  final int legacyMembers;
  @override
  @JsonKey(name: 'users_at_risk')
  final int usersAtRisk;
  @override
  @JsonKey(name: 'new_registrations_this_week')
  final int newRegistrationsThisWeek;

  @override
  String toString() {
    return 'UserMetricsModel(pendingUsers: $pendingUsers, activeUsers: $activeUsers, suspendedUsers: $suspendedUsers, deactivatedUsers: $deactivatedUsers, newMembers: $newMembers, exclusiveMembers: $exclusiveMembers, legacyMembers: $legacyMembers, usersAtRisk: $usersAtRisk, newRegistrationsThisWeek: $newRegistrationsThisWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserMetricsModelImpl &&
            (identical(other.pendingUsers, pendingUsers) ||
                other.pendingUsers == pendingUsers) &&
            (identical(other.activeUsers, activeUsers) ||
                other.activeUsers == activeUsers) &&
            (identical(other.suspendedUsers, suspendedUsers) ||
                other.suspendedUsers == suspendedUsers) &&
            (identical(other.deactivatedUsers, deactivatedUsers) ||
                other.deactivatedUsers == deactivatedUsers) &&
            (identical(other.newMembers, newMembers) ||
                other.newMembers == newMembers) &&
            (identical(other.exclusiveMembers, exclusiveMembers) ||
                other.exclusiveMembers == exclusiveMembers) &&
            (identical(other.legacyMembers, legacyMembers) ||
                other.legacyMembers == legacyMembers) &&
            (identical(other.usersAtRisk, usersAtRisk) ||
                other.usersAtRisk == usersAtRisk) &&
            (identical(
                  other.newRegistrationsThisWeek,
                  newRegistrationsThisWeek,
                ) ||
                other.newRegistrationsThisWeek == newRegistrationsThisWeek));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pendingUsers,
    activeUsers,
    suspendedUsers,
    deactivatedUsers,
    newMembers,
    exclusiveMembers,
    legacyMembers,
    usersAtRisk,
    newRegistrationsThisWeek,
  );

  /// Create a copy of UserMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserMetricsModelImplCopyWith<_$UserMetricsModelImpl> get copyWith =>
      __$$UserMetricsModelImplCopyWithImpl<_$UserMetricsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserMetricsModelImplToJson(this);
  }
}

abstract class _UserMetricsModel extends UserMetricsModel {
  const factory _UserMetricsModel({
    @JsonKey(name: 'pending_users') required final int pendingUsers,
    @JsonKey(name: 'active_users') required final int activeUsers,
    @JsonKey(name: 'suspended_users') required final int suspendedUsers,
    @JsonKey(name: 'deactivated_users') required final int deactivatedUsers,
    @JsonKey(name: 'new_members') required final int newMembers,
    @JsonKey(name: 'exclusive_members') required final int exclusiveMembers,
    @JsonKey(name: 'legacy_members') required final int legacyMembers,
    @JsonKey(name: 'users_at_risk') required final int usersAtRisk,
    @JsonKey(name: 'new_registrations_this_week')
    required final int newRegistrationsThisWeek,
  }) = _$UserMetricsModelImpl;
  const _UserMetricsModel._() : super._();

  factory _UserMetricsModel.fromJson(Map<String, dynamic> json) =
      _$UserMetricsModelImpl.fromJson;

  @override
  @JsonKey(name: 'pending_users')
  int get pendingUsers;
  @override
  @JsonKey(name: 'active_users')
  int get activeUsers;
  @override
  @JsonKey(name: 'suspended_users')
  int get suspendedUsers;
  @override
  @JsonKey(name: 'deactivated_users')
  int get deactivatedUsers;
  @override
  @JsonKey(name: 'new_members')
  int get newMembers;
  @override
  @JsonKey(name: 'exclusive_members')
  int get exclusiveMembers;
  @override
  @JsonKey(name: 'legacy_members')
  int get legacyMembers;
  @override
  @JsonKey(name: 'users_at_risk')
  int get usersAtRisk;
  @override
  @JsonKey(name: 'new_registrations_this_week')
  int get newRegistrationsThisWeek;

  /// Create a copy of UserMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserMetricsModelImplCopyWith<_$UserMetricsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeedMetricsModel _$DeedMetricsModelFromJson(Map<String, dynamic> json) {
  return _DeedMetricsModel.fromJson(json);
}

/// @nodoc
mixin _$DeedMetricsModel {
  @JsonKey(name: 'total_deeds_today')
  int get totalDeedsToday => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_deeds_week')
  int get totalDeedsWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_deeds_month')
  int get totalDeedsMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_deeds_all_time')
  int get totalDeedsAllTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_per_user_today')
  double get averagePerUserToday => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_per_user_week')
  double get averagePerUserWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_per_user_month')
  double get averagePerUserMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'compliance_rate_today')
  double get complianceRateToday => throw _privateConstructorUsedError;
  @JsonKey(name: 'compliance_rate_week')
  double get complianceRateWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'compliance_rate_month')
  double get complianceRateMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'users_completed_today')
  int get usersCompletedToday => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_active_users')
  int get totalActiveUsers => throw _privateConstructorUsedError;
  @JsonKey(name: 'faraid_compliance_rate')
  double get faraidComplianceRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'sunnah_compliance_rate')
  double get sunnahComplianceRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'top_performers')
  List<TopPerformerModel> get topPerformers =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'users_needing_attention')
  List<UserNeedingAttentionModel> get usersNeedingAttention =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'deed_compliance_by_type')
  Map<String, double> get deedComplianceByType =>
      throw _privateConstructorUsedError;

  /// Serializes this DeedMetricsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeedMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeedMetricsModelCopyWith<DeedMetricsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeedMetricsModelCopyWith<$Res> {
  factory $DeedMetricsModelCopyWith(
    DeedMetricsModel value,
    $Res Function(DeedMetricsModel) then,
  ) = _$DeedMetricsModelCopyWithImpl<$Res, DeedMetricsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_deeds_today') int totalDeedsToday,
    @JsonKey(name: 'total_deeds_week') int totalDeedsWeek,
    @JsonKey(name: 'total_deeds_month') int totalDeedsMonth,
    @JsonKey(name: 'total_deeds_all_time') int totalDeedsAllTime,
    @JsonKey(name: 'average_per_user_today') double averagePerUserToday,
    @JsonKey(name: 'average_per_user_week') double averagePerUserWeek,
    @JsonKey(name: 'average_per_user_month') double averagePerUserMonth,
    @JsonKey(name: 'compliance_rate_today') double complianceRateToday,
    @JsonKey(name: 'compliance_rate_week') double complianceRateWeek,
    @JsonKey(name: 'compliance_rate_month') double complianceRateMonth,
    @JsonKey(name: 'users_completed_today') int usersCompletedToday,
    @JsonKey(name: 'total_active_users') int totalActiveUsers,
    @JsonKey(name: 'faraid_compliance_rate') double faraidComplianceRate,
    @JsonKey(name: 'sunnah_compliance_rate') double sunnahComplianceRate,
    @JsonKey(name: 'top_performers') List<TopPerformerModel> topPerformers,
    @JsonKey(name: 'users_needing_attention')
    List<UserNeedingAttentionModel> usersNeedingAttention,
    @JsonKey(name: 'deed_compliance_by_type')
    Map<String, double> deedComplianceByType,
  });
}

/// @nodoc
class _$DeedMetricsModelCopyWithImpl<$Res, $Val extends DeedMetricsModel>
    implements $DeedMetricsModelCopyWith<$Res> {
  _$DeedMetricsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeedMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDeedsToday = null,
    Object? totalDeedsWeek = null,
    Object? totalDeedsMonth = null,
    Object? totalDeedsAllTime = null,
    Object? averagePerUserToday = null,
    Object? averagePerUserWeek = null,
    Object? averagePerUserMonth = null,
    Object? complianceRateToday = null,
    Object? complianceRateWeek = null,
    Object? complianceRateMonth = null,
    Object? usersCompletedToday = null,
    Object? totalActiveUsers = null,
    Object? faraidComplianceRate = null,
    Object? sunnahComplianceRate = null,
    Object? topPerformers = null,
    Object? usersNeedingAttention = null,
    Object? deedComplianceByType = null,
  }) {
    return _then(
      _value.copyWith(
            totalDeedsToday: null == totalDeedsToday
                ? _value.totalDeedsToday
                : totalDeedsToday // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDeedsWeek: null == totalDeedsWeek
                ? _value.totalDeedsWeek
                : totalDeedsWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDeedsMonth: null == totalDeedsMonth
                ? _value.totalDeedsMonth
                : totalDeedsMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDeedsAllTime: null == totalDeedsAllTime
                ? _value.totalDeedsAllTime
                : totalDeedsAllTime // ignore: cast_nullable_to_non_nullable
                      as int,
            averagePerUserToday: null == averagePerUserToday
                ? _value.averagePerUserToday
                : averagePerUserToday // ignore: cast_nullable_to_non_nullable
                      as double,
            averagePerUserWeek: null == averagePerUserWeek
                ? _value.averagePerUserWeek
                : averagePerUserWeek // ignore: cast_nullable_to_non_nullable
                      as double,
            averagePerUserMonth: null == averagePerUserMonth
                ? _value.averagePerUserMonth
                : averagePerUserMonth // ignore: cast_nullable_to_non_nullable
                      as double,
            complianceRateToday: null == complianceRateToday
                ? _value.complianceRateToday
                : complianceRateToday // ignore: cast_nullable_to_non_nullable
                      as double,
            complianceRateWeek: null == complianceRateWeek
                ? _value.complianceRateWeek
                : complianceRateWeek // ignore: cast_nullable_to_non_nullable
                      as double,
            complianceRateMonth: null == complianceRateMonth
                ? _value.complianceRateMonth
                : complianceRateMonth // ignore: cast_nullable_to_non_nullable
                      as double,
            usersCompletedToday: null == usersCompletedToday
                ? _value.usersCompletedToday
                : usersCompletedToday // ignore: cast_nullable_to_non_nullable
                      as int,
            totalActiveUsers: null == totalActiveUsers
                ? _value.totalActiveUsers
                : totalActiveUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            faraidComplianceRate: null == faraidComplianceRate
                ? _value.faraidComplianceRate
                : faraidComplianceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            sunnahComplianceRate: null == sunnahComplianceRate
                ? _value.sunnahComplianceRate
                : sunnahComplianceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            topPerformers: null == topPerformers
                ? _value.topPerformers
                : topPerformers // ignore: cast_nullable_to_non_nullable
                      as List<TopPerformerModel>,
            usersNeedingAttention: null == usersNeedingAttention
                ? _value.usersNeedingAttention
                : usersNeedingAttention // ignore: cast_nullable_to_non_nullable
                      as List<UserNeedingAttentionModel>,
            deedComplianceByType: null == deedComplianceByType
                ? _value.deedComplianceByType
                : deedComplianceByType // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeedMetricsModelImplCopyWith<$Res>
    implements $DeedMetricsModelCopyWith<$Res> {
  factory _$$DeedMetricsModelImplCopyWith(
    _$DeedMetricsModelImpl value,
    $Res Function(_$DeedMetricsModelImpl) then,
  ) = __$$DeedMetricsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_deeds_today') int totalDeedsToday,
    @JsonKey(name: 'total_deeds_week') int totalDeedsWeek,
    @JsonKey(name: 'total_deeds_month') int totalDeedsMonth,
    @JsonKey(name: 'total_deeds_all_time') int totalDeedsAllTime,
    @JsonKey(name: 'average_per_user_today') double averagePerUserToday,
    @JsonKey(name: 'average_per_user_week') double averagePerUserWeek,
    @JsonKey(name: 'average_per_user_month') double averagePerUserMonth,
    @JsonKey(name: 'compliance_rate_today') double complianceRateToday,
    @JsonKey(name: 'compliance_rate_week') double complianceRateWeek,
    @JsonKey(name: 'compliance_rate_month') double complianceRateMonth,
    @JsonKey(name: 'users_completed_today') int usersCompletedToday,
    @JsonKey(name: 'total_active_users') int totalActiveUsers,
    @JsonKey(name: 'faraid_compliance_rate') double faraidComplianceRate,
    @JsonKey(name: 'sunnah_compliance_rate') double sunnahComplianceRate,
    @JsonKey(name: 'top_performers') List<TopPerformerModel> topPerformers,
    @JsonKey(name: 'users_needing_attention')
    List<UserNeedingAttentionModel> usersNeedingAttention,
    @JsonKey(name: 'deed_compliance_by_type')
    Map<String, double> deedComplianceByType,
  });
}

/// @nodoc
class __$$DeedMetricsModelImplCopyWithImpl<$Res>
    extends _$DeedMetricsModelCopyWithImpl<$Res, _$DeedMetricsModelImpl>
    implements _$$DeedMetricsModelImplCopyWith<$Res> {
  __$$DeedMetricsModelImplCopyWithImpl(
    _$DeedMetricsModelImpl _value,
    $Res Function(_$DeedMetricsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeedMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDeedsToday = null,
    Object? totalDeedsWeek = null,
    Object? totalDeedsMonth = null,
    Object? totalDeedsAllTime = null,
    Object? averagePerUserToday = null,
    Object? averagePerUserWeek = null,
    Object? averagePerUserMonth = null,
    Object? complianceRateToday = null,
    Object? complianceRateWeek = null,
    Object? complianceRateMonth = null,
    Object? usersCompletedToday = null,
    Object? totalActiveUsers = null,
    Object? faraidComplianceRate = null,
    Object? sunnahComplianceRate = null,
    Object? topPerformers = null,
    Object? usersNeedingAttention = null,
    Object? deedComplianceByType = null,
  }) {
    return _then(
      _$DeedMetricsModelImpl(
        totalDeedsToday: null == totalDeedsToday
            ? _value.totalDeedsToday
            : totalDeedsToday // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDeedsWeek: null == totalDeedsWeek
            ? _value.totalDeedsWeek
            : totalDeedsWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDeedsMonth: null == totalDeedsMonth
            ? _value.totalDeedsMonth
            : totalDeedsMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDeedsAllTime: null == totalDeedsAllTime
            ? _value.totalDeedsAllTime
            : totalDeedsAllTime // ignore: cast_nullable_to_non_nullable
                  as int,
        averagePerUserToday: null == averagePerUserToday
            ? _value.averagePerUserToday
            : averagePerUserToday // ignore: cast_nullable_to_non_nullable
                  as double,
        averagePerUserWeek: null == averagePerUserWeek
            ? _value.averagePerUserWeek
            : averagePerUserWeek // ignore: cast_nullable_to_non_nullable
                  as double,
        averagePerUserMonth: null == averagePerUserMonth
            ? _value.averagePerUserMonth
            : averagePerUserMonth // ignore: cast_nullable_to_non_nullable
                  as double,
        complianceRateToday: null == complianceRateToday
            ? _value.complianceRateToday
            : complianceRateToday // ignore: cast_nullable_to_non_nullable
                  as double,
        complianceRateWeek: null == complianceRateWeek
            ? _value.complianceRateWeek
            : complianceRateWeek // ignore: cast_nullable_to_non_nullable
                  as double,
        complianceRateMonth: null == complianceRateMonth
            ? _value.complianceRateMonth
            : complianceRateMonth // ignore: cast_nullable_to_non_nullable
                  as double,
        usersCompletedToday: null == usersCompletedToday
            ? _value.usersCompletedToday
            : usersCompletedToday // ignore: cast_nullable_to_non_nullable
                  as int,
        totalActiveUsers: null == totalActiveUsers
            ? _value.totalActiveUsers
            : totalActiveUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        faraidComplianceRate: null == faraidComplianceRate
            ? _value.faraidComplianceRate
            : faraidComplianceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        sunnahComplianceRate: null == sunnahComplianceRate
            ? _value.sunnahComplianceRate
            : sunnahComplianceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        topPerformers: null == topPerformers
            ? _value._topPerformers
            : topPerformers // ignore: cast_nullable_to_non_nullable
                  as List<TopPerformerModel>,
        usersNeedingAttention: null == usersNeedingAttention
            ? _value._usersNeedingAttention
            : usersNeedingAttention // ignore: cast_nullable_to_non_nullable
                  as List<UserNeedingAttentionModel>,
        deedComplianceByType: null == deedComplianceByType
            ? _value._deedComplianceByType
            : deedComplianceByType // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeedMetricsModelImpl extends _DeedMetricsModel {
  const _$DeedMetricsModelImpl({
    @JsonKey(name: 'total_deeds_today') required this.totalDeedsToday,
    @JsonKey(name: 'total_deeds_week') required this.totalDeedsWeek,
    @JsonKey(name: 'total_deeds_month') required this.totalDeedsMonth,
    @JsonKey(name: 'total_deeds_all_time') required this.totalDeedsAllTime,
    @JsonKey(name: 'average_per_user_today') required this.averagePerUserToday,
    @JsonKey(name: 'average_per_user_week') required this.averagePerUserWeek,
    @JsonKey(name: 'average_per_user_month') required this.averagePerUserMonth,
    @JsonKey(name: 'compliance_rate_today') required this.complianceRateToday,
    @JsonKey(name: 'compliance_rate_week') required this.complianceRateWeek,
    @JsonKey(name: 'compliance_rate_month') required this.complianceRateMonth,
    @JsonKey(name: 'users_completed_today') required this.usersCompletedToday,
    @JsonKey(name: 'total_active_users') required this.totalActiveUsers,
    @JsonKey(name: 'faraid_compliance_rate') required this.faraidComplianceRate,
    @JsonKey(name: 'sunnah_compliance_rate') required this.sunnahComplianceRate,
    @JsonKey(name: 'top_performers')
    required final List<TopPerformerModel> topPerformers,
    @JsonKey(name: 'users_needing_attention')
    required final List<UserNeedingAttentionModel> usersNeedingAttention,
    @JsonKey(name: 'deed_compliance_by_type')
    required final Map<String, double> deedComplianceByType,
  }) : _topPerformers = topPerformers,
       _usersNeedingAttention = usersNeedingAttention,
       _deedComplianceByType = deedComplianceByType,
       super._();

  factory _$DeedMetricsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeedMetricsModelImplFromJson(json);

  @override
  @JsonKey(name: 'total_deeds_today')
  final int totalDeedsToday;
  @override
  @JsonKey(name: 'total_deeds_week')
  final int totalDeedsWeek;
  @override
  @JsonKey(name: 'total_deeds_month')
  final int totalDeedsMonth;
  @override
  @JsonKey(name: 'total_deeds_all_time')
  final int totalDeedsAllTime;
  @override
  @JsonKey(name: 'average_per_user_today')
  final double averagePerUserToday;
  @override
  @JsonKey(name: 'average_per_user_week')
  final double averagePerUserWeek;
  @override
  @JsonKey(name: 'average_per_user_month')
  final double averagePerUserMonth;
  @override
  @JsonKey(name: 'compliance_rate_today')
  final double complianceRateToday;
  @override
  @JsonKey(name: 'compliance_rate_week')
  final double complianceRateWeek;
  @override
  @JsonKey(name: 'compliance_rate_month')
  final double complianceRateMonth;
  @override
  @JsonKey(name: 'users_completed_today')
  final int usersCompletedToday;
  @override
  @JsonKey(name: 'total_active_users')
  final int totalActiveUsers;
  @override
  @JsonKey(name: 'faraid_compliance_rate')
  final double faraidComplianceRate;
  @override
  @JsonKey(name: 'sunnah_compliance_rate')
  final double sunnahComplianceRate;
  final List<TopPerformerModel> _topPerformers;
  @override
  @JsonKey(name: 'top_performers')
  List<TopPerformerModel> get topPerformers {
    if (_topPerformers is EqualUnmodifiableListView) return _topPerformers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topPerformers);
  }

  final List<UserNeedingAttentionModel> _usersNeedingAttention;
  @override
  @JsonKey(name: 'users_needing_attention')
  List<UserNeedingAttentionModel> get usersNeedingAttention {
    if (_usersNeedingAttention is EqualUnmodifiableListView)
      return _usersNeedingAttention;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_usersNeedingAttention);
  }

  final Map<String, double> _deedComplianceByType;
  @override
  @JsonKey(name: 'deed_compliance_by_type')
  Map<String, double> get deedComplianceByType {
    if (_deedComplianceByType is EqualUnmodifiableMapView)
      return _deedComplianceByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_deedComplianceByType);
  }

  @override
  String toString() {
    return 'DeedMetricsModel(totalDeedsToday: $totalDeedsToday, totalDeedsWeek: $totalDeedsWeek, totalDeedsMonth: $totalDeedsMonth, totalDeedsAllTime: $totalDeedsAllTime, averagePerUserToday: $averagePerUserToday, averagePerUserWeek: $averagePerUserWeek, averagePerUserMonth: $averagePerUserMonth, complianceRateToday: $complianceRateToday, complianceRateWeek: $complianceRateWeek, complianceRateMonth: $complianceRateMonth, usersCompletedToday: $usersCompletedToday, totalActiveUsers: $totalActiveUsers, faraidComplianceRate: $faraidComplianceRate, sunnahComplianceRate: $sunnahComplianceRate, topPerformers: $topPerformers, usersNeedingAttention: $usersNeedingAttention, deedComplianceByType: $deedComplianceByType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeedMetricsModelImpl &&
            (identical(other.totalDeedsToday, totalDeedsToday) ||
                other.totalDeedsToday == totalDeedsToday) &&
            (identical(other.totalDeedsWeek, totalDeedsWeek) ||
                other.totalDeedsWeek == totalDeedsWeek) &&
            (identical(other.totalDeedsMonth, totalDeedsMonth) ||
                other.totalDeedsMonth == totalDeedsMonth) &&
            (identical(other.totalDeedsAllTime, totalDeedsAllTime) ||
                other.totalDeedsAllTime == totalDeedsAllTime) &&
            (identical(other.averagePerUserToday, averagePerUserToday) ||
                other.averagePerUserToday == averagePerUserToday) &&
            (identical(other.averagePerUserWeek, averagePerUserWeek) ||
                other.averagePerUserWeek == averagePerUserWeek) &&
            (identical(other.averagePerUserMonth, averagePerUserMonth) ||
                other.averagePerUserMonth == averagePerUserMonth) &&
            (identical(other.complianceRateToday, complianceRateToday) ||
                other.complianceRateToday == complianceRateToday) &&
            (identical(other.complianceRateWeek, complianceRateWeek) ||
                other.complianceRateWeek == complianceRateWeek) &&
            (identical(other.complianceRateMonth, complianceRateMonth) ||
                other.complianceRateMonth == complianceRateMonth) &&
            (identical(other.usersCompletedToday, usersCompletedToday) ||
                other.usersCompletedToday == usersCompletedToday) &&
            (identical(other.totalActiveUsers, totalActiveUsers) ||
                other.totalActiveUsers == totalActiveUsers) &&
            (identical(other.faraidComplianceRate, faraidComplianceRate) ||
                other.faraidComplianceRate == faraidComplianceRate) &&
            (identical(other.sunnahComplianceRate, sunnahComplianceRate) ||
                other.sunnahComplianceRate == sunnahComplianceRate) &&
            const DeepCollectionEquality().equals(
              other._topPerformers,
              _topPerformers,
            ) &&
            const DeepCollectionEquality().equals(
              other._usersNeedingAttention,
              _usersNeedingAttention,
            ) &&
            const DeepCollectionEquality().equals(
              other._deedComplianceByType,
              _deedComplianceByType,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalDeedsToday,
    totalDeedsWeek,
    totalDeedsMonth,
    totalDeedsAllTime,
    averagePerUserToday,
    averagePerUserWeek,
    averagePerUserMonth,
    complianceRateToday,
    complianceRateWeek,
    complianceRateMonth,
    usersCompletedToday,
    totalActiveUsers,
    faraidComplianceRate,
    sunnahComplianceRate,
    const DeepCollectionEquality().hash(_topPerformers),
    const DeepCollectionEquality().hash(_usersNeedingAttention),
    const DeepCollectionEquality().hash(_deedComplianceByType),
  );

  /// Create a copy of DeedMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeedMetricsModelImplCopyWith<_$DeedMetricsModelImpl> get copyWith =>
      __$$DeedMetricsModelImplCopyWithImpl<_$DeedMetricsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeedMetricsModelImplToJson(this);
  }
}

abstract class _DeedMetricsModel extends DeedMetricsModel {
  const factory _DeedMetricsModel({
    @JsonKey(name: 'total_deeds_today') required final int totalDeedsToday,
    @JsonKey(name: 'total_deeds_week') required final int totalDeedsWeek,
    @JsonKey(name: 'total_deeds_month') required final int totalDeedsMonth,
    @JsonKey(name: 'total_deeds_all_time') required final int totalDeedsAllTime,
    @JsonKey(name: 'average_per_user_today')
    required final double averagePerUserToday,
    @JsonKey(name: 'average_per_user_week')
    required final double averagePerUserWeek,
    @JsonKey(name: 'average_per_user_month')
    required final double averagePerUserMonth,
    @JsonKey(name: 'compliance_rate_today')
    required final double complianceRateToday,
    @JsonKey(name: 'compliance_rate_week')
    required final double complianceRateWeek,
    @JsonKey(name: 'compliance_rate_month')
    required final double complianceRateMonth,
    @JsonKey(name: 'users_completed_today')
    required final int usersCompletedToday,
    @JsonKey(name: 'total_active_users') required final int totalActiveUsers,
    @JsonKey(name: 'faraid_compliance_rate')
    required final double faraidComplianceRate,
    @JsonKey(name: 'sunnah_compliance_rate')
    required final double sunnahComplianceRate,
    @JsonKey(name: 'top_performers')
    required final List<TopPerformerModel> topPerformers,
    @JsonKey(name: 'users_needing_attention')
    required final List<UserNeedingAttentionModel> usersNeedingAttention,
    @JsonKey(name: 'deed_compliance_by_type')
    required final Map<String, double> deedComplianceByType,
  }) = _$DeedMetricsModelImpl;
  const _DeedMetricsModel._() : super._();

  factory _DeedMetricsModel.fromJson(Map<String, dynamic> json) =
      _$DeedMetricsModelImpl.fromJson;

  @override
  @JsonKey(name: 'total_deeds_today')
  int get totalDeedsToday;
  @override
  @JsonKey(name: 'total_deeds_week')
  int get totalDeedsWeek;
  @override
  @JsonKey(name: 'total_deeds_month')
  int get totalDeedsMonth;
  @override
  @JsonKey(name: 'total_deeds_all_time')
  int get totalDeedsAllTime;
  @override
  @JsonKey(name: 'average_per_user_today')
  double get averagePerUserToday;
  @override
  @JsonKey(name: 'average_per_user_week')
  double get averagePerUserWeek;
  @override
  @JsonKey(name: 'average_per_user_month')
  double get averagePerUserMonth;
  @override
  @JsonKey(name: 'compliance_rate_today')
  double get complianceRateToday;
  @override
  @JsonKey(name: 'compliance_rate_week')
  double get complianceRateWeek;
  @override
  @JsonKey(name: 'compliance_rate_month')
  double get complianceRateMonth;
  @override
  @JsonKey(name: 'users_completed_today')
  int get usersCompletedToday;
  @override
  @JsonKey(name: 'total_active_users')
  int get totalActiveUsers;
  @override
  @JsonKey(name: 'faraid_compliance_rate')
  double get faraidComplianceRate;
  @override
  @JsonKey(name: 'sunnah_compliance_rate')
  double get sunnahComplianceRate;
  @override
  @JsonKey(name: 'top_performers')
  List<TopPerformerModel> get topPerformers;
  @override
  @JsonKey(name: 'users_needing_attention')
  List<UserNeedingAttentionModel> get usersNeedingAttention;
  @override
  @JsonKey(name: 'deed_compliance_by_type')
  Map<String, double> get deedComplianceByType;

  /// Create a copy of DeedMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeedMetricsModelImplCopyWith<_$DeedMetricsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TopPerformerModel _$TopPerformerModelFromJson(Map<String, dynamic> json) {
  return _TopPerformerModel.fromJson(json);
}

/// @nodoc
mixin _$TopPerformerModel {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_deeds')
  double get averageDeeds => throw _privateConstructorUsedError;

  /// Serializes this TopPerformerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopPerformerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopPerformerModelCopyWith<TopPerformerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopPerformerModelCopyWith<$Res> {
  factory $TopPerformerModelCopyWith(
    TopPerformerModel value,
    $Res Function(TopPerformerModel) then,
  ) = _$TopPerformerModelCopyWithImpl<$Res, TopPerformerModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'user_name') String userName,
    @JsonKey(name: 'average_deeds') double averageDeeds,
  });
}

/// @nodoc
class _$TopPerformerModelCopyWithImpl<$Res, $Val extends TopPerformerModel>
    implements $TopPerformerModelCopyWith<$Res> {
  _$TopPerformerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopPerformerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? averageDeeds = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            averageDeeds: null == averageDeeds
                ? _value.averageDeeds
                : averageDeeds // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopPerformerModelImplCopyWith<$Res>
    implements $TopPerformerModelCopyWith<$Res> {
  factory _$$TopPerformerModelImplCopyWith(
    _$TopPerformerModelImpl value,
    $Res Function(_$TopPerformerModelImpl) then,
  ) = __$$TopPerformerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'user_name') String userName,
    @JsonKey(name: 'average_deeds') double averageDeeds,
  });
}

/// @nodoc
class __$$TopPerformerModelImplCopyWithImpl<$Res>
    extends _$TopPerformerModelCopyWithImpl<$Res, _$TopPerformerModelImpl>
    implements _$$TopPerformerModelImplCopyWith<$Res> {
  __$$TopPerformerModelImplCopyWithImpl(
    _$TopPerformerModelImpl _value,
    $Res Function(_$TopPerformerModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopPerformerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? averageDeeds = null,
  }) {
    return _then(
      _$TopPerformerModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        averageDeeds: null == averageDeeds
            ? _value.averageDeeds
            : averageDeeds // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopPerformerModelImpl extends _TopPerformerModel {
  const _$TopPerformerModelImpl({
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'user_name') required this.userName,
    @JsonKey(name: 'average_deeds') required this.averageDeeds,
  }) : super._();

  factory _$TopPerformerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopPerformerModelImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'user_name')
  final String userName;
  @override
  @JsonKey(name: 'average_deeds')
  final double averageDeeds;

  @override
  String toString() {
    return 'TopPerformerModel(userId: $userId, userName: $userName, averageDeeds: $averageDeeds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopPerformerModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.averageDeeds, averageDeeds) ||
                other.averageDeeds == averageDeeds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, userName, averageDeeds);

  /// Create a copy of TopPerformerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopPerformerModelImplCopyWith<_$TopPerformerModelImpl> get copyWith =>
      __$$TopPerformerModelImplCopyWithImpl<_$TopPerformerModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TopPerformerModelImplToJson(this);
  }
}

abstract class _TopPerformerModel extends TopPerformerModel {
  const factory _TopPerformerModel({
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'user_name') required final String userName,
    @JsonKey(name: 'average_deeds') required final double averageDeeds,
  }) = _$TopPerformerModelImpl;
  const _TopPerformerModel._() : super._();

  factory _TopPerformerModel.fromJson(Map<String, dynamic> json) =
      _$TopPerformerModelImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'user_name')
  String get userName;
  @override
  @JsonKey(name: 'average_deeds')
  double get averageDeeds;

  /// Create a copy of TopPerformerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopPerformerModelImplCopyWith<_$TopPerformerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserNeedingAttentionModel _$UserNeedingAttentionModelFromJson(
  Map<String, dynamic> json,
) {
  return _UserNeedingAttentionModel.fromJson(json);
}

/// @nodoc
mixin _$UserNeedingAttentionModel {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_deeds')
  double get averageDeeds => throw _privateConstructorUsedError;

  /// Serializes this UserNeedingAttentionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserNeedingAttentionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserNeedingAttentionModelCopyWith<UserNeedingAttentionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserNeedingAttentionModelCopyWith<$Res> {
  factory $UserNeedingAttentionModelCopyWith(
    UserNeedingAttentionModel value,
    $Res Function(UserNeedingAttentionModel) then,
  ) = _$UserNeedingAttentionModelCopyWithImpl<$Res, UserNeedingAttentionModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'user_name') String userName,
    @JsonKey(name: 'average_deeds') double averageDeeds,
  });
}

/// @nodoc
class _$UserNeedingAttentionModelCopyWithImpl<
  $Res,
  $Val extends UserNeedingAttentionModel
>
    implements $UserNeedingAttentionModelCopyWith<$Res> {
  _$UserNeedingAttentionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserNeedingAttentionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? averageDeeds = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            averageDeeds: null == averageDeeds
                ? _value.averageDeeds
                : averageDeeds // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserNeedingAttentionModelImplCopyWith<$Res>
    implements $UserNeedingAttentionModelCopyWith<$Res> {
  factory _$$UserNeedingAttentionModelImplCopyWith(
    _$UserNeedingAttentionModelImpl value,
    $Res Function(_$UserNeedingAttentionModelImpl) then,
  ) = __$$UserNeedingAttentionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'user_name') String userName,
    @JsonKey(name: 'average_deeds') double averageDeeds,
  });
}

/// @nodoc
class __$$UserNeedingAttentionModelImplCopyWithImpl<$Res>
    extends
        _$UserNeedingAttentionModelCopyWithImpl<
          $Res,
          _$UserNeedingAttentionModelImpl
        >
    implements _$$UserNeedingAttentionModelImplCopyWith<$Res> {
  __$$UserNeedingAttentionModelImplCopyWithImpl(
    _$UserNeedingAttentionModelImpl _value,
    $Res Function(_$UserNeedingAttentionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserNeedingAttentionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? averageDeeds = null,
  }) {
    return _then(
      _$UserNeedingAttentionModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        averageDeeds: null == averageDeeds
            ? _value.averageDeeds
            : averageDeeds // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserNeedingAttentionModelImpl extends _UserNeedingAttentionModel {
  const _$UserNeedingAttentionModelImpl({
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'user_name') required this.userName,
    @JsonKey(name: 'average_deeds') required this.averageDeeds,
  }) : super._();

  factory _$UserNeedingAttentionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserNeedingAttentionModelImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'user_name')
  final String userName;
  @override
  @JsonKey(name: 'average_deeds')
  final double averageDeeds;

  @override
  String toString() {
    return 'UserNeedingAttentionModel(userId: $userId, userName: $userName, averageDeeds: $averageDeeds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserNeedingAttentionModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.averageDeeds, averageDeeds) ||
                other.averageDeeds == averageDeeds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, userName, averageDeeds);

  /// Create a copy of UserNeedingAttentionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserNeedingAttentionModelImplCopyWith<_$UserNeedingAttentionModelImpl>
  get copyWith =>
      __$$UserNeedingAttentionModelImplCopyWithImpl<
        _$UserNeedingAttentionModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserNeedingAttentionModelImplToJson(this);
  }
}

abstract class _UserNeedingAttentionModel extends UserNeedingAttentionModel {
  const factory _UserNeedingAttentionModel({
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'user_name') required final String userName,
    @JsonKey(name: 'average_deeds') required final double averageDeeds,
  }) = _$UserNeedingAttentionModelImpl;
  const _UserNeedingAttentionModel._() : super._();

  factory _UserNeedingAttentionModel.fromJson(Map<String, dynamic> json) =
      _$UserNeedingAttentionModelImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'user_name')
  String get userName;
  @override
  @JsonKey(name: 'average_deeds')
  double get averageDeeds;

  /// Create a copy of UserNeedingAttentionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserNeedingAttentionModelImplCopyWith<_$UserNeedingAttentionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

FinancialMetricsModel _$FinancialMetricsModelFromJson(
  Map<String, dynamic> json,
) {
  return _FinancialMetricsModel.fromJson(json);
}

/// @nodoc
mixin _$FinancialMetricsModel {
  @JsonKey(name: 'penalties_incurred_this_month')
  double get penaltiesIncurredThisMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'penalties_incurred_all_time')
  double get penaltiesIncurredAllTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'payments_received_this_month')
  double get paymentsReceivedThisMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'payments_received_all_time')
  double get paymentsReceivedAllTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'outstanding_balance')
  double get outstandingBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_payments_count')
  int get pendingPaymentsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_payments_amount')
  double get pendingPaymentsAmount => throw _privateConstructorUsedError;

  /// Serializes this FinancialMetricsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialMetricsModelCopyWith<FinancialMetricsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialMetricsModelCopyWith<$Res> {
  factory $FinancialMetricsModelCopyWith(
    FinancialMetricsModel value,
    $Res Function(FinancialMetricsModel) then,
  ) = _$FinancialMetricsModelCopyWithImpl<$Res, FinancialMetricsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'penalties_incurred_this_month')
    double penaltiesIncurredThisMonth,
    @JsonKey(name: 'penalties_incurred_all_time')
    double penaltiesIncurredAllTime,
    @JsonKey(name: 'payments_received_this_month')
    double paymentsReceivedThisMonth,
    @JsonKey(name: 'payments_received_all_time') double paymentsReceivedAllTime,
    @JsonKey(name: 'outstanding_balance') double outstandingBalance,
    @JsonKey(name: 'pending_payments_count') int pendingPaymentsCount,
    @JsonKey(name: 'pending_payments_amount') double pendingPaymentsAmount,
  });
}

/// @nodoc
class _$FinancialMetricsModelCopyWithImpl<
  $Res,
  $Val extends FinancialMetricsModel
>
    implements $FinancialMetricsModelCopyWith<$Res> {
  _$FinancialMetricsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? penaltiesIncurredThisMonth = null,
    Object? penaltiesIncurredAllTime = null,
    Object? paymentsReceivedThisMonth = null,
    Object? paymentsReceivedAllTime = null,
    Object? outstandingBalance = null,
    Object? pendingPaymentsCount = null,
    Object? pendingPaymentsAmount = null,
  }) {
    return _then(
      _value.copyWith(
            penaltiesIncurredThisMonth: null == penaltiesIncurredThisMonth
                ? _value.penaltiesIncurredThisMonth
                : penaltiesIncurredThisMonth // ignore: cast_nullable_to_non_nullable
                      as double,
            penaltiesIncurredAllTime: null == penaltiesIncurredAllTime
                ? _value.penaltiesIncurredAllTime
                : penaltiesIncurredAllTime // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentsReceivedThisMonth: null == paymentsReceivedThisMonth
                ? _value.paymentsReceivedThisMonth
                : paymentsReceivedThisMonth // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentsReceivedAllTime: null == paymentsReceivedAllTime
                ? _value.paymentsReceivedAllTime
                : paymentsReceivedAllTime // ignore: cast_nullable_to_non_nullable
                      as double,
            outstandingBalance: null == outstandingBalance
                ? _value.outstandingBalance
                : outstandingBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            pendingPaymentsCount: null == pendingPaymentsCount
                ? _value.pendingPaymentsCount
                : pendingPaymentsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingPaymentsAmount: null == pendingPaymentsAmount
                ? _value.pendingPaymentsAmount
                : pendingPaymentsAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FinancialMetricsModelImplCopyWith<$Res>
    implements $FinancialMetricsModelCopyWith<$Res> {
  factory _$$FinancialMetricsModelImplCopyWith(
    _$FinancialMetricsModelImpl value,
    $Res Function(_$FinancialMetricsModelImpl) then,
  ) = __$$FinancialMetricsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'penalties_incurred_this_month')
    double penaltiesIncurredThisMonth,
    @JsonKey(name: 'penalties_incurred_all_time')
    double penaltiesIncurredAllTime,
    @JsonKey(name: 'payments_received_this_month')
    double paymentsReceivedThisMonth,
    @JsonKey(name: 'payments_received_all_time') double paymentsReceivedAllTime,
    @JsonKey(name: 'outstanding_balance') double outstandingBalance,
    @JsonKey(name: 'pending_payments_count') int pendingPaymentsCount,
    @JsonKey(name: 'pending_payments_amount') double pendingPaymentsAmount,
  });
}

/// @nodoc
class __$$FinancialMetricsModelImplCopyWithImpl<$Res>
    extends
        _$FinancialMetricsModelCopyWithImpl<$Res, _$FinancialMetricsModelImpl>
    implements _$$FinancialMetricsModelImplCopyWith<$Res> {
  __$$FinancialMetricsModelImplCopyWithImpl(
    _$FinancialMetricsModelImpl _value,
    $Res Function(_$FinancialMetricsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FinancialMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? penaltiesIncurredThisMonth = null,
    Object? penaltiesIncurredAllTime = null,
    Object? paymentsReceivedThisMonth = null,
    Object? paymentsReceivedAllTime = null,
    Object? outstandingBalance = null,
    Object? pendingPaymentsCount = null,
    Object? pendingPaymentsAmount = null,
  }) {
    return _then(
      _$FinancialMetricsModelImpl(
        penaltiesIncurredThisMonth: null == penaltiesIncurredThisMonth
            ? _value.penaltiesIncurredThisMonth
            : penaltiesIncurredThisMonth // ignore: cast_nullable_to_non_nullable
                  as double,
        penaltiesIncurredAllTime: null == penaltiesIncurredAllTime
            ? _value.penaltiesIncurredAllTime
            : penaltiesIncurredAllTime // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentsReceivedThisMonth: null == paymentsReceivedThisMonth
            ? _value.paymentsReceivedThisMonth
            : paymentsReceivedThisMonth // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentsReceivedAllTime: null == paymentsReceivedAllTime
            ? _value.paymentsReceivedAllTime
            : paymentsReceivedAllTime // ignore: cast_nullable_to_non_nullable
                  as double,
        outstandingBalance: null == outstandingBalance
            ? _value.outstandingBalance
            : outstandingBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        pendingPaymentsCount: null == pendingPaymentsCount
            ? _value.pendingPaymentsCount
            : pendingPaymentsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingPaymentsAmount: null == pendingPaymentsAmount
            ? _value.pendingPaymentsAmount
            : pendingPaymentsAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialMetricsModelImpl extends _FinancialMetricsModel {
  const _$FinancialMetricsModelImpl({
    @JsonKey(name: 'penalties_incurred_this_month')
    required this.penaltiesIncurredThisMonth,
    @JsonKey(name: 'penalties_incurred_all_time')
    required this.penaltiesIncurredAllTime,
    @JsonKey(name: 'payments_received_this_month')
    required this.paymentsReceivedThisMonth,
    @JsonKey(name: 'payments_received_all_time')
    required this.paymentsReceivedAllTime,
    @JsonKey(name: 'outstanding_balance') required this.outstandingBalance,
    @JsonKey(name: 'pending_payments_count') required this.pendingPaymentsCount,
    @JsonKey(name: 'pending_payments_amount')
    required this.pendingPaymentsAmount,
  }) : super._();

  factory _$FinancialMetricsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialMetricsModelImplFromJson(json);

  @override
  @JsonKey(name: 'penalties_incurred_this_month')
  final double penaltiesIncurredThisMonth;
  @override
  @JsonKey(name: 'penalties_incurred_all_time')
  final double penaltiesIncurredAllTime;
  @override
  @JsonKey(name: 'payments_received_this_month')
  final double paymentsReceivedThisMonth;
  @override
  @JsonKey(name: 'payments_received_all_time')
  final double paymentsReceivedAllTime;
  @override
  @JsonKey(name: 'outstanding_balance')
  final double outstandingBalance;
  @override
  @JsonKey(name: 'pending_payments_count')
  final int pendingPaymentsCount;
  @override
  @JsonKey(name: 'pending_payments_amount')
  final double pendingPaymentsAmount;

  @override
  String toString() {
    return 'FinancialMetricsModel(penaltiesIncurredThisMonth: $penaltiesIncurredThisMonth, penaltiesIncurredAllTime: $penaltiesIncurredAllTime, paymentsReceivedThisMonth: $paymentsReceivedThisMonth, paymentsReceivedAllTime: $paymentsReceivedAllTime, outstandingBalance: $outstandingBalance, pendingPaymentsCount: $pendingPaymentsCount, pendingPaymentsAmount: $pendingPaymentsAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialMetricsModelImpl &&
            (identical(
                  other.penaltiesIncurredThisMonth,
                  penaltiesIncurredThisMonth,
                ) ||
                other.penaltiesIncurredThisMonth ==
                    penaltiesIncurredThisMonth) &&
            (identical(
                  other.penaltiesIncurredAllTime,
                  penaltiesIncurredAllTime,
                ) ||
                other.penaltiesIncurredAllTime == penaltiesIncurredAllTime) &&
            (identical(
                  other.paymentsReceivedThisMonth,
                  paymentsReceivedThisMonth,
                ) ||
                other.paymentsReceivedThisMonth == paymentsReceivedThisMonth) &&
            (identical(
                  other.paymentsReceivedAllTime,
                  paymentsReceivedAllTime,
                ) ||
                other.paymentsReceivedAllTime == paymentsReceivedAllTime) &&
            (identical(other.outstandingBalance, outstandingBalance) ||
                other.outstandingBalance == outstandingBalance) &&
            (identical(other.pendingPaymentsCount, pendingPaymentsCount) ||
                other.pendingPaymentsCount == pendingPaymentsCount) &&
            (identical(other.pendingPaymentsAmount, pendingPaymentsAmount) ||
                other.pendingPaymentsAmount == pendingPaymentsAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    penaltiesIncurredThisMonth,
    penaltiesIncurredAllTime,
    paymentsReceivedThisMonth,
    paymentsReceivedAllTime,
    outstandingBalance,
    pendingPaymentsCount,
    pendingPaymentsAmount,
  );

  /// Create a copy of FinancialMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialMetricsModelImplCopyWith<_$FinancialMetricsModelImpl>
  get copyWith =>
      __$$FinancialMetricsModelImplCopyWithImpl<_$FinancialMetricsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialMetricsModelImplToJson(this);
  }
}

abstract class _FinancialMetricsModel extends FinancialMetricsModel {
  const factory _FinancialMetricsModel({
    @JsonKey(name: 'penalties_incurred_this_month')
    required final double penaltiesIncurredThisMonth,
    @JsonKey(name: 'penalties_incurred_all_time')
    required final double penaltiesIncurredAllTime,
    @JsonKey(name: 'payments_received_this_month')
    required final double paymentsReceivedThisMonth,
    @JsonKey(name: 'payments_received_all_time')
    required final double paymentsReceivedAllTime,
    @JsonKey(name: 'outstanding_balance')
    required final double outstandingBalance,
    @JsonKey(name: 'pending_payments_count')
    required final int pendingPaymentsCount,
    @JsonKey(name: 'pending_payments_amount')
    required final double pendingPaymentsAmount,
  }) = _$FinancialMetricsModelImpl;
  const _FinancialMetricsModel._() : super._();

  factory _FinancialMetricsModel.fromJson(Map<String, dynamic> json) =
      _$FinancialMetricsModelImpl.fromJson;

  @override
  @JsonKey(name: 'penalties_incurred_this_month')
  double get penaltiesIncurredThisMonth;
  @override
  @JsonKey(name: 'penalties_incurred_all_time')
  double get penaltiesIncurredAllTime;
  @override
  @JsonKey(name: 'payments_received_this_month')
  double get paymentsReceivedThisMonth;
  @override
  @JsonKey(name: 'payments_received_all_time')
  double get paymentsReceivedAllTime;
  @override
  @JsonKey(name: 'outstanding_balance')
  double get outstandingBalance;
  @override
  @JsonKey(name: 'pending_payments_count')
  int get pendingPaymentsCount;
  @override
  @JsonKey(name: 'pending_payments_amount')
  double get pendingPaymentsAmount;

  /// Create a copy of FinancialMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialMetricsModelImplCopyWith<_$FinancialMetricsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

EngagementMetricsModel _$EngagementMetricsModelFromJson(
  Map<String, dynamic> json,
) {
  return _EngagementMetricsModel.fromJson(json);
}

/// @nodoc
mixin _$EngagementMetricsModel {
  @JsonKey(name: 'daily_active_users')
  int get dailyActiveUsers => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_active_users')
  int get totalActiveUsers => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_submission_rate')
  double get reportSubmissionRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_submission_time')
  String get averageSubmissionTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'notification_open_rate')
  double get notificationOpenRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_response_time_minutes')
  int get averageResponseTimeMinutes => throw _privateConstructorUsedError;

  /// Serializes this EngagementMetricsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EngagementMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EngagementMetricsModelCopyWith<EngagementMetricsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EngagementMetricsModelCopyWith<$Res> {
  factory $EngagementMetricsModelCopyWith(
    EngagementMetricsModel value,
    $Res Function(EngagementMetricsModel) then,
  ) = _$EngagementMetricsModelCopyWithImpl<$Res, EngagementMetricsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'daily_active_users') int dailyActiveUsers,
    @JsonKey(name: 'total_active_users') int totalActiveUsers,
    @JsonKey(name: 'report_submission_rate') double reportSubmissionRate,
    @JsonKey(name: 'average_submission_time') String averageSubmissionTime,
    @JsonKey(name: 'notification_open_rate') double notificationOpenRate,
    @JsonKey(name: 'average_response_time_minutes')
    int averageResponseTimeMinutes,
  });
}

/// @nodoc
class _$EngagementMetricsModelCopyWithImpl<
  $Res,
  $Val extends EngagementMetricsModel
>
    implements $EngagementMetricsModelCopyWith<$Res> {
  _$EngagementMetricsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EngagementMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyActiveUsers = null,
    Object? totalActiveUsers = null,
    Object? reportSubmissionRate = null,
    Object? averageSubmissionTime = null,
    Object? notificationOpenRate = null,
    Object? averageResponseTimeMinutes = null,
  }) {
    return _then(
      _value.copyWith(
            dailyActiveUsers: null == dailyActiveUsers
                ? _value.dailyActiveUsers
                : dailyActiveUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalActiveUsers: null == totalActiveUsers
                ? _value.totalActiveUsers
                : totalActiveUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            reportSubmissionRate: null == reportSubmissionRate
                ? _value.reportSubmissionRate
                : reportSubmissionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageSubmissionTime: null == averageSubmissionTime
                ? _value.averageSubmissionTime
                : averageSubmissionTime // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationOpenRate: null == notificationOpenRate
                ? _value.notificationOpenRate
                : notificationOpenRate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageResponseTimeMinutes: null == averageResponseTimeMinutes
                ? _value.averageResponseTimeMinutes
                : averageResponseTimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EngagementMetricsModelImplCopyWith<$Res>
    implements $EngagementMetricsModelCopyWith<$Res> {
  factory _$$EngagementMetricsModelImplCopyWith(
    _$EngagementMetricsModelImpl value,
    $Res Function(_$EngagementMetricsModelImpl) then,
  ) = __$$EngagementMetricsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'daily_active_users') int dailyActiveUsers,
    @JsonKey(name: 'total_active_users') int totalActiveUsers,
    @JsonKey(name: 'report_submission_rate') double reportSubmissionRate,
    @JsonKey(name: 'average_submission_time') String averageSubmissionTime,
    @JsonKey(name: 'notification_open_rate') double notificationOpenRate,
    @JsonKey(name: 'average_response_time_minutes')
    int averageResponseTimeMinutes,
  });
}

/// @nodoc
class __$$EngagementMetricsModelImplCopyWithImpl<$Res>
    extends
        _$EngagementMetricsModelCopyWithImpl<$Res, _$EngagementMetricsModelImpl>
    implements _$$EngagementMetricsModelImplCopyWith<$Res> {
  __$$EngagementMetricsModelImplCopyWithImpl(
    _$EngagementMetricsModelImpl _value,
    $Res Function(_$EngagementMetricsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EngagementMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyActiveUsers = null,
    Object? totalActiveUsers = null,
    Object? reportSubmissionRate = null,
    Object? averageSubmissionTime = null,
    Object? notificationOpenRate = null,
    Object? averageResponseTimeMinutes = null,
  }) {
    return _then(
      _$EngagementMetricsModelImpl(
        dailyActiveUsers: null == dailyActiveUsers
            ? _value.dailyActiveUsers
            : dailyActiveUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalActiveUsers: null == totalActiveUsers
            ? _value.totalActiveUsers
            : totalActiveUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        reportSubmissionRate: null == reportSubmissionRate
            ? _value.reportSubmissionRate
            : reportSubmissionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageSubmissionTime: null == averageSubmissionTime
            ? _value.averageSubmissionTime
            : averageSubmissionTime // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationOpenRate: null == notificationOpenRate
            ? _value.notificationOpenRate
            : notificationOpenRate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageResponseTimeMinutes: null == averageResponseTimeMinutes
            ? _value.averageResponseTimeMinutes
            : averageResponseTimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EngagementMetricsModelImpl extends _EngagementMetricsModel {
  const _$EngagementMetricsModelImpl({
    @JsonKey(name: 'daily_active_users') required this.dailyActiveUsers,
    @JsonKey(name: 'total_active_users') required this.totalActiveUsers,
    @JsonKey(name: 'report_submission_rate') required this.reportSubmissionRate,
    @JsonKey(name: 'average_submission_time')
    required this.averageSubmissionTime,
    @JsonKey(name: 'notification_open_rate') required this.notificationOpenRate,
    @JsonKey(name: 'average_response_time_minutes')
    required this.averageResponseTimeMinutes,
  }) : super._();

  factory _$EngagementMetricsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EngagementMetricsModelImplFromJson(json);

  @override
  @JsonKey(name: 'daily_active_users')
  final int dailyActiveUsers;
  @override
  @JsonKey(name: 'total_active_users')
  final int totalActiveUsers;
  @override
  @JsonKey(name: 'report_submission_rate')
  final double reportSubmissionRate;
  @override
  @JsonKey(name: 'average_submission_time')
  final String averageSubmissionTime;
  @override
  @JsonKey(name: 'notification_open_rate')
  final double notificationOpenRate;
  @override
  @JsonKey(name: 'average_response_time_minutes')
  final int averageResponseTimeMinutes;

  @override
  String toString() {
    return 'EngagementMetricsModel(dailyActiveUsers: $dailyActiveUsers, totalActiveUsers: $totalActiveUsers, reportSubmissionRate: $reportSubmissionRate, averageSubmissionTime: $averageSubmissionTime, notificationOpenRate: $notificationOpenRate, averageResponseTimeMinutes: $averageResponseTimeMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EngagementMetricsModelImpl &&
            (identical(other.dailyActiveUsers, dailyActiveUsers) ||
                other.dailyActiveUsers == dailyActiveUsers) &&
            (identical(other.totalActiveUsers, totalActiveUsers) ||
                other.totalActiveUsers == totalActiveUsers) &&
            (identical(other.reportSubmissionRate, reportSubmissionRate) ||
                other.reportSubmissionRate == reportSubmissionRate) &&
            (identical(other.averageSubmissionTime, averageSubmissionTime) ||
                other.averageSubmissionTime == averageSubmissionTime) &&
            (identical(other.notificationOpenRate, notificationOpenRate) ||
                other.notificationOpenRate == notificationOpenRate) &&
            (identical(
                  other.averageResponseTimeMinutes,
                  averageResponseTimeMinutes,
                ) ||
                other.averageResponseTimeMinutes ==
                    averageResponseTimeMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dailyActiveUsers,
    totalActiveUsers,
    reportSubmissionRate,
    averageSubmissionTime,
    notificationOpenRate,
    averageResponseTimeMinutes,
  );

  /// Create a copy of EngagementMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EngagementMetricsModelImplCopyWith<_$EngagementMetricsModelImpl>
  get copyWith =>
      __$$EngagementMetricsModelImplCopyWithImpl<_$EngagementMetricsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EngagementMetricsModelImplToJson(this);
  }
}

abstract class _EngagementMetricsModel extends EngagementMetricsModel {
  const factory _EngagementMetricsModel({
    @JsonKey(name: 'daily_active_users') required final int dailyActiveUsers,
    @JsonKey(name: 'total_active_users') required final int totalActiveUsers,
    @JsonKey(name: 'report_submission_rate')
    required final double reportSubmissionRate,
    @JsonKey(name: 'average_submission_time')
    required final String averageSubmissionTime,
    @JsonKey(name: 'notification_open_rate')
    required final double notificationOpenRate,
    @JsonKey(name: 'average_response_time_minutes')
    required final int averageResponseTimeMinutes,
  }) = _$EngagementMetricsModelImpl;
  const _EngagementMetricsModel._() : super._();

  factory _EngagementMetricsModel.fromJson(Map<String, dynamic> json) =
      _$EngagementMetricsModelImpl.fromJson;

  @override
  @JsonKey(name: 'daily_active_users')
  int get dailyActiveUsers;
  @override
  @JsonKey(name: 'total_active_users')
  int get totalActiveUsers;
  @override
  @JsonKey(name: 'report_submission_rate')
  double get reportSubmissionRate;
  @override
  @JsonKey(name: 'average_submission_time')
  String get averageSubmissionTime;
  @override
  @JsonKey(name: 'notification_open_rate')
  double get notificationOpenRate;
  @override
  @JsonKey(name: 'average_response_time_minutes')
  int get averageResponseTimeMinutes;

  /// Create a copy of EngagementMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EngagementMetricsModelImplCopyWith<_$EngagementMetricsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExcuseMetricsModel _$ExcuseMetricsModelFromJson(Map<String, dynamic> json) {
  return _ExcuseMetricsModel.fromJson(json);
}

/// @nodoc
mixin _$ExcuseMetricsModel {
  @JsonKey(name: 'pending_excuses')
  int get pendingExcuses => throw _privateConstructorUsedError;
  @JsonKey(name: 'approval_rate')
  double get approvalRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'excuses_by_reason')
  Map<String, int> get excusesByReason => throw _privateConstructorUsedError;

  /// Serializes this ExcuseMetricsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExcuseMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExcuseMetricsModelCopyWith<ExcuseMetricsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExcuseMetricsModelCopyWith<$Res> {
  factory $ExcuseMetricsModelCopyWith(
    ExcuseMetricsModel value,
    $Res Function(ExcuseMetricsModel) then,
  ) = _$ExcuseMetricsModelCopyWithImpl<$Res, ExcuseMetricsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'pending_excuses') int pendingExcuses,
    @JsonKey(name: 'approval_rate') double approvalRate,
    @JsonKey(name: 'excuses_by_reason') Map<String, int> excusesByReason,
  });
}

/// @nodoc
class _$ExcuseMetricsModelCopyWithImpl<$Res, $Val extends ExcuseMetricsModel>
    implements $ExcuseMetricsModelCopyWith<$Res> {
  _$ExcuseMetricsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExcuseMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pendingExcuses = null,
    Object? approvalRate = null,
    Object? excusesByReason = null,
  }) {
    return _then(
      _value.copyWith(
            pendingExcuses: null == pendingExcuses
                ? _value.pendingExcuses
                : pendingExcuses // ignore: cast_nullable_to_non_nullable
                      as int,
            approvalRate: null == approvalRate
                ? _value.approvalRate
                : approvalRate // ignore: cast_nullable_to_non_nullable
                      as double,
            excusesByReason: null == excusesByReason
                ? _value.excusesByReason
                : excusesByReason // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExcuseMetricsModelImplCopyWith<$Res>
    implements $ExcuseMetricsModelCopyWith<$Res> {
  factory _$$ExcuseMetricsModelImplCopyWith(
    _$ExcuseMetricsModelImpl value,
    $Res Function(_$ExcuseMetricsModelImpl) then,
  ) = __$$ExcuseMetricsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pending_excuses') int pendingExcuses,
    @JsonKey(name: 'approval_rate') double approvalRate,
    @JsonKey(name: 'excuses_by_reason') Map<String, int> excusesByReason,
  });
}

/// @nodoc
class __$$ExcuseMetricsModelImplCopyWithImpl<$Res>
    extends _$ExcuseMetricsModelCopyWithImpl<$Res, _$ExcuseMetricsModelImpl>
    implements _$$ExcuseMetricsModelImplCopyWith<$Res> {
  __$$ExcuseMetricsModelImplCopyWithImpl(
    _$ExcuseMetricsModelImpl _value,
    $Res Function(_$ExcuseMetricsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExcuseMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pendingExcuses = null,
    Object? approvalRate = null,
    Object? excusesByReason = null,
  }) {
    return _then(
      _$ExcuseMetricsModelImpl(
        pendingExcuses: null == pendingExcuses
            ? _value.pendingExcuses
            : pendingExcuses // ignore: cast_nullable_to_non_nullable
                  as int,
        approvalRate: null == approvalRate
            ? _value.approvalRate
            : approvalRate // ignore: cast_nullable_to_non_nullable
                  as double,
        excusesByReason: null == excusesByReason
            ? _value._excusesByReason
            : excusesByReason // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExcuseMetricsModelImpl extends _ExcuseMetricsModel {
  const _$ExcuseMetricsModelImpl({
    @JsonKey(name: 'pending_excuses') required this.pendingExcuses,
    @JsonKey(name: 'approval_rate') required this.approvalRate,
    @JsonKey(name: 'excuses_by_reason')
    required final Map<String, int> excusesByReason,
  }) : _excusesByReason = excusesByReason,
       super._();

  factory _$ExcuseMetricsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExcuseMetricsModelImplFromJson(json);

  @override
  @JsonKey(name: 'pending_excuses')
  final int pendingExcuses;
  @override
  @JsonKey(name: 'approval_rate')
  final double approvalRate;
  final Map<String, int> _excusesByReason;
  @override
  @JsonKey(name: 'excuses_by_reason')
  Map<String, int> get excusesByReason {
    if (_excusesByReason is EqualUnmodifiableMapView) return _excusesByReason;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_excusesByReason);
  }

  @override
  String toString() {
    return 'ExcuseMetricsModel(pendingExcuses: $pendingExcuses, approvalRate: $approvalRate, excusesByReason: $excusesByReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExcuseMetricsModelImpl &&
            (identical(other.pendingExcuses, pendingExcuses) ||
                other.pendingExcuses == pendingExcuses) &&
            (identical(other.approvalRate, approvalRate) ||
                other.approvalRate == approvalRate) &&
            const DeepCollectionEquality().equals(
              other._excusesByReason,
              _excusesByReason,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pendingExcuses,
    approvalRate,
    const DeepCollectionEquality().hash(_excusesByReason),
  );

  /// Create a copy of ExcuseMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExcuseMetricsModelImplCopyWith<_$ExcuseMetricsModelImpl> get copyWith =>
      __$$ExcuseMetricsModelImplCopyWithImpl<_$ExcuseMetricsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExcuseMetricsModelImplToJson(this);
  }
}

abstract class _ExcuseMetricsModel extends ExcuseMetricsModel {
  const factory _ExcuseMetricsModel({
    @JsonKey(name: 'pending_excuses') required final int pendingExcuses,
    @JsonKey(name: 'approval_rate') required final double approvalRate,
    @JsonKey(name: 'excuses_by_reason')
    required final Map<String, int> excusesByReason,
  }) = _$ExcuseMetricsModelImpl;
  const _ExcuseMetricsModel._() : super._();

  factory _ExcuseMetricsModel.fromJson(Map<String, dynamic> json) =
      _$ExcuseMetricsModelImpl.fromJson;

  @override
  @JsonKey(name: 'pending_excuses')
  int get pendingExcuses;
  @override
  @JsonKey(name: 'approval_rate')
  double get approvalRate;
  @override
  @JsonKey(name: 'excuses_by_reason')
  Map<String, int> get excusesByReason;

  /// Create a copy of ExcuseMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExcuseMetricsModelImplCopyWith<_$ExcuseMetricsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
