// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationTemplateModel _$NotificationTemplateModelFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationTemplateModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationTemplateModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'template_key')
  String get templateKey => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_subject')
  String? get emailSubject => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_body')
  String? get emailBody => throw _privateConstructorUsedError;
  @JsonKey(name: 'notification_type')
  String get notificationType => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_enabled')
  bool get isEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_system_default')
  bool get isSystemDefault => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationTemplateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationTemplateModelCopyWith<NotificationTemplateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationTemplateModelCopyWith<$Res> {
  factory $NotificationTemplateModelCopyWith(
    NotificationTemplateModel value,
    $Res Function(NotificationTemplateModel) then,
  ) = _$NotificationTemplateModelCopyWithImpl<$Res, NotificationTemplateModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'template_key') String templateKey,
    String title,
    String body,
    @JsonKey(name: 'email_subject') String? emailSubject,
    @JsonKey(name: 'email_body') String? emailBody,
    @JsonKey(name: 'notification_type') String notificationType,
    @JsonKey(name: 'is_enabled') bool isEnabled,
    @JsonKey(name: 'is_system_default') bool isSystemDefault,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$NotificationTemplateModelCopyWithImpl<
  $Res,
  $Val extends NotificationTemplateModel
>
    implements $NotificationTemplateModelCopyWith<$Res> {
  _$NotificationTemplateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateKey = null,
    Object? title = null,
    Object? body = null,
    Object? emailSubject = freezed,
    Object? emailBody = freezed,
    Object? notificationType = null,
    Object? isEnabled = null,
    Object? isSystemDefault = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            templateKey: null == templateKey
                ? _value.templateKey
                : templateKey // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            emailSubject: freezed == emailSubject
                ? _value.emailSubject
                : emailSubject // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailBody: freezed == emailBody
                ? _value.emailBody
                : emailBody // ignore: cast_nullable_to_non_nullable
                      as String?,
            notificationType: null == notificationType
                ? _value.notificationType
                : notificationType // ignore: cast_nullable_to_non_nullable
                      as String,
            isEnabled: null == isEnabled
                ? _value.isEnabled
                : isEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSystemDefault: null == isSystemDefault
                ? _value.isSystemDefault
                : isSystemDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$NotificationTemplateModelImplCopyWith<$Res>
    implements $NotificationTemplateModelCopyWith<$Res> {
  factory _$$NotificationTemplateModelImplCopyWith(
    _$NotificationTemplateModelImpl value,
    $Res Function(_$NotificationTemplateModelImpl) then,
  ) = __$$NotificationTemplateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'template_key') String templateKey,
    String title,
    String body,
    @JsonKey(name: 'email_subject') String? emailSubject,
    @JsonKey(name: 'email_body') String? emailBody,
    @JsonKey(name: 'notification_type') String notificationType,
    @JsonKey(name: 'is_enabled') bool isEnabled,
    @JsonKey(name: 'is_system_default') bool isSystemDefault,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$NotificationTemplateModelImplCopyWithImpl<$Res>
    extends
        _$NotificationTemplateModelCopyWithImpl<
          $Res,
          _$NotificationTemplateModelImpl
        >
    implements _$$NotificationTemplateModelImplCopyWith<$Res> {
  __$$NotificationTemplateModelImplCopyWithImpl(
    _$NotificationTemplateModelImpl _value,
    $Res Function(_$NotificationTemplateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateKey = null,
    Object? title = null,
    Object? body = null,
    Object? emailSubject = freezed,
    Object? emailBody = freezed,
    Object? notificationType = null,
    Object? isEnabled = null,
    Object? isSystemDefault = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$NotificationTemplateModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        templateKey: null == templateKey
            ? _value.templateKey
            : templateKey // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        emailSubject: freezed == emailSubject
            ? _value.emailSubject
            : emailSubject // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailBody: freezed == emailBody
            ? _value.emailBody
            : emailBody // ignore: cast_nullable_to_non_nullable
                  as String?,
        notificationType: null == notificationType
            ? _value.notificationType
            : notificationType // ignore: cast_nullable_to_non_nullable
                  as String,
        isEnabled: null == isEnabled
            ? _value.isEnabled
            : isEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSystemDefault: null == isSystemDefault
            ? _value.isSystemDefault
            : isSystemDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$NotificationTemplateModelImpl implements _NotificationTemplateModel {
  const _$NotificationTemplateModelImpl({
    required this.id,
    @JsonKey(name: 'template_key') required this.templateKey,
    required this.title,
    required this.body,
    @JsonKey(name: 'email_subject') this.emailSubject,
    @JsonKey(name: 'email_body') this.emailBody,
    @JsonKey(name: 'notification_type') required this.notificationType,
    @JsonKey(name: 'is_enabled') required this.isEnabled,
    @JsonKey(name: 'is_system_default') required this.isSystemDefault,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$NotificationTemplateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationTemplateModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'template_key')
  final String templateKey;
  @override
  final String title;
  @override
  final String body;
  @override
  @JsonKey(name: 'email_subject')
  final String? emailSubject;
  @override
  @JsonKey(name: 'email_body')
  final String? emailBody;
  @override
  @JsonKey(name: 'notification_type')
  final String notificationType;
  @override
  @JsonKey(name: 'is_enabled')
  final bool isEnabled;
  @override
  @JsonKey(name: 'is_system_default')
  final bool isSystemDefault;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'NotificationTemplateModel(id: $id, templateKey: $templateKey, title: $title, body: $body, emailSubject: $emailSubject, emailBody: $emailBody, notificationType: $notificationType, isEnabled: $isEnabled, isSystemDefault: $isSystemDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationTemplateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateKey, templateKey) ||
                other.templateKey == templateKey) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.emailSubject, emailSubject) ||
                other.emailSubject == emailSubject) &&
            (identical(other.emailBody, emailBody) ||
                other.emailBody == emailBody) &&
            (identical(other.notificationType, notificationType) ||
                other.notificationType == notificationType) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.isSystemDefault, isSystemDefault) ||
                other.isSystemDefault == isSystemDefault) &&
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
    templateKey,
    title,
    body,
    emailSubject,
    emailBody,
    notificationType,
    isEnabled,
    isSystemDefault,
    createdAt,
    updatedAt,
  );

  /// Create a copy of NotificationTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationTemplateModelImplCopyWith<_$NotificationTemplateModelImpl>
  get copyWith =>
      __$$NotificationTemplateModelImplCopyWithImpl<
        _$NotificationTemplateModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationTemplateModelImplToJson(this);
  }
}

