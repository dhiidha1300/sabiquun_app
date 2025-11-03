// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationScheduleModel _$NotificationScheduleModelFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationScheduleModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationScheduleModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'notification_template_id')
  String get notificationTemplateId => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_time')
  String get scheduledTime => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'days_of_week')
  List<int>? get daysOfWeek => throw _privateConstructorUsedError;
  Map<String, dynamic>? get conditions => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationScheduleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationScheduleModelCopyWith<NotificationScheduleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationScheduleModelCopyWith<$Res> {
  factory $NotificationScheduleModelCopyWith(
    NotificationScheduleModel value,
    $Res Function(NotificationScheduleModel) then,
  ) = _$NotificationScheduleModelCopyWithImpl<$Res, NotificationScheduleModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'notification_template_id') String notificationTemplateId,
    @JsonKey(name: 'scheduled_time') String scheduledTime,
    String frequency,
    @JsonKey(name: 'days_of_week') List<int>? daysOfWeek,
    Map<String, dynamic>? conditions,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$NotificationScheduleModelCopyWithImpl<
  $Res,
  $Val extends NotificationScheduleModel
>
    implements $NotificationScheduleModelCopyWith<$Res> {
  _$NotificationScheduleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? notificationTemplateId = null,
    Object? scheduledTime = null,
    Object? frequency = null,
    Object? daysOfWeek = freezed,
    Object? conditions = freezed,
    Object? isActive = null,
    Object? createdBy = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationTemplateId: null == notificationTemplateId
                ? _value.notificationTemplateId
                : notificationTemplateId // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledTime: null == scheduledTime
                ? _value.scheduledTime
                : scheduledTime // ignore: cast_nullable_to_non_nullable
                      as String,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as String,
            daysOfWeek: freezed == daysOfWeek
                ? _value.daysOfWeek
                : daysOfWeek // ignore: cast_nullable_to_non_nullable
                      as List<int>?,
            conditions: freezed == conditions
                ? _value.conditions
                : conditions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationScheduleModelImplCopyWith<$Res>
    implements $NotificationScheduleModelCopyWith<$Res> {
  factory _$$NotificationScheduleModelImplCopyWith(
    _$NotificationScheduleModelImpl value,
    $Res Function(_$NotificationScheduleModelImpl) then,
  ) = __$$NotificationScheduleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'notification_template_id') String notificationTemplateId,
    @JsonKey(name: 'scheduled_time') String scheduledTime,
    String frequency,
    @JsonKey(name: 'days_of_week') List<int>? daysOfWeek,
    Map<String, dynamic>? conditions,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$NotificationScheduleModelImplCopyWithImpl<$Res>
    extends
        _$NotificationScheduleModelCopyWithImpl<
          $Res,
          _$NotificationScheduleModelImpl
        >
    implements _$$NotificationScheduleModelImplCopyWith<$Res> {
  __$$NotificationScheduleModelImplCopyWithImpl(
    _$NotificationScheduleModelImpl _value,
    $Res Function(_$NotificationScheduleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? notificationTemplateId = null,
    Object? scheduledTime = null,
    Object? frequency = null,
    Object? daysOfWeek = freezed,
    Object? conditions = freezed,
    Object? isActive = null,
    Object? createdBy = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$NotificationScheduleModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationTemplateId: null == notificationTemplateId
            ? _value.notificationTemplateId
            : notificationTemplateId // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledTime: null == scheduledTime
            ? _value.scheduledTime
            : scheduledTime // ignore: cast_nullable_to_non_nullable
                  as String,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as String,
        daysOfWeek: freezed == daysOfWeek
            ? _value._daysOfWeek
            : daysOfWeek // ignore: cast_nullable_to_non_nullable
                  as List<int>?,
        conditions: freezed == conditions
            ? _value._conditions
            : conditions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationScheduleModelImpl implements _NotificationScheduleModel {
  const _$NotificationScheduleModelImpl({
    required this.id,
    @JsonKey(name: 'notification_template_id')
    required this.notificationTemplateId,
    @JsonKey(name: 'scheduled_time') required this.scheduledTime,
    required this.frequency,
    @JsonKey(name: 'days_of_week') final List<int>? daysOfWeek,
    final Map<String, dynamic>? conditions,
    @JsonKey(name: 'is_active') required this.isActive,
    @JsonKey(name: 'created_by') this.createdBy,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _daysOfWeek = daysOfWeek,
       _conditions = conditions;

  factory _$NotificationScheduleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationScheduleModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'notification_template_id')
  final String notificationTemplateId;
  @override
  @JsonKey(name: 'scheduled_time')
  final String scheduledTime;
  @override
  final String frequency;
  final List<int>? _daysOfWeek;
  @override
  @JsonKey(name: 'days_of_week')
  List<int>? get daysOfWeek {
    final value = _daysOfWeek;
    if (value == null) return null;
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _conditions;
  @override
  Map<String, dynamic>? get conditions {
    final value = _conditions;
    if (value == null) return null;
    if (_conditions is EqualUnmodifiableMapView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'NotificationScheduleModel(id: $id, notificationTemplateId: $notificationTemplateId, scheduledTime: $scheduledTime, frequency: $frequency, daysOfWeek: $daysOfWeek, conditions: $conditions, isActive: $isActive, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationScheduleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.notificationTemplateId, notificationTemplateId) ||
                other.notificationTemplateId == notificationTemplateId) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            const DeepCollectionEquality().equals(
              other._daysOfWeek,
              _daysOfWeek,
            ) &&
            const DeepCollectionEquality().equals(
              other._conditions,
              _conditions,
            ) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    notificationTemplateId,
    scheduledTime,
    frequency,
    const DeepCollectionEquality().hash(_daysOfWeek),
    const DeepCollectionEquality().hash(_conditions),
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  );

  /// Create a copy of NotificationScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationScheduleModelImplCopyWith<_$NotificationScheduleModelImpl>
  get copyWith =>
      __$$NotificationScheduleModelImplCopyWithImpl<
        _$NotificationScheduleModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationScheduleModelImplToJson(this);
  }
}

abstract class _NotificationScheduleModel implements NotificationScheduleModel {
  const factory _NotificationScheduleModel({
    required final String id,
    @JsonKey(name: 'notification_template_id')
    required final String notificationTemplateId,
    @JsonKey(name: 'scheduled_time') required final String scheduledTime,
    required final String frequency,
    @JsonKey(name: 'days_of_week') final List<int>? daysOfWeek,
    final Map<String, dynamic>? conditions,
    @JsonKey(name: 'is_active') required final bool isActive,
    @JsonKey(name: 'created_by') final String? createdBy,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$NotificationScheduleModelImpl;

  factory _NotificationScheduleModel.fromJson(Map<String, dynamic> json) =
      _$NotificationScheduleModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'notification_template_id')
  String get notificationTemplateId;
  @override
  @JsonKey(name: 'scheduled_time')
  String get scheduledTime;
  @override
  String get frequency;
  @override
  @JsonKey(name: 'days_of_week')
  List<int>? get daysOfWeek;
  @override
  Map<String, dynamic>? get conditions;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of NotificationScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationScheduleModelImplCopyWith<_$NotificationScheduleModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
