// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detailed_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeedDetailModel _$DeedDetailModelFromJson(Map<String, dynamic> json) {
  return _DeedDetailModel.fromJson(json);
}

/// @nodoc
mixin _$DeedDetailModel {
  String get deedName => throw _privateConstructorUsedError;
  String get deedKey => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // 'faraid' or 'sunnah'
  String get valueType =>
      throw _privateConstructorUsedError; // 'binary' or 'fractional'
  double get deedValue =>
      throw _privateConstructorUsedError; // 0, 1, or 0.0-1.0 for fractional
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this DeedDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeedDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeedDetailModelCopyWith<DeedDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeedDetailModelCopyWith<$Res> {
  factory $DeedDetailModelCopyWith(
    DeedDetailModel value,
    $Res Function(DeedDetailModel) then,
  ) = _$DeedDetailModelCopyWithImpl<$Res, DeedDetailModel>;
  @useResult
  $Res call({
    String deedName,
    String deedKey,
    String category,
    String valueType,
    double deedValue,
    int sortOrder,
  });
}

/// @nodoc
class _$DeedDetailModelCopyWithImpl<$Res, $Val extends DeedDetailModel>
    implements $DeedDetailModelCopyWith<$Res> {
  _$DeedDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeedDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deedName = null,
    Object? deedKey = null,
    Object? category = null,
    Object? valueType = null,
    Object? deedValue = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            deedName: null == deedName
                ? _value.deedName
                : deedName // ignore: cast_nullable_to_non_nullable
                      as String,
            deedKey: null == deedKey
                ? _value.deedKey
                : deedKey // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            valueType: null == valueType
                ? _value.valueType
                : valueType // ignore: cast_nullable_to_non_nullable
                      as String,
            deedValue: null == deedValue
                ? _value.deedValue
                : deedValue // ignore: cast_nullable_to_non_nullable
                      as double,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeedDetailModelImplCopyWith<$Res>
    implements $DeedDetailModelCopyWith<$Res> {
  factory _$$DeedDetailModelImplCopyWith(
    _$DeedDetailModelImpl value,
    $Res Function(_$DeedDetailModelImpl) then,
  ) = __$$DeedDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String deedName,
    String deedKey,
    String category,
    String valueType,
    double deedValue,
    int sortOrder,
  });
}

