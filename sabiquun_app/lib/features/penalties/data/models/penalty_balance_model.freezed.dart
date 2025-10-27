// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'penalty_balance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PenaltyBalanceModel _$PenaltyBalanceModelFromJson(Map<String, dynamic> json) {
  return _PenaltyBalanceModel.fromJson(json);
}

/// @nodoc
mixin _$PenaltyBalanceModel {
  double get balance => throw _privateConstructorUsedError;
  @JsonKey(name: 'unpaid_penalties_count')
  int get unpaidPenaltiesCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'oldest_penalty_date')
  DateTime? get oldestPenaltyDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'approaching_deactivation')
  bool get approachingDeactivation => throw _privateConstructorUsedError;
  @JsonKey(name: 'deactivation_threshold')
  double get deactivationThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_warning_threshold')
  double? get firstWarningThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_warning_threshold')
  double? get finalWarningThreshold => throw _privateConstructorUsedError;

  /// Serializes this PenaltyBalanceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PenaltyBalanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PenaltyBalanceModelCopyWith<PenaltyBalanceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PenaltyBalanceModelCopyWith<$Res> {
  factory $PenaltyBalanceModelCopyWith(
    PenaltyBalanceModel value,
    $Res Function(PenaltyBalanceModel) then,
  ) = _$PenaltyBalanceModelCopyWithImpl<$Res, PenaltyBalanceModel>;
  @useResult
  $Res call({
    double balance,
    @JsonKey(name: 'unpaid_penalties_count') int unpaidPenaltiesCount,
    @JsonKey(name: 'oldest_penalty_date') DateTime? oldestPenaltyDate,
    @JsonKey(name: 'approaching_deactivation') bool approachingDeactivation,
    @JsonKey(name: 'deactivation_threshold') double deactivationThreshold,
    @JsonKey(name: 'first_warning_threshold') double? firstWarningThreshold,
    @JsonKey(name: 'final_warning_threshold') double? finalWarningThreshold,
  });
}

