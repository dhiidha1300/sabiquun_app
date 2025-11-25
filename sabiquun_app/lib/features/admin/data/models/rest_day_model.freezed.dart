// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rest_day_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RestDayModel {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_recurring')
  bool get isRecurring => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of RestDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestDayModelCopyWith<RestDayModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestDayModelCopyWith<$Res> {
  factory $RestDayModelCopyWith(
    RestDayModel value,
    $Res Function(RestDayModel) then,
  ) = _$RestDayModelCopyWithImpl<$Res, RestDayModel>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    DateTime? endDate,
    String description,
    @JsonKey(name: 'is_recurring') bool isRecurring,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$RestDayModelCopyWithImpl<$Res, $Val extends RestDayModel>
    implements $RestDayModelCopyWith<$Res> {
  _$RestDayModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? endDate = freezed,
    Object? description = null,
    Object? isRecurring = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$RestDayModelImplCopyWith<$Res>
    implements $RestDayModelCopyWith<$Res> {
  factory _$$RestDayModelImplCopyWith(
    _$RestDayModelImpl value,
    $Res Function(_$RestDayModelImpl) then,
  ) = __$$RestDayModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    DateTime? endDate,
    String description,
    @JsonKey(name: 'is_recurring') bool isRecurring,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$RestDayModelImplCopyWithImpl<$Res>
    extends _$RestDayModelCopyWithImpl<$Res, _$RestDayModelImpl>
    implements _$$RestDayModelImplCopyWith<$Res> {
  __$$RestDayModelImplCopyWithImpl(
    _$RestDayModelImpl _value,
    $Res Function(_$RestDayModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RestDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? endDate = freezed,
    Object? description = null,
    Object? isRecurring = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RestDayModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$RestDayModelImpl implements _RestDayModel {
  const _$RestDayModelImpl({
    required this.id,
    required this.date,
    this.endDate,
    required this.description,
    @JsonKey(name: 'is_recurring') required this.isRecurring,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final DateTime? endDate;
  @override
  final String description;
  @override
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'RestDayModel(id: $id, date: $date, endDate: $endDate, description: $description, isRecurring: $isRecurring, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestDayModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    endDate,
    description,
    isRecurring,
    createdAt,
  );

  /// Create a copy of RestDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestDayModelImplCopyWith<_$RestDayModelImpl> get copyWith =>
      __$$RestDayModelImplCopyWithImpl<_$RestDayModelImpl>(this, _$identity);
}

abstract class _RestDayModel implements RestDayModel {
  const factory _RestDayModel({
    required final String id,
    required final DateTime date,
    final DateTime? endDate,
    required final String description,
    @JsonKey(name: 'is_recurring') required final bool isRecurring,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$RestDayModelImpl;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  DateTime? get endDate;
  @override
  String get description;
  @override
  @JsonKey(name: 'is_recurring')
  bool get isRecurring;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of RestDayModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestDayModelImplCopyWith<_$RestDayModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