/// @nodoc
class __$$DeedDetailModelImplCopyWithImpl<$Res>
    extends _$DeedDetailModelCopyWithImpl<$Res, _$DeedDetailModelImpl>
    implements _$$DeedDetailModelImplCopyWith<$Res> {
  __$$DeedDetailModelImplCopyWithImpl(
    _$DeedDetailModelImpl _value,
    $Res Function(_$DeedDetailModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeedDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deedName = null,
    Object? deedKey = null,
    Object? category = null,
    Object? valueType = null,
    Object? deedValue = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _$DeedDetailModelImpl(
        deedName: null == deedName
            ? _value.deedName
            : deedName // ignore: cast_nullable_to_non_nullable
                  as String,
        deedKey: null == deedKey
            ? _value.deedKey
            : deedKey // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        valueType: null == valueType
            ? _value.valueType
            : valueType // ignore: cast_nullable_to_non_nullable
                  as String,
        deedValue: null == deedValue
            ? _value.deedValue
            : deedValue // ignore: cast_nullable_to_non_nullable
                  as double,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeedDetailModelImpl extends _DeedDetailModel {
  const _$DeedDetailModelImpl({
    required this.deedName,
    required this.deedKey,
    required this.category,
    required this.valueType,
    required this.deedValue,
    required this.sortOrder,
  }) : super._();

  factory _$DeedDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeedDetailModelImplFromJson(json);

  @override
  final String deedName;
  @override
  final String deedKey;
  @override
  final String category;
  // 'faraid' or 'sunnah'
  @override
  final String valueType;
  // 'binary' or 'fractional'
  @override
  final double deedValue;
  // 0, 1, or 0.0-1.0 for fractional
  @override
  final int sortOrder;

  @override
  String toString() {
    return 'DeedDetailModel(deedName: $deedName, deedKey: $deedKey, category: $category, valueType: $valueType, deedValue: $deedValue, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeedDetailModelImpl &&
            (identical(other.deedName, deedName) ||
                other.deedName == deedName) &&
            (identical(other.deedKey, deedKey) || other.deedKey == deedKey) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.valueType, valueType) ||
                other.valueType == valueType) &&
            (identical(other.deedValue, deedValue) ||
                other.deedValue == deedValue) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deedName,
    deedKey,
    category,
    valueType,
    deedValue,
    sortOrder,
  );

  /// Create a copy of DeedDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeedDetailModelImplCopyWith<_$DeedDetailModelImpl> get copyWith =>
      __$$DeedDetailModelImplCopyWithImpl<_$DeedDetailModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeedDetailModelImplToJson(this);
  }
}

abstract class _DeedDetailModel extends DeedDetailModel {
  const factory _DeedDetailModel({
    required final String deedName,
    required final String deedKey,
    required final String category,
    required final String valueType,
    required final double deedValue,
    required final int sortOrder,
  }) = _$DeedDetailModelImpl;
  const _DeedDetailModel._() : super._();

  factory _DeedDetailModel.fromJson(Map<String, dynamic> json) =
      _$DeedDetailModelImpl.fromJson;

  @override
  String get deedName;
  @override
  String get deedKey;
  @override
  String get category; // 'faraid' or 'sunnah'
  @override
  String get valueType; // 'binary' or 'fractional'
  @override
  double get deedValue; // 0, 1, or 0.0-1.0 for fractional
  @override
  int get sortOrder;

  /// Create a copy of DeedDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeedDetailModelImplCopyWith<_$DeedDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyReportDetailModel _$DailyReportDetailModelFromJson(
  Map<String, dynamic> json,
) {
  return _DailyReportDetailModel.fromJson(json);
}

/// @nodoc
mixin _$DailyReportDetailModel {
  DateTime get reportDate => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'draft' or 'submitted'
  double get totalDeeds => throw _privateConstructorUsedError;
  double get faraidCount => throw _privateConstructorUsedError;
  double get sunnahCount => throw _privateConstructorUsedError;
  List<DeedDetailModel> get deedEntries => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this DailyReportDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyReportDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyReportDetailModelCopyWith<DailyReportDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyReportDetailModelCopyWith<$Res> {
  factory $DailyReportDetailModelCopyWith(
    DailyReportDetailModel value,
    $Res Function(DailyReportDetailModel) then,
  ) = _$DailyReportDetailModelCopyWithImpl<$Res, DailyReportDetailModel>;
  @useResult
  $Res call({
    DateTime reportDate,
    String status,
    double totalDeeds,
    double faraidCount,
    double sunnahCount,
    List<DeedDetailModel> deedEntries,
    DateTime? submittedAt,
  });
}

/// @nodoc
class _$DailyReportDetailModelCopyWithImpl<
  $Res,
  $Val extends DailyReportDetailModel
>
    implements $DailyReportDetailModelCopyWith<$Res> {
  _$DailyReportDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyReportDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportDate = null,
    Object? status = null,
    Object? totalDeeds = null,
    Object? faraidCount = null,
    Object? sunnahCount = null,
    Object? deedEntries = null,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            reportDate: null == reportDate
                ? _value.reportDate
                : reportDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            totalDeeds: null == totalDeeds
                ? _value.totalDeeds
                : totalDeeds // ignore: cast_nullable_to_non_nullable
                      as double,
            faraidCount: null == faraidCount
                ? _value.faraidCount
                : faraidCount // ignore: cast_nullable_to_non_nullable
                      as double,
            sunnahCount: null == sunnahCount
                ? _value.sunnahCount
                : sunnahCount // ignore: cast_nullable_to_non_nullable
                      as double,
            deedEntries: null == deedEntries
                ? _value.deedEntries
                : deedEntries // ignore: cast_nullable_to_non_nullable
                      as List<DeedDetailModel>,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyReportDetailModelImplCopyWith<$Res>
    implements $DailyReportDetailModelCopyWith<$Res> {
  factory _$$DailyReportDetailModelImplCopyWith(
    _$DailyReportDetailModelImpl value,
    $Res Function(_$DailyReportDetailModelImpl) then,
  ) = __$$DailyReportDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime reportDate,
    String status,
    double totalDeeds,
    double faraidCount,
    double sunnahCount,
    List<DeedDetailModel> deedEntries,
    DateTime? submittedAt,
  });
}

/// @nodoc
class __$$DailyReportDetailModelImplCopyWithImpl<$Res>
    extends
        _$DailyReportDetailModelCopyWithImpl<$Res, _$DailyReportDetailModelImpl>
    implements _$$DailyReportDetailModelImplCopyWith<$Res> {
  __$$DailyReportDetailModelImplCopyWithImpl(
    _$DailyReportDetailModelImpl _value,
    $Res Function(_$DailyReportDetailModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyReportDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportDate = null,
    Object? status = null,
    Object? totalDeeds = null,
    Object? faraidCount = null,
    Object? sunnahCount = null,
    Object? deedEntries = null,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _$DailyReportDetailModelImpl(
        reportDate: null == reportDate
            ? _value.reportDate
            : reportDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        totalDeeds: null == totalDeeds
            ? _value.totalDeeds
            : totalDeeds // ignore: cast_nullable_to_non_nullable
                  as double,
        faraidCount: null == faraidCount
            ? _value.faraidCount
            : faraidCount // ignore: cast_nullable_to_non_nullable
                  as double,
        sunnahCount: null == sunnahCount
            ? _value.sunnahCount
            : sunnahCount // ignore: cast_nullable_to_non_nullable
                  as double,
        deedEntries: null == deedEntries
            ? _value._deedEntries
            : deedEntries // ignore: cast_nullable_to_non_nullable
                  as List<DeedDetailModel>,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyReportDetailModelImpl extends _DailyReportDetailModel {
  const _$DailyReportDetailModelImpl({
    required this.reportDate,
    required this.status,
    required this.totalDeeds,
    required this.faraidCount,
    required this.sunnahCount,
    required final List<DeedDetailModel> deedEntries,
    this.submittedAt,
  }) : _deedEntries = deedEntries,
       super._();

  factory _$DailyReportDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyReportDetailModelImplFromJson(json);

  @override
  final DateTime reportDate;
  @override
  final String status;
  // 'draft' or 'submitted'
  @override
  final double totalDeeds;
  @override
  final double faraidCount;
  @override
  final double sunnahCount;
  final List<DeedDetailModel> _deedEntries;
  @override
  List<DeedDetailModel> get deedEntries {
    if (_deedEntries is EqualUnmodifiableListView) return _deedEntries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deedEntries);
  }

  @override
  final DateTime? submittedAt;

  @override
  String toString() {
    return 'DailyReportDetailModel(reportDate: $reportDate, status: $status, totalDeeds: $totalDeeds, faraidCount: $faraidCount, sunnahCount: $sunnahCount, deedEntries: $deedEntries, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyReportDetailModelImpl &&
            (identical(other.reportDate, reportDate) ||
                other.reportDate == reportDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalDeeds, totalDeeds) ||
                other.totalDeeds == totalDeeds) &&
            (identical(other.faraidCount, faraidCount) ||
                other.faraidCount == faraidCount) &&
            (identical(other.sunnahCount, sunnahCount) ||
                other.sunnahCount == sunnahCount) &&
            const DeepCollectionEquality().equals(
              other._deedEntries,
              _deedEntries,
            ) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    reportDate,
    status,
    totalDeeds,
    faraidCount,
    sunnahCount,
    const DeepCollectionEquality().hash(_deedEntries),
    submittedAt,
  );

  /// Create a copy of DailyReportDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyReportDetailModelImplCopyWith<_$DailyReportDetailModelImpl>
  get copyWith =>
      __$$DailyReportDetailModelImplCopyWithImpl<_$DailyReportDetailModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyReportDetailModelImplToJson(this);
  }
}

abstract class _DailyReportDetailModel extends DailyReportDetailModel {
  const factory _DailyReportDetailModel({
    required final DateTime reportDate,
    required final String status,
    required final double totalDeeds,
    required final double faraidCount,
    required final double sunnahCount,
    required final List<DeedDetailModel> deedEntries,
    final DateTime? submittedAt,
  }) = _$DailyReportDetailModelImpl;
  const _DailyReportDetailModel._() : super._();

  factory _DailyReportDetailModel.fromJson(Map<String, dynamic> json) =
      _$DailyReportDetailModelImpl.fromJson;

  @override
  DateTime get reportDate;
  @override
  String get status; // 'draft' or 'submitted'
  @override
  double get totalDeeds;
  @override
  double get faraidCount;
  @override
  double get sunnahCount;
  @override
  List<DeedDetailModel> get deedEntries;
  @override
  DateTime? get submittedAt;

  /// Create a copy of DailyReportDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyReportDetailModelImplCopyWith<_$DailyReportDetailModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DetailedUserReportModel _$DetailedUserReportModelFromJson(
  Map<String, dynamic> json,
) {
  return _DetailedUserReportModel.fromJson(json);
}

/// @nodoc
mixin _$DetailedUserReportModel {
  // User Information
  String get userId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;
  String get membershipStatus => throw _privateConstructorUsedError;
  DateTime? get memberSince => throw _privateConstructorUsedError; // Date Range
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate =>
      throw _privateConstructorUsedError; // Summary Statistics
  int get totalReportsInRange => throw _privateConstructorUsedError;
  double get averageDeeds => throw _privateConstructorUsedError;
  double get complianceRate => throw _privateConstructorUsedError;
  double get faraidCompliance => throw _privateConstructorUsedError;
  double get sunnahCompliance => throw _privateConstructorUsedError;
  double get currentBalance =>
      throw _privateConstructorUsedError; // Daily Reports
  List<DailyReportDetailModel> get dailyReports =>
      throw _privateConstructorUsedError; // Achievement Tags
  List<String> get achievementTags => throw _privateConstructorUsedError;

  /// Serializes this DetailedUserReportModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetailedUserReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetailedUserReportModelCopyWith<DetailedUserReportModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetailedUserReportModelCopyWith<$Res> {
  factory $DetailedUserReportModelCopyWith(
    DetailedUserReportModel value,
    $Res Function(DetailedUserReportModel) then,
  ) = _$DetailedUserReportModelCopyWithImpl<$Res, DetailedUserReportModel>;
  @useResult
  $Res call({
    String userId,
    String fullName,
    String email,
    String? phoneNumber,
    String? profilePhotoUrl,
    String membershipStatus,
    DateTime? memberSince,
    DateTime startDate,
    DateTime endDate,
    int totalReportsInRange,
    double averageDeeds,
    double complianceRate,
    double faraidCompliance,
    double sunnahCompliance,
    double currentBalance,
    List<DailyReportDetailModel> dailyReports,
    List<String> achievementTags,
  });
}

/// @nodoc
class _$DetailedUserReportModelCopyWithImpl<
  $Res,
  $Val extends DetailedUserReportModel
>
    implements $DetailedUserReportModelCopyWith<$Res> {
  _$DetailedUserReportModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetailedUserReportModel
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
    Object? startDate = null,
    Object? endDate = null,
    Object? totalReportsInRange = null,
    Object? averageDeeds = null,
    Object? complianceRate = null,
    Object? faraidCompliance = null,
    Object? sunnahCompliance = null,
    Object? currentBalance = null,
    Object? dailyReports = null,
    Object? achievementTags = null,
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
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalReportsInRange: null == totalReportsInRange
                ? _value.totalReportsInRange
                : totalReportsInRange // ignore: cast_nullable_to_non_nullable
                      as int,
            averageDeeds: null == averageDeeds
                ? _value.averageDeeds
                : averageDeeds // ignore: cast_nullable_to_non_nullable
                      as double,
            complianceRate: null == complianceRate
                ? _value.complianceRate
                : complianceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            faraidCompliance: null == faraidCompliance
                ? _value.faraidCompliance
                : faraidCompliance // ignore: cast_nullable_to_non_nullable
                      as double,
            sunnahCompliance: null == sunnahCompliance
                ? _value.sunnahCompliance
                : sunnahCompliance // ignore: cast_nullable_to_non_nullable
                      as double,
            currentBalance: null == currentBalance
                ? _value.currentBalance
                : currentBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            dailyReports: null == dailyReports
                ? _value.dailyReports
                : dailyReports // ignore: cast_nullable_to_non_nullable
                      as List<DailyReportDetailModel>,
            achievementTags: null == achievementTags
                ? _value.achievementTags
                : achievementTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DetailedUserReportModelImplCopyWith<$Res>
    implements $DetailedUserReportModelCopyWith<$Res> {
  factory _$$DetailedUserReportModelImplCopyWith(
    _$DetailedUserReportModelImpl value,
    $Res Function(_$DetailedUserReportModelImpl) then,
  ) = __$$DetailedUserReportModelImplCopyWithImpl<$Res>;
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
    DateTime startDate,
    DateTime endDate,
    int totalReportsInRange,
    double averageDeeds,
    double complianceRate,
    double faraidCompliance,
    double sunnahCompliance,
    double currentBalance,
    List<DailyReportDetailModel> dailyReports,
    List<String> achievementTags,
  });
}

/// @nodoc
class __$$DetailedUserReportModelImplCopyWithImpl<$Res>
    extends
        _$DetailedUserReportModelCopyWithImpl<
          $Res,
          _$DetailedUserReportModelImpl
        >
    implements _$$DetailedUserReportModelImplCopyWith<$Res> {
  __$$DetailedUserReportModelImplCopyWithImpl(
    _$DetailedUserReportModelImpl _value,
    $Res Function(_$DetailedUserReportModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DetailedUserReportModel
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
    Object? startDate = null,
    Object? endDate = null,
    Object? totalReportsInRange = null,
    Object? averageDeeds = null,
    Object? complianceRate = null,
    Object? faraidCompliance = null,
    Object? sunnahCompliance = null,
    Object? currentBalance = null,
    Object? dailyReports = null,
    Object? achievementTags = null,
  }) {
    return _then(
      _$DetailedUserReportModelImpl(
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
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalReportsInRange: null == totalReportsInRange
            ? _value.totalReportsInRange
            : totalReportsInRange // ignore: cast_nullable_to_non_nullable
                  as int,
        averageDeeds: null == averageDeeds
            ? _value.averageDeeds
            : averageDeeds // ignore: cast_nullable_to_non_nullable
                  as double,
        complianceRate: null == complianceRate
            ? _value.complianceRate
            : complianceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        faraidCompliance: null == faraidCompliance
            ? _value.faraidCompliance
            : faraidCompliance // ignore: cast_nullable_to_non_nullable
                  as double,
        sunnahCompliance: null == sunnahCompliance
            ? _value.sunnahCompliance
            : sunnahCompliance // ignore: cast_nullable_to_non_nullable
                  as double,
        currentBalance: null == currentBalance
            ? _value.currentBalance
            : currentBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        dailyReports: null == dailyReports
            ? _value._dailyReports
            : dailyReports // ignore: cast_nullable_to_non_nullable
                  as List<DailyReportDetailModel>,
        achievementTags: null == achievementTags
            ? _value._achievementTags
            : achievementTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DetailedUserReportModelImpl extends _DetailedUserReportModel {
  const _$DetailedUserReportModelImpl({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
    required this.membershipStatus,
    this.memberSince,
    required this.startDate,
    required this.endDate,
    required this.totalReportsInRange,
    required this.averageDeeds,
    required this.complianceRate,
    required this.faraidCompliance,
    required this.sunnahCompliance,
    required this.currentBalance,
    required final List<DailyReportDetailModel> dailyReports,
    required final List<String> achievementTags,
  }) : _dailyReports = dailyReports,
       _achievementTags = achievementTags,
       super._();

  factory _$DetailedUserReportModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetailedUserReportModelImplFromJson(json);

  // User Information
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
  // Date Range
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  // Summary Statistics
  @override
  final int totalReportsInRange;
  @override
  final double averageDeeds;
  @override
  final double complianceRate;
  @override
  final double faraidCompliance;
  @override
  final double sunnahCompliance;
  @override
  final double currentBalance;
  // Daily Reports
  final List<DailyReportDetailModel> _dailyReports;
  // Daily Reports
  @override
  List<DailyReportDetailModel> get dailyReports {
    if (_dailyReports is EqualUnmodifiableListView) return _dailyReports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyReports);
  }

  // Achievement Tags
  final List<String> _achievementTags;
  // Achievement Tags
  @override
  List<String> get achievementTags {
    if (_achievementTags is EqualUnmodifiableListView) return _achievementTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievementTags);
  }

  @override
  String toString() {
    return 'DetailedUserReportModel(userId: $userId, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, profilePhotoUrl: $profilePhotoUrl, membershipStatus: $membershipStatus, memberSince: $memberSince, startDate: $startDate, endDate: $endDate, totalReportsInRange: $totalReportsInRange, averageDeeds: $averageDeeds, complianceRate: $complianceRate, faraidCompliance: $faraidCompliance, sunnahCompliance: $sunnahCompliance, currentBalance: $currentBalance, dailyReports: $dailyReports, achievementTags: $achievementTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetailedUserReportModelImpl &&
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
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.totalReportsInRange, totalReportsInRange) ||
                other.totalReportsInRange == totalReportsInRange) &&
            (identical(other.averageDeeds, averageDeeds) ||
                other.averageDeeds == averageDeeds) &&
            (identical(other.complianceRate, complianceRate) ||
                other.complianceRate == complianceRate) &&
            (identical(other.faraidCompliance, faraidCompliance) ||
                other.faraidCompliance == faraidCompliance) &&
            (identical(other.sunnahCompliance, sunnahCompliance) ||
                other.sunnahCompliance == sunnahCompliance) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            const DeepCollectionEquality().equals(
              other._dailyReports,
              _dailyReports,
            ) &&
            const DeepCollectionEquality().equals(
              other._achievementTags,
              _achievementTags,
            ));
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
    startDate,
    endDate,
    totalReportsInRange,
    averageDeeds,
    complianceRate,
    faraidCompliance,
    sunnahCompliance,
    currentBalance,
    const DeepCollectionEquality().hash(_dailyReports),
    const DeepCollectionEquality().hash(_achievementTags),
  );

  /// Create a copy of DetailedUserReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetailedUserReportModelImplCopyWith<_$DetailedUserReportModelImpl>
  get copyWith =>
      __$$DetailedUserReportModelImplCopyWithImpl<
        _$DetailedUserReportModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetailedUserReportModelImplToJson(this);
  }
}

