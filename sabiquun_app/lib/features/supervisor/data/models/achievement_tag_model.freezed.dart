// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_tag_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AchievementTagModel _$AchievementTagModelFromJson(Map<String, dynamic> json) {
  return _AchievementTagModel.fromJson(json);
}

/// @nodoc
mixin _$AchievementTagModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  Map<String, dynamic>? get criteria => throw _privateConstructorUsedError;
  bool get autoAssign => throw _privateConstructorUsedError;
  int get activeUserCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AchievementTagModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AchievementTagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementTagModelCopyWith<AchievementTagModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementTagModelCopyWith<$Res> {
  factory $AchievementTagModelCopyWith(
    AchievementTagModel value,
    $Res Function(AchievementTagModel) then,
  ) = _$AchievementTagModelCopyWithImpl<$Res, AchievementTagModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String icon,
    Map<String, dynamic>? criteria,
    bool autoAssign,
    int activeUserCount,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AchievementTagModelCopyWithImpl<$Res, $Val extends AchievementTagModel>
    implements $AchievementTagModelCopyWith<$Res> {
  _$AchievementTagModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AchievementTagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = null,
    Object? criteria = freezed,
    Object? autoAssign = null,
    Object? activeUserCount = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            criteria: freezed == criteria
                ? _value.criteria
                : criteria // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            autoAssign: null == autoAssign
                ? _value.autoAssign
                : autoAssign // ignore: cast_nullable_to_non_nullable
                      as bool,
            activeUserCount: null == activeUserCount
                ? _value.activeUserCount
                : activeUserCount // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$AchievementTagModelImplCopyWith<$Res>
    implements $AchievementTagModelCopyWith<$Res> {
  factory _$$AchievementTagModelImplCopyWith(
    _$AchievementTagModelImpl value,
    $Res Function(_$AchievementTagModelImpl) then,
  ) = __$$AchievementTagModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String icon,
    Map<String, dynamic>? criteria,
    bool autoAssign,
    int activeUserCount,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AchievementTagModelImplCopyWithImpl<$Res>
    extends _$AchievementTagModelCopyWithImpl<$Res, _$AchievementTagModelImpl>
    implements _$$AchievementTagModelImplCopyWith<$Res> {
  __$$AchievementTagModelImplCopyWithImpl(
    _$AchievementTagModelImpl _value,
    $Res Function(_$AchievementTagModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AchievementTagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = null,
    Object? criteria = freezed,
    Object? autoAssign = null,
    Object? activeUserCount = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AchievementTagModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        criteria: freezed == criteria
            ? _value._criteria
            : criteria // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        autoAssign: null == autoAssign
            ? _value.autoAssign
            : autoAssign // ignore: cast_nullable_to_non_nullable
                  as bool,
        activeUserCount: null == activeUserCount
            ? _value.activeUserCount
            : activeUserCount // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$AchievementTagModelImpl extends _AchievementTagModel {
  const _$AchievementTagModelImpl({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    final Map<String, dynamic>? criteria,
    required this.autoAssign,
    required this.activeUserCount,
    required this.createdAt,
  }) : _criteria = criteria,
       super._();

  factory _$AchievementTagModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementTagModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String icon;
  final Map<String, dynamic>? _criteria;
  @override
  Map<String, dynamic>? get criteria {
    final value = _criteria;
    if (value == null) return null;
    if (_criteria is EqualUnmodifiableMapView) return _criteria;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool autoAssign;
  @override
  final int activeUserCount;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AchievementTagModel(id: $id, name: $name, description: $description, icon: $icon, criteria: $criteria, autoAssign: $autoAssign, activeUserCount: $activeUserCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementTagModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._criteria, _criteria) &&
            (identical(other.autoAssign, autoAssign) ||
                other.autoAssign == autoAssign) &&
            (identical(other.activeUserCount, activeUserCount) ||
                other.activeUserCount == activeUserCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    icon,
    const DeepCollectionEquality().hash(_criteria),
    autoAssign,
    activeUserCount,
    createdAt,
  );

  /// Create a copy of AchievementTagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementTagModelImplCopyWith<_$AchievementTagModelImpl> get copyWith =>
      __$$AchievementTagModelImplCopyWithImpl<_$AchievementTagModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementTagModelImplToJson(this);
  }
}

abstract class _AchievementTagModel extends AchievementTagModel {
  const factory _AchievementTagModel({
    required final String id,
    required final String name,
    final String? description,
    required final String icon,
    final Map<String, dynamic>? criteria,
    required final bool autoAssign,
    required final int activeUserCount,
    required final DateTime createdAt,
  }) = _$AchievementTagModelImpl;
  const _AchievementTagModel._() : super._();

  factory _AchievementTagModel.fromJson(Map<String, dynamic> json) =
      _$AchievementTagModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get icon;
  @override
  Map<String, dynamic>? get criteria;
  @override
  bool get autoAssign;
  @override
  int get activeUserCount;
  @override
  DateTime get createdAt;

  /// Create a copy of AchievementTagModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementTagModelImplCopyWith<_$AchievementTagModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
