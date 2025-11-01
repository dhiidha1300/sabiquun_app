// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'excuse_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExcuseModel _$ExcuseModelFromJson(Map<String, dynamic> json) {
  return _ExcuseModel.fromJson(json);
}

/// @nodoc
mixin _$ExcuseModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String? get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_date')
  DateTime get reportDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'excuse_type')
  String get excuseType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'affected_deeds')
  Map<String, dynamic> get affectedDeeds => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'submitted_at')
  DateTime get submittedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'reviewed_by')
  String? get reviewedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'reviewer_name')
  String? get reviewerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'reviewed_at')
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason => throw _privateConstructorUsedError;

  /// Serializes this ExcuseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExcuseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExcuseModelCopyWith<ExcuseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExcuseModelCopyWith<$Res> {
  factory $ExcuseModelCopyWith(
    ExcuseModel value,
    $Res Function(ExcuseModel) then,
  ) = _$ExcuseModelCopyWithImpl<$Res, ExcuseModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'report_date') DateTime reportDate,
    @JsonKey(name: 'excuse_type') String excuseType,
    String? description,
    @JsonKey(name: 'affected_deeds') Map<String, dynamic> affectedDeeds,
    String status,
    @JsonKey(name: 'submitted_at') DateTime submittedAt,
    @JsonKey(name: 'reviewed_by') String? reviewedBy,
    @JsonKey(name: 'reviewer_name') String? reviewerName,
    @JsonKey(name: 'reviewed_at') DateTime? reviewedAt,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
  });
}

/// @nodoc
class _$ExcuseModelCopyWithImpl<$Res, $Val extends ExcuseModel>
    implements $ExcuseModelCopyWith<$Res> {
  _$ExcuseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExcuseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? reportDate = null,
    Object? excuseType = null,
    Object? description = freezed,
    Object? affectedDeeds = null,
    Object? status = null,
    Object? submittedAt = null,
    Object? reviewedBy = freezed,
    Object? reviewerName = freezed,
    Object? reviewedAt = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            reportDate: null == reportDate
                ? _value.reportDate
                : reportDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            excuseType: null == excuseType
                ? _value.excuseType
                : excuseType // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            affectedDeeds: null == affectedDeeds
                ? _value.affectedDeeds
                : affectedDeeds // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            submittedAt: null == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reviewedBy: freezed == reviewedBy
                ? _value.reviewedBy
                : reviewedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewerName: freezed == reviewerName
                ? _value.reviewerName
                : reviewerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewedAt: freezed == reviewedAt
                ? _value.reviewedAt
                : reviewedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            rejectionReason: freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExcuseModelImplCopyWith<$Res>
    implements $ExcuseModelCopyWith<$Res> {
  factory _$$ExcuseModelImplCopyWith(
    _$ExcuseModelImpl value,
    $Res Function(_$ExcuseModelImpl) then,
  ) = __$$ExcuseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'report_date') DateTime reportDate,
    @JsonKey(name: 'excuse_type') String excuseType,
    String? description,
    @JsonKey(name: 'affected_deeds') Map<String, dynamic> affectedDeeds,
    String status,
    @JsonKey(name: 'submitted_at') DateTime submittedAt,
    @JsonKey(name: 'reviewed_by') String? reviewedBy,
    @JsonKey(name: 'reviewer_name') String? reviewerName,
    @JsonKey(name: 'reviewed_at') DateTime? reviewedAt,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
  });
}