abstract class _DetailedUserReportModel extends DetailedUserReportModel {
  const factory _DetailedUserReportModel({
    required final String userId,
    required final String fullName,
    required final String email,
    final String? phoneNumber,
    final String? profilePhotoUrl,
    required final String membershipStatus,
    final DateTime? memberSince,
    required final DateTime startDate,
    required final DateTime endDate,
    required final int totalReportsInRange,
    required final double averageDeeds,
    required final double complianceRate,
    required final double faraidCompliance,
    required final double sunnahCompliance,
    required final double currentBalance,
    required final List<DailyReportDetailModel> dailyReports,
    required final List<String> achievementTags,
  }) = _$DetailedUserReportModelImpl;
  const _DetailedUserReportModel._() : super._();

  factory _DetailedUserReportModel.fromJson(Map<String, dynamic> json) =
      _$DetailedUserReportModelImpl.fromJson;

  // User Information
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
  DateTime? get memberSince; // Date Range
  @override
  DateTime get startDate;
  @override
  DateTime get endDate; // Summary Statistics
  @override
  int get totalReportsInRange;
  @override
  double get averageDeeds;
  @override
  double get complianceRate;
  @override
  double get faraidCompliance;
  @override
  double get sunnahCompliance;
  @override
  double get currentBalance; // Daily Reports
  @override
  List<DailyReportDetailModel> get dailyReports; // Achievement Tags
  @override
  List<String> get achievementTags;

  /// Create a copy of DetailedUserReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetailedUserReportModelImplCopyWith<_$DetailedUserReportModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
