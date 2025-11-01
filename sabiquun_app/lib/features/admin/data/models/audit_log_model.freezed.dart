// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuditLogModel {
  String get id => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String get performedBy => throw _privateConstructorUsedError;
  String get performedByName => throw _privateConstructorUsedError;
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get oldValue => throw _privateConstructorUsedError;
  Map<String, dynamic>? get newValue => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogModelCopyWith<AuditLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogModelCopyWith<$Res> {
  factory $AuditLogModelCopyWith(
    AuditLogModel value,
    $Res Function(AuditLogModel) then,
  ) = _$AuditLogModelCopyWithImpl<$Res, AuditLogModel>;
  @useResult
  $Res call({
    String id,
    String action,
    String performedBy,
    String performedByName,
    String entityType,
    String entityId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? reason,
    DateTime timestamp,
  });
}

/// @nodoc
class _$AuditLogModelCopyWithImpl<$Res, $Val extends AuditLogModel>
    implements $AuditLogModelCopyWith<$Res> {
  _$AuditLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? performedBy = null,
    Object? performedByName = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? reason = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            performedBy: null == performedBy
                ? _value.performedBy
                : performedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            performedByName: null == performedByName
                ? _value.performedByName
                : performedByName // ignore: cast_nullable_to_non_nullable
                      as String,
            entityType: null == entityType
                ? _value.entityType
                : entityType // ignore: cast_nullable_to_non_nullable
                      as String,
            entityId: null == entityId
                ? _value.entityId
                : entityId // ignore: cast_nullable_to_non_nullable
                      as String,
            oldValue: freezed == oldValue
                ? _value.oldValue
                : oldValue // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            newValue: freezed == newValue
                ? _value.newValue
                : newValue // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuditLogModelImplCopyWith<$Res>
    implements $AuditLogModelCopyWith<$Res> {
  factory _$$AuditLogModelImplCopyWith(
    _$AuditLogModelImpl value,
    $Res Function(_$AuditLogModelImpl) then,
  ) = __$$AuditLogModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String action,
    String performedBy,
    String performedByName,
    String entityType,
    String entityId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? reason,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$AuditLogModelImplCopyWithImpl<$Res>
    extends _$AuditLogModelCopyWithImpl<$Res, _$AuditLogModelImpl>
    implements _$$AuditLogModelImplCopyWith<$Res> {
  __$$AuditLogModelImplCopyWithImpl(
    _$AuditLogModelImpl _value,
    $Res Function(_$AuditLogModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? performedBy = null,
    Object? performedByName = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? reason = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$AuditLogModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        performedBy: null == performedBy
            ? _value.performedBy
            : performedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        performedByName: null == performedByName
            ? _value.performedByName
            : performedByName // ignore: cast_nullable_to_non_nullable
                  as String,
        entityType: null == entityType
            ? _value.entityType
            : entityType // ignore: cast_nullable_to_non_nullable
                  as String,
        entityId: null == entityId
            ? _value.entityId
            : entityId // ignore: cast_nullable_to_non_nullable
                  as String,
        oldValue: freezed == oldValue
            ? _value._oldValue
            : oldValue // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        newValue: freezed == newValue
            ? _value._newValue
            : newValue // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AuditLogModelImpl extends _AuditLogModel {
  const _$AuditLogModelImpl({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.performedByName,
    required this.entityType,
    required this.entityId,
    final Map<String, dynamic>? oldValue,
    final Map<String, dynamic>? newValue,
    this.reason,
    required this.timestamp,
  }) : _oldValue = oldValue,
       _newValue = newValue,
       super._();

  @override
  final String id;
  @override
  final String action;
  @override
  final String performedBy;
  @override
  final String performedByName;
  @override
  final String entityType;
  @override
  final String entityId;
  final Map<String, dynamic>? _oldValue;
  @override
  Map<String, dynamic>? get oldValue {
    final value = _oldValue;
    if (value == null) return null;
    if (_oldValue is EqualUnmodifiableMapView) return _oldValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newValue;
  @override
  Map<String, dynamic>? get newValue {
    final value = _newValue;
    if (value == null) return null;
    if (_newValue is EqualUnmodifiableMapView) return _newValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? reason;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'AuditLogModel(id: $id, action: $action, performedBy: $performedBy, performedByName: $performedByName, entityType: $entityType, entityId: $entityId, oldValue: $oldValue, newValue: $newValue, reason: $reason, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.performedByName, performedByName) ||
                other.performedByName == performedByName) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            const DeepCollectionEquality().equals(other._oldValue, _oldValue) &&
            const DeepCollectionEquality().equals(other._newValue, _newValue) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    action,
    performedBy,
    performedByName,
    entityType,
    entityId,
    const DeepCollectionEquality().hash(_oldValue),
    const DeepCollectionEquality().hash(_newValue),
    reason,
    timestamp,
  );

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogModelImplCopyWith<_$AuditLogModelImpl> get copyWith =>
      __$$AuditLogModelImplCopyWithImpl<_$AuditLogModelImpl>(this, _$identity);
}

abstract class _AuditLogModel extends AuditLogModel {
  const factory _AuditLogModel({
    required final String id,
    required final String action,
    required final String performedBy,
    required final String performedByName,
    required final String entityType,
    required final String entityId,
    final Map<String, dynamic>? oldValue,
    final Map<String, dynamic>? newValue,
    final String? reason,
    required final DateTime timestamp,
  }) = _$AuditLogModelImpl;
  const _AuditLogModel._() : super._();

  @override
  String get id;
  @override
  String get action;
  @override
  String get performedBy;
  @override
  String get performedByName;
  @override
  String get entityType;
  @override
  String get entityId;
  @override
  Map<String, dynamic>? get oldValue;
  @override
  Map<String, dynamic>? get newValue;
  @override
  String? get reason;
  @override
  DateTime get timestamp;

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogModelImplCopyWith<_$AuditLogModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