/// @nodoc
class _$PenaltyBalanceModelCopyWithImpl<$Res, $Val extends PenaltyBalanceModel>
    implements $PenaltyBalanceModelCopyWith<$Res> {
  _$PenaltyBalanceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PenaltyBalanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? unpaidPenaltiesCount = null,
    Object? oldestPenaltyDate = freezed,
    Object? approachingDeactivation = null,
    Object? deactivationThreshold = null,
    Object? firstWarningThreshold = freezed,
    Object? finalWarningThreshold = freezed,
  }) {
    return _then(
      _value.copyWith(
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as double,
            unpaidPenaltiesCount: null == unpaidPenaltiesCount
                ? _value.unpaidPenaltiesCount
                : unpaidPenaltiesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            oldestPenaltyDate: freezed == oldestPenaltyDate
                ? _value.oldestPenaltyDate
                : oldestPenaltyDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            approachingDeactivation: null == approachingDeactivation
                ? _value.approachingDeactivation
                : approachingDeactivation // ignore: cast_nullable_to_non_nullable
                      as bool,
            deactivationThreshold: null == deactivationThreshold
                ? _value.deactivationThreshold
                : deactivationThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            firstWarningThreshold: freezed == firstWarningThreshold
                ? _value.firstWarningThreshold
                : firstWarningThreshold // ignore: cast_nullable_to_non_nullable
                      as double?,
            finalWarningThreshold: freezed == finalWarningThreshold
                ? _value.finalWarningThreshold
                : finalWarningThreshold // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PenaltyBalanceModelImplCopyWith<$Res>
    implements $PenaltyBalanceModelCopyWith<$Res> {
  factory _$$PenaltyBalanceModelImplCopyWith(
    _$PenaltyBalanceModelImpl value,
    $Res Function(_$PenaltyBalanceModelImpl) then,
  ) = __$$PenaltyBalanceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double balance,
    @JsonKey(name: 'unpaid_penalties_count') int unpaidPenaltiesCount,
    @JsonKey(name: 'oldest_penalty_date') DateTime? oldestPenaltyDate,
    @JsonKey(name: 'approaching_deactivation') bool approachingDeactivation,
    @JsonKey(name: 'deactivation_threshold') double deactivationThreshold,
    @JsonKey(name: 'first_warning_threshold') double? firstWarningThreshold,
    @JsonKey(name: 'final_warning_threshold') double? finalWarningThreshold,
  });
}

/// @nodoc
class __$$PenaltyBalanceModelImplCopyWithImpl<$Res>
    extends _$PenaltyBalanceModelCopyWithImpl<$Res, _$PenaltyBalanceModelImpl>
    implements _$$PenaltyBalanceModelImplCopyWith<$Res> {
  __$$PenaltyBalanceModelImplCopyWithImpl(
    _$PenaltyBalanceModelImpl _value,
    $Res Function(_$PenaltyBalanceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PenaltyBalanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? unpaidPenaltiesCount = null,
    Object? oldestPenaltyDate = freezed,
    Object? approachingDeactivation = null,
    Object? deactivationThreshold = null,
    Object? firstWarningThreshold = freezed,
    Object? finalWarningThreshold = freezed,
  }) {
    return _then(
      _$PenaltyBalanceModelImpl(
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as double,
        unpaidPenaltiesCount: null == unpaidPenaltiesCount
            ? _value.unpaidPenaltiesCount
            : unpaidPenaltiesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        oldestPenaltyDate: freezed == oldestPenaltyDate
            ? _value.oldestPenaltyDate
            : oldestPenaltyDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        approachingDeactivation: null == approachingDeactivation
            ? _value.approachingDeactivation
            : approachingDeactivation // ignore: cast_nullable_to_non_nullable
                  as bool,
        deactivationThreshold: null == deactivationThreshold
            ? _value.deactivationThreshold
            : deactivationThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        firstWarningThreshold: freezed == firstWarningThreshold
            ? _value.firstWarningThreshold
            : firstWarningThreshold // ignore: cast_nullable_to_non_nullable
                  as double?,
        finalWarningThreshold: freezed == finalWarningThreshold
            ? _value.finalWarningThreshold
            : finalWarningThreshold // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PenaltyBalanceModelImpl extends _PenaltyBalanceModel {
  const _$PenaltyBalanceModelImpl({
    required this.balance,
    @JsonKey(name: 'unpaid_penalties_count') required this.unpaidPenaltiesCount,
    @JsonKey(name: 'oldest_penalty_date') this.oldestPenaltyDate,
    @JsonKey(name: 'approaching_deactivation')
    required this.approachingDeactivation,
    @JsonKey(name: 'deactivation_threshold')
    required this.deactivationThreshold,
    @JsonKey(name: 'first_warning_threshold') this.firstWarningThreshold,
    @JsonKey(name: 'final_warning_threshold') this.finalWarningThreshold,
  }) : super._();

  factory _$PenaltyBalanceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PenaltyBalanceModelImplFromJson(json);

  @override
  final double balance;
  @override
  @JsonKey(name: 'unpaid_penalties_count')
  final int unpaidPenaltiesCount;
  @override
  @JsonKey(name: 'oldest_penalty_date')
  final DateTime? oldestPenaltyDate;
  @override
  @JsonKey(name: 'approaching_deactivation')
  final bool approachingDeactivation;
  @override
  @JsonKey(name: 'deactivation_threshold')
  final double deactivationThreshold;
  @override
  @JsonKey(name: 'first_warning_threshold')
  final double? firstWarningThreshold;
  @override
  @JsonKey(name: 'final_warning_threshold')
  final double? finalWarningThreshold;

  @override
  String toString() {
    return 'PenaltyBalanceModel(balance: $balance, unpaidPenaltiesCount: $unpaidPenaltiesCount, oldestPenaltyDate: $oldestPenaltyDate, approachingDeactivation: $approachingDeactivation, deactivationThreshold: $deactivationThreshold, firstWarningThreshold: $firstWarningThreshold, finalWarningThreshold: $finalWarningThreshold)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PenaltyBalanceModelImpl &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.unpaidPenaltiesCount, unpaidPenaltiesCount) ||
                other.unpaidPenaltiesCount == unpaidPenaltiesCount) &&
            (identical(other.oldestPenaltyDate, oldestPenaltyDate) ||
                other.oldestPenaltyDate == oldestPenaltyDate) &&
            (identical(
                  other.approachingDeactivation,
                  approachingDeactivation,
                ) ||
                other.approachingDeactivation == approachingDeactivation) &&
            (identical(other.deactivationThreshold, deactivationThreshold) ||
                other.deactivationThreshold == deactivationThreshold) &&
            (identical(other.firstWarningThreshold, firstWarningThreshold) ||
                other.firstWarningThreshold == firstWarningThreshold) &&
            (identical(other.finalWarningThreshold, finalWarningThreshold) ||
                other.finalWarningThreshold == finalWarningThreshold));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    balance,
    unpaidPenaltiesCount,
    oldestPenaltyDate,
    approachingDeactivation,
    deactivationThreshold,
    firstWarningThreshold,
    finalWarningThreshold,
  );

  /// Create a copy of PenaltyBalanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PenaltyBalanceModelImplCopyWith<_$PenaltyBalanceModelImpl> get copyWith =>
      __$$PenaltyBalanceModelImplCopyWithImpl<_$PenaltyBalanceModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PenaltyBalanceModelImplToJson(this);
  }
}

abstract class _PenaltyBalanceModel extends PenaltyBalanceModel {
  const factory _PenaltyBalanceModel({
    required final double balance,
    @JsonKey(name: 'unpaid_penalties_count')
    required final int unpaidPenaltiesCount,
    @JsonKey(name: 'oldest_penalty_date') final DateTime? oldestPenaltyDate,
    @JsonKey(name: 'approaching_deactivation')
    required final bool approachingDeactivation,
    @JsonKey(name: 'deactivation_threshold')
    required final double deactivationThreshold,
    @JsonKey(name: 'first_warning_threshold')
    final double? firstWarningThreshold,
    @JsonKey(name: 'final_warning_threshold')
    final double? finalWarningThreshold,
  }) = _$PenaltyBalanceModelImpl;
  const _PenaltyBalanceModel._() : super._();

  factory _PenaltyBalanceModel.fromJson(Map<String, dynamic> json) =
      _$PenaltyBalanceModelImpl.fromJson;

  @override
  double get balance;
  @override
  @JsonKey(name: 'unpaid_penalties_count')
  int get unpaidPenaltiesCount;
  @override
  @JsonKey(name: 'oldest_penalty_date')
  DateTime? get oldestPenaltyDate;
  @override
  @JsonKey(name: 'approaching_deactivation')
  bool get approachingDeactivation;
  @override
  @JsonKey(name: 'deactivation_threshold')
  double get deactivationThreshold;
  @override
  @JsonKey(name: 'first_warning_threshold')
  double? get firstWarningThreshold;
  @override
  @JsonKey(name: 'final_warning_threshold')
  double? get finalWarningThreshold;

  /// Create a copy of PenaltyBalanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PenaltyBalanceModelImplCopyWith<_$PenaltyBalanceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
