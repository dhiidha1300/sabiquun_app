// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'penalty_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PenaltyModel _$PenaltyModelFromJson(Map<String, dynamic> json) {
  return _PenaltyModel.fromJson(json);
}

/// @nodoc
mixin _$PenaltyModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_id')
  String? get reportId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_incurred')
  DateTime get dateIncurred => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_amount')
  double get paidAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'waived_by')
  String? get waivedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'waived_reason')
  String? get waivedReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'missed_deeds')
  double? get missedDeeds => throw _privateConstructorUsedError;

  /// Serializes this PenaltyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PenaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PenaltyModelCopyWith<PenaltyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PenaltyModelCopyWith<$Res> {
  factory $PenaltyModelCopyWith(
    PenaltyModel value,
    $Res Function(PenaltyModel) then,
  ) = _$PenaltyModelCopyWithImpl<$Res, PenaltyModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'report_id') String? reportId,
    double amount,
    @JsonKey(name: 'date_incurred') DateTime dateIncurred,
    String status,
    @JsonKey(name: 'paid_amount') double paidAmount,
    @JsonKey(name: 'waived_by') String? waivedBy,
    @JsonKey(name: 'waived_reason') String? waivedReason,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'missed_deeds') double? missedDeeds,
  });
}

/// @nodoc
class _$PenaltyModelCopyWithImpl<$Res, $Val extends PenaltyModel>
    implements $PenaltyModelCopyWith<$Res> {
  _$PenaltyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PenaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? reportId = freezed,
    Object? amount = null,
    Object? dateIncurred = null,
    Object? status = null,
    Object? paidAmount = null,
    Object? waivedBy = freezed,
    Object? waivedReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? missedDeeds = freezed,
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
            reportId: freezed == reportId
                ? _value.reportId
                : reportId // ignore: cast_nullable_to_non_nullable
                      as String?,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            dateIncurred: null == dateIncurred
                ? _value.dateIncurred
                : dateIncurred // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            paidAmount: null == paidAmount
                ? _value.paidAmount
                : paidAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            waivedBy: freezed == waivedBy
                ? _value.waivedBy
                : waivedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            waivedReason: freezed == waivedReason
                ? _value.waivedReason
                : waivedReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            missedDeeds: freezed == missedDeeds
                ? _value.missedDeeds
                : missedDeeds // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PenaltyModelImplCopyWith<$Res>
    implements $PenaltyModelCopyWith<$Res> {
  factory _$$PenaltyModelImplCopyWith(
    _$PenaltyModelImpl value,
    $Res Function(_$PenaltyModelImpl) then,
  ) = __$$PenaltyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'report_id') String? reportId,
    double amount,
    @JsonKey(name: 'date_incurred') DateTime dateIncurred,
    String status,
    @JsonKey(name: 'paid_amount') double paidAmount,
    @JsonKey(name: 'waived_by') String? waivedBy,
    @JsonKey(name: 'waived_reason') String? waivedReason,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'missed_deeds') double? missedDeeds,
  });
}