abstract class _NotificationTemplateModel implements NotificationTemplateModel {
  const factory _NotificationTemplateModel({
    required final String id,
    @JsonKey(name: 'template_key') required final String templateKey,
    required final String title,
    required final String body,
    @JsonKey(name: 'email_subject') final String? emailSubject,
    @JsonKey(name: 'email_body') final String? emailBody,
    @JsonKey(name: 'notification_type') required final String notificationType,
    @JsonKey(name: 'is_enabled') required final bool isEnabled,
    @JsonKey(name: 'is_system_default') required final bool isSystemDefault,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$NotificationTemplateModelImpl;

  factory _NotificationTemplateModel.fromJson(Map<String, dynamic> json) =
      _$NotificationTemplateModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'template_key')
  String get templateKey;
  @override
  String get title;
  @override
  String get body;
  @override
  @JsonKey(name: 'email_subject')
  String? get emailSubject;
  @override
  @JsonKey(name: 'email_body')
  String? get emailBody;
  @override
  @JsonKey(name: 'notification_type')
  String get notificationType;
  @override
  @JsonKey(name: 'is_enabled')
  bool get isEnabled;
  @override
  @JsonKey(name: 'is_system_default')
  bool get isSystemDefault;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of NotificationTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationTemplateModelImplCopyWith<_$NotificationTemplateModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
