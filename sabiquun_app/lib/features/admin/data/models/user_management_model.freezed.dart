// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_management_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserManagementModel _$UserManagementModelFromJson(Map<String, dynamic> json) {
  return _UserManagementModel.fromJson(json);
}

/// @nodoc
mixin _$UserManagementModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_status')
  String get accountStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'membership_status')
  String get membershipStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'excuse_mode')
  bool get excuseMode => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'approved_by')
  String? get approvedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'approved_at')
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_balance')
  double get currentBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_reports')
  int get totalReports => throw _privateConstructorUsedError;
  @JsonKey(name: 'compliance_rate')
  double get complianceRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_report_date')
  DateTime? get lastReportDate => throw _privateConstructorUsedError;

  /// Serializes this UserManagementModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserManagementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserManagementModelCopyWith<UserManagementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserManagementModelCopyWith<$Res> {
  factory $UserManagementModelCopyWith(
    UserManagementModel value,
    $Res Function(UserManagementModel) then,
  ) = _$UserManagementModelCopyWithImpl<$Res, UserManagementModel>;
  @useResult
  $Res call({
    String id,
    String email,
    String name,
    String? phone,
    @JsonKey(name: 'photo_url') String? photoUrl,
    String role,
    @JsonKey(name: 'account_status') String accountStatus,
    @JsonKey(name: 'membership_status') String membershipStatus,
    @JsonKey(name: 'excuse_mode') bool excuseMode,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'approved_by') String? approvedBy,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'current_balance') double currentBalance,
    @JsonKey(name: 'total_reports') int totalReports,
    @JsonKey(name: 'compliance_rate') double complianceRate,
    @JsonKey(name: 'last_report_date') DateTime? lastReportDate,
  });
}

/// @nodoc
class _$UserManagementModelCopyWithImpl<$Res, $Val extends UserManagementModel>
    implements $UserManagementModelCopyWith<$Res> {
  _$UserManagementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserManagementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? phone = freezed,
    Object? photoUrl = freezed,
    Object? role = null,
    Object? accountStatus = null,
    Object? membershipStatus = null,
    Object? excuseMode = null,
    Object? createdAt = null,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? updatedAt = null,
    Object? currentBalance = null,
    Object? totalReports = null,
    Object? complianceRate = null,
    Object? lastReportDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            accountStatus: null == accountStatus
                ? _value.accountStatus
                : accountStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            membershipStatus: null == membershipStatus
                ? _value.membershipStatus
                : membershipStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            excuseMode: null == excuseMode
                ? _value.excuseMode
                : excuseMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            approvedBy: freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            approvedAt: freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            currentBalance: null == currentBalance
                ? _value.currentBalance
                : currentBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            totalReports: null == totalReports
                ? _value.totalReports
                : totalReports // ignore: cast_nullable_to_non_nullable
                      as int,
            complianceRate: null == complianceRate
                ? _value.complianceRate
                : complianceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            lastReportDate: freezed == lastReportDate
                ? _value.lastReportDate
                : lastReportDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserManagementModelImplCopyWith<$Res>
    implements $UserManagementModelCopyWith<$Res> {
  factory _$$UserManagementModelImplCopyWith(
    _$UserManagementModelImpl value,
    $Res Function(_$UserManagementModelImpl) then,
  ) = __$$UserManagementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String name,
    String? phone,
    @JsonKey(name: 'photo_url') String? photoUrl,
    String role,
    @JsonKey(name: 'account_status') String accountStatus,
    @JsonKey(name: 'membership_status') String membershipStatus,
    @JsonKey(name: 'excuse_mode') bool excuseMode,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'approved_by') String? approvedBy,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'current_balance') double currentBalance,
    @JsonKey(name: 'total_reports') int totalReports,
    @JsonKey(name: 'compliance_rate') double complianceRate,
    @JsonKey(name: 'last_report_date') DateTime? lastReportDate,
  });
}

