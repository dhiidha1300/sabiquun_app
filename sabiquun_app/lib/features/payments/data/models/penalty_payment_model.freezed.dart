// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'penalty_payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PenaltyPaymentModel _$PenaltyPaymentModelFromJson(Map<String, dynamic> json) {
  return _PenaltyPaymentModel.fromJson(json);
}

/// @nodoc
mixin _$PenaltyPaymentModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_id')
  String get paymentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'penalty_id')
  String get penaltyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_applied')
  double get amountApplied => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PenaltyPaymentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PenaltyPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PenaltyPaymentModelCopyWith<PenaltyPaymentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PenaltyPaymentModelCopyWith<$Res> {
  factory $PenaltyPaymentModelCopyWith(
    PenaltyPaymentModel value,
    $Res Function(PenaltyPaymentModel) then,
  ) = _$PenaltyPaymentModelCopyWithImpl<$Res, PenaltyPaymentModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'payment_id') String paymentId,
    @JsonKey(name: 'penalty_id') String penaltyId,
    @JsonKey(name: 'amount_applied') double amountApplied,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$PenaltyPaymentModelCopyWithImpl<$Res, $Val extends PenaltyPaymentModel>
    implements $PenaltyPaymentModelCopyWith<$Res> {
  _$PenaltyPaymentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PenaltyPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? paymentId = null,
    Object? penaltyId = null,
    Object? amountApplied = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentId: null == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                      as String,
            penaltyId: null == penaltyId
                ? _value.penaltyId
                : penaltyId // ignore: cast_nullable_to_non_nullable
                      as String,
            amountApplied: null == amountApplied
                ? _value.amountApplied
                : amountApplied // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PenaltyPaymentModelImplCopyWith<$Res>
    implements $PenaltyPaymentModelCopyWith<$Res> {
  factory _$$PenaltyPaymentModelImplCopyWith(
    _$PenaltyPaymentModelImpl value,
    $Res Function(_$PenaltyPaymentModelImpl) then,
  ) = __$$PenaltyPaymentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'payment_id') String paymentId,
    @JsonKey(name: 'penalty_id') String penaltyId,
    @JsonKey(name: 'amount_applied') double amountApplied,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$PenaltyPaymentModelImplCopyWithImpl<$Res>
    extends _$PenaltyPaymentModelCopyWithImpl<$Res, _$PenaltyPaymentModelImpl>
    implements _$$PenaltyPaymentModelImplCopyWith<$Res> {
  __$$PenaltyPaymentModelImplCopyWithImpl(
    _$PenaltyPaymentModelImpl _value,
    $Res Function(_$PenaltyPaymentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PenaltyPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? paymentId = null,
    Object? penaltyId = null,
    Object? amountApplied = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PenaltyPaymentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentId: null == paymentId
            ? _value.paymentId
            : paymentId // ignore: cast_nullable_to_non_nullable
                  as String,
        penaltyId: null == penaltyId
            ? _value.penaltyId
            : penaltyId // ignore: cast_nullable_to_non_nullable
                  as String,
        amountApplied: null == amountApplied
            ? _value.amountApplied
            : amountApplied // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PenaltyPaymentModelImpl extends _PenaltyPaymentModel {
  const _$PenaltyPaymentModelImpl({
    required this.id,
    @JsonKey(name: 'payment_id') required this.paymentId,
    @JsonKey(name: 'penalty_id') required this.penaltyId,
    @JsonKey(name: 'amount_applied') required this.amountApplied,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : super._();

  factory _$PenaltyPaymentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PenaltyPaymentModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'payment_id')
  final String paymentId;
  @override
  @JsonKey(name: 'penalty_id')
  final String penaltyId;
  @override
  @JsonKey(name: 'amount_applied')
  final double amountApplied;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'PenaltyPaymentModel(id: $id, paymentId: $paymentId, penaltyId: $penaltyId, amountApplied: $amountApplied, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PenaltyPaymentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.penaltyId, penaltyId) ||
                other.penaltyId == penaltyId) &&
            (identical(other.amountApplied, amountApplied) ||
                other.amountApplied == amountApplied) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    paymentId,
    penaltyId,
    amountApplied,
    createdAt,
  );

  /// Create a copy of PenaltyPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PenaltyPaymentModelImplCopyWith<_$PenaltyPaymentModelImpl> get copyWith =>
      __$$PenaltyPaymentModelImplCopyWithImpl<_$PenaltyPaymentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PenaltyPaymentModelImplToJson(this);
  }
}

abstract class _PenaltyPaymentModel extends PenaltyPaymentModel {
  const factory _PenaltyPaymentModel({
    required final String id,
    @JsonKey(name: 'payment_id') required final String paymentId,
    @JsonKey(name: 'penalty_id') required final String penaltyId,
    @JsonKey(name: 'amount_applied') required final double amountApplied,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$PenaltyPaymentModelImpl;
  const _PenaltyPaymentModel._() : super._();

  factory _PenaltyPaymentModel.fromJson(Map<String, dynamic> json) =
      _$PenaltyPaymentModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'payment_id')
  String get paymentId;
  @override
  @JsonKey(name: 'penalty_id')
  String get penaltyId;
  @override
  @JsonKey(name: 'amount_applied')
  double get amountApplied;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of PenaltyPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PenaltyPaymentModelImplCopyWith<_$PenaltyPaymentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