/// @nodoc
class __$$PenaltyModelImplCopyWithImpl<$Res>
    extends _$PenaltyModelCopyWithImpl<$Res, _$PenaltyModelImpl>
    implements _$$PenaltyModelImplCopyWith<$Res> {
  __$$PenaltyModelImplCopyWithImpl(
    _$PenaltyModelImpl _value,
    $Res Function(_$PenaltyModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PenaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? reportId = freezed,
    Object? amount = null,
    Object? dateIncurred = null,
    Object? status = null,
    Object? paidAmount = null,
    Object? waivedBy = freezed,
    Object? waivedReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? missedDeeds = freezed,
  }) {
    return _then(
      _$PenaltyModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        reportId: freezed == reportId
            ? _value.reportId
            : reportId // ignore: cast_nullable_to_non_nullable
                  as String?,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        dateIncurred: null == dateIncurred
            ? _value.dateIncurred
            : dateIncurred // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        paidAmount: null == paidAmount
            ? _value.paidAmount
            : paidAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        waivedBy: freezed == waivedBy
            ? _value.waivedBy
            : waivedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        waivedReason: freezed == waivedReason
            ? _value.waivedReason
            : waivedReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        missedDeeds: freezed == missedDeeds
            ? _value.missedDeeds
            : missedDeeds // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PenaltyModelImpl extends _PenaltyModel {
  const _$PenaltyModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'report_id') this.reportId,
    required this.amount,
    @JsonKey(name: 'date_incurred') required this.dateIncurred,
    required this.status,
    @JsonKey(name: 'paid_amount') required this.paidAmount,
    @JsonKey(name: 'waived_by') this.waivedBy,
    @JsonKey(name: 'waived_reason') this.waivedReason,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'missed_deeds') this.missedDeeds,
  }) : super._();

  factory _$PenaltyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PenaltyModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'report_id')
  final String? reportId;
  @override
  final double amount;
  @override
  @JsonKey(name: 'date_incurred')
  final DateTime dateIncurred;
  @override
  final String status;
  @override
  @JsonKey(name: 'paid_amount')
  final double paidAmount;
  @override
  @JsonKey(name: 'waived_by')
  final String? waivedBy;
  @override
  @JsonKey(name: 'waived_reason')
  final String? waivedReason;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'missed_deeds')
  final double? missedDeeds;

  @override
  String toString() {
    return 'PenaltyModel(id: $id, userId: $userId, reportId: $reportId, amount: $amount, dateIncurred: $dateIncurred, status: $status, paidAmount: $paidAmount, waivedBy: $waivedBy, waivedReason: $waivedReason, createdAt: $createdAt, updatedAt: $updatedAt, missedDeeds: $missedDeeds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PenaltyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dateIncurred, dateIncurred) ||
                other.dateIncurred == dateIncurred) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.waivedBy, waivedBy) ||
                other.waivedBy == waivedBy) &&
            (identical(other.waivedReason, waivedReason) ||
                other.waivedReason == waivedReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.missedDeeds, missedDeeds) ||
                other.missedDeeds == missedDeeds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    reportId,
    amount,
    dateIncurred,
    status,
    paidAmount,
    waivedBy,
    waivedReason,
    createdAt,
    updatedAt,
    missedDeeds,
  );

  /// Create a copy of PenaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PenaltyModelImplCopyWith<_$PenaltyModelImpl> get copyWith =>
      __$$PenaltyModelImplCopyWithImpl<_$PenaltyModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PenaltyModelImplToJson(this);
  }
}

abstract class _PenaltyModel extends PenaltyModel {
  const factory _PenaltyModel({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'report_id') final String? reportId,
    required final double amount,
    @JsonKey(name: 'date_incurred') required final DateTime dateIncurred,
    required final String status,
    @JsonKey(name: 'paid_amount') required final double paidAmount,
    @JsonKey(name: 'waived_by') final String? waivedBy,
    @JsonKey(name: 'waived_reason') final String? waivedReason,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'missed_deeds') final double? missedDeeds,
  }) = _$PenaltyModelImpl;
  const _PenaltyModel._() : super._();

  factory _PenaltyModel.fromJson(Map<String, dynamic> json) =
      _$PenaltyModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'report_id')
  String? get reportId;
  @override
  double get amount;
  @override
  @JsonKey(name: 'date_incurred')
  DateTime get dateIncurred;
  @override
  String get status;
  @override
  @JsonKey(name: 'paid_amount')
  double get paidAmount;
  @override
  @JsonKey(name: 'waived_by')
  String? get waivedBy;
  @override
  @JsonKey(name: 'waived_reason')
  String? get waivedReason;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'missed_deeds')
  double? get missedDeeds;

  /// Create a copy of PenaltyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PenaltyModelImplCopyWith<_$PenaltyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