/// @nodoc
class __$$ExcuseModelImplCopyWithImpl<$Res>
    extends _$ExcuseModelCopyWithImpl<$Res, _$ExcuseModelImpl>
    implements _$$ExcuseModelImplCopyWith<$Res> {
  __$$ExcuseModelImplCopyWithImpl(
    _$ExcuseModelImpl _value,
    $Res Function(_$ExcuseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExcuseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? reportDate = null,
    Object? excuseType = null,
    Object? description = freezed,
    Object? affectedDeeds = null,
    Object? status = null,
    Object? submittedAt = null,
    Object? reviewedBy = freezed,
    Object? reviewerName = freezed,
    Object? reviewedAt = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(
      _$ExcuseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        reportDate: null == reportDate
            ? _value.reportDate
            : reportDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        excuseType: null == excuseType
            ? _value.excuseType
            : excuseType // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        affectedDeeds: null == affectedDeeds
            ? _value._affectedDeeds
            : affectedDeeds // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        submittedAt: null == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reviewedBy: freezed == reviewedBy
            ? _value.reviewedBy
            : reviewedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewerName: freezed == reviewerName
            ? _value.reviewerName
            : reviewerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewedAt: freezed == reviewedAt
            ? _value.reviewedAt
            : reviewedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        rejectionReason: freezed == rejectionReason
            ? _value.rejectionReason
            : rejectionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExcuseModelImpl extends _ExcuseModel {
  const _$ExcuseModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'user_name') this.userName,
    @JsonKey(name: 'report_date') required this.reportDate,
    @JsonKey(name: 'excuse_type') required this.excuseType,
    this.description,
    @JsonKey(name: 'affected_deeds')
    required final Map<String, dynamic> affectedDeeds,
    required this.status,
    @JsonKey(name: 'submitted_at') required this.submittedAt,
    @JsonKey(name: 'reviewed_by') this.reviewedBy,
    @JsonKey(name: 'reviewer_name') this.reviewerName,
    @JsonKey(name: 'reviewed_at') this.reviewedAt,
    @JsonKey(name: 'rejection_reason') this.rejectionReason,
  }) : _affectedDeeds = affectedDeeds,
       super._();

  factory _$ExcuseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExcuseModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'user_name')
  final String? userName;
  @override
  @JsonKey(name: 'report_date')
  final DateTime reportDate;
  @override
  @JsonKey(name: 'excuse_type')
  final String excuseType;
  @override
  final String? description;
  final Map<String, dynamic> _affectedDeeds;
  @override
  @JsonKey(name: 'affected_deeds')
  Map<String, dynamic> get affectedDeeds {
    if (_affectedDeeds is EqualUnmodifiableMapView) return _affectedDeeds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_affectedDeeds);
  }

  @override
  final String status;
  @override
  @JsonKey(name: 'submitted_at')
  final DateTime submittedAt;
  @override
  @JsonKey(name: 'reviewed_by')
  final String? reviewedBy;
  @override
  @JsonKey(name: 'reviewer_name')
  final String? reviewerName;
  @override
  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;
  @override
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;

  @override
  String toString() {
    return 'ExcuseModel(id: $id, userId: $userId, userName: $userName, reportDate: $reportDate, excuseType: $excuseType, description: $description, affectedDeeds: $affectedDeeds, status: $status, submittedAt: $submittedAt, reviewedBy: $reviewedBy, reviewerName: $reviewerName, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExcuseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.reportDate, reportDate) ||
                other.reportDate == reportDate) &&
            (identical(other.excuseType, excuseType) ||
                other.excuseType == excuseType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._affectedDeeds,
              _affectedDeeds,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewerName, reviewerName) ||
                other.reviewerName == reviewerName) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    userName,
    reportDate,
    excuseType,
    description,
    const DeepCollectionEquality().hash(_affectedDeeds),
    status,
    submittedAt,
    reviewedBy,
    reviewerName,
    reviewedAt,
    rejectionReason,
  );

  /// Create a copy of ExcuseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExcuseModelImplCopyWith<_$ExcuseModelImpl> get copyWith =>
      __$$ExcuseModelImplCopyWithImpl<_$ExcuseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExcuseModelImplToJson(this);
  }
}

abstract class _ExcuseModel extends ExcuseModel {
  const factory _ExcuseModel({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'user_name') final String? userName,
    @JsonKey(name: 'report_date') required final DateTime reportDate,
    @JsonKey(name: 'excuse_type') required final String excuseType,
    final String? description,
    @JsonKey(name: 'affected_deeds')
    required final Map<String, dynamic> affectedDeeds,
    required final String status,
    @JsonKey(name: 'submitted_at') required final DateTime submittedAt,
    @JsonKey(name: 'reviewed_by') final String? reviewedBy,
    @JsonKey(name: 'reviewer_name') final String? reviewerName,
    @JsonKey(name: 'reviewed_at') final DateTime? reviewedAt,
    @JsonKey(name: 'rejection_reason') final String? rejectionReason,
  }) = _$ExcuseModelImpl;
  const _ExcuseModel._() : super._();

  factory _ExcuseModel.fromJson(Map<String, dynamic> json) =
      _$ExcuseModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'user_name')
  String? get userName;
  @override
  @JsonKey(name: 'report_date')
  DateTime get reportDate;
  @override
  @JsonKey(name: 'excuse_type')
  String get excuseType;
  @override
  String? get description;
  @override
  @JsonKey(name: 'affected_deeds')
  Map<String, dynamic> get affectedDeeds;
  @override
  String get status;
  @override
  @JsonKey(name: 'submitted_at')
  DateTime get submittedAt;
  @override
  @JsonKey(name: 'reviewed_by')
  String? get reviewedBy;
  @override
  @JsonKey(name: 'reviewer_name')
  String? get reviewerName;
  @override
  @JsonKey(name: 'reviewed_at')
  DateTime? get reviewedAt;
  @override
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason;

  /// Create a copy of ExcuseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExcuseModelImplCopyWith<_$ExcuseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