/// @nodoc
class __$$UserManagementModelImplCopyWithImpl<$Res>
    extends _$UserManagementModelCopyWithImpl<$Res, _$UserManagementModelImpl>
    implements _$$UserManagementModelImplCopyWith<$Res> {
  __$$UserManagementModelImplCopyWithImpl(
    _$UserManagementModelImpl _value,
    $Res Function(_$UserManagementModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserManagementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? phone = freezed,
    Object? photoUrl = freezed,
    Object? role = null,
    Object? accountStatus = null,
    Object? membershipStatus = null,
    Object? excuseMode = null,
    Object? createdAt = null,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? updatedAt = null,
    Object? currentBalance = null,
    Object? totalReports = null,
    Object? complianceRate = null,
    Object? lastReportDate = freezed,
  }) {
    return _then(
      _$UserManagementModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        accountStatus: null == accountStatus
            ? _value.accountStatus
            : accountStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        membershipStatus: null == membershipStatus
            ? _value.membershipStatus
            : membershipStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        excuseMode: null == excuseMode
            ? _value.excuseMode
            : excuseMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        approvedBy: freezed == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        approvedAt: freezed == approvedAt
            ? _value.approvedAt
            : approvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        currentBalance: null == currentBalance
            ? _value.currentBalance
            : currentBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        totalReports: null == totalReports
            ? _value.totalReports
            : totalReports // ignore: cast_nullable_to_non_nullable
                  as int,
        complianceRate: null == complianceRate
            ? _value.complianceRate
            : complianceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        lastReportDate: freezed == lastReportDate
            ? _value.lastReportDate
            : lastReportDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserManagementModelImpl extends _UserManagementModel {
  const _$UserManagementModelImpl({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    @JsonKey(name: 'photo_url') this.photoUrl,
    required this.role,
    @JsonKey(name: 'account_status') required this.accountStatus,
    @JsonKey(name: 'membership_status') required this.membershipStatus,
    @JsonKey(name: 'excuse_mode') this.excuseMode = false,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'approved_by') this.approvedBy,
    @JsonKey(name: 'approved_at') this.approvedAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'current_balance') this.currentBalance = 0.0,
    @JsonKey(name: 'total_reports') this.totalReports = 0,
    @JsonKey(name: 'compliance_rate') this.complianceRate = 0.0,
    @JsonKey(name: 'last_report_date') this.lastReportDate,
  }) : super._();

  factory _$UserManagementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserManagementModelImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  final String? phone;
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @override
  final String role;
  @override
  @JsonKey(name: 'account_status')
  final String accountStatus;
  @override
  @JsonKey(name: 'membership_status')
  final String membershipStatus;
  @override
  @JsonKey(name: 'excuse_mode')
  final bool excuseMode;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'approved_by')
  final String? approvedBy;
  @override
  @JsonKey(name: 'approved_at')
  final DateTime? approvedAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'current_balance')
  final double currentBalance;
  @override
  @JsonKey(name: 'total_reports')
  final int totalReports;
  @override
  @JsonKey(name: 'compliance_rate')
  final double complianceRate;
  @override
  @JsonKey(name: 'last_report_date')
  final DateTime? lastReportDate;

  @override
  String toString() {
    return 'UserManagementModel(id: $id, email: $email, name: $name, phone: $phone, photoUrl: $photoUrl, role: $role, accountStatus: $accountStatus, membershipStatus: $membershipStatus, excuseMode: $excuseMode, createdAt: $createdAt, approvedBy: $approvedBy, approvedAt: $approvedAt, updatedAt: $updatedAt, currentBalance: $currentBalance, totalReports: $totalReports, complianceRate: $complianceRate, lastReportDate: $lastReportDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserManagementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.accountStatus, accountStatus) ||
                other.accountStatus == accountStatus) &&
            (identical(other.membershipStatus, membershipStatus) ||
                other.membershipStatus == membershipStatus) &&
            (identical(other.excuseMode, excuseMode) ||
                other.excuseMode == excuseMode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.totalReports, totalReports) ||
                other.totalReports == totalReports) &&
            (identical(other.complianceRate, complianceRate) ||
                other.complianceRate == complianceRate) &&
            (identical(other.lastReportDate, lastReportDate) ||
                other.lastReportDate == lastReportDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    name,
    phone,
    photoUrl,
    role,
    accountStatus,
    membershipStatus,
    excuseMode,
    createdAt,
    approvedBy,
    approvedAt,
    updatedAt,
    currentBalance,
    totalReports,
    complianceRate,
    lastReportDate,
  );

  /// Create a copy of UserManagementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserManagementModelImplCopyWith<_$UserManagementModelImpl> get copyWith =>
      __$$UserManagementModelImplCopyWithImpl<_$UserManagementModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserManagementModelImplToJson(this);
  }
}

abstract class _UserManagementModel extends UserManagementModel {
  const factory _UserManagementModel({
    required final String id,
    required final String email,
    required final String name,
    final String? phone,
    @JsonKey(name: 'photo_url') final String? photoUrl,
    required final String role,
    @JsonKey(name: 'account_status') required final String accountStatus,
    @JsonKey(name: 'membership_status') required final String membershipStatus,
    @JsonKey(name: 'excuse_mode') final bool excuseMode,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'approved_by') final String? approvedBy,
    @JsonKey(name: 'approved_at') final DateTime? approvedAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'current_balance') final double currentBalance,
    @JsonKey(name: 'total_reports') final int totalReports,
    @JsonKey(name: 'compliance_rate') final double complianceRate,
    @JsonKey(name: 'last_report_date') final DateTime? lastReportDate,
  }) = _$UserManagementModelImpl;
  const _UserManagementModel._() : super._();

  factory _UserManagementModel.fromJson(Map<String, dynamic> json) =
      _$UserManagementModelImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  String? get phone;
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;
  @override
  String get role;
  @override
  @JsonKey(name: 'account_status')
  String get accountStatus;
  @override
  @JsonKey(name: 'membership_status')
  String get membershipStatus;
  @override
  @JsonKey(name: 'excuse_mode')
  bool get excuseMode;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'approved_by')
  String? get approvedBy;
  @override
  @JsonKey(name: 'approved_at')
  DateTime? get approvedAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'current_balance')
  double get currentBalance;
  @override
  @JsonKey(name: 'total_reports')
  int get totalReports;
  @override
  @JsonKey(name: 'compliance_rate')
  double get complianceRate;
  @override
  @JsonKey(name: 'last_report_date')
  DateTime? get lastReportDate;

  /// Create a copy of UserManagementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserManagementModelImplCopyWith<_$UserManagementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
