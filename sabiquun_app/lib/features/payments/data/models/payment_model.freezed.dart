// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaymentModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get paymentMethodId => throw _privateConstructorUsedError;
  String? get referenceNumber => throw _privateConstructorUsedError;
  String? get paymentType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get reviewedBy => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get paymentMethodName => throw _privateConstructorUsedError;
  String? get reviewerName => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;
  String? get userEmail => throw _privateConstructorUsedError;
  double? get userCurrentBalance => throw _privateConstructorUsedError;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentModelCopyWith<PaymentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentModelCopyWith<$Res> {
  factory $PaymentModelCopyWith(
    PaymentModel value,
    $Res Function(PaymentModel) then,
  ) = _$PaymentModelCopyWithImpl<$Res, PaymentModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    double amount,
    String paymentMethodId,
    String? referenceNumber,
    String? paymentType,
    String status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    DateTime createdAt,
    DateTime? updatedAt,
    String? paymentMethodName,
    String? reviewerName,
    String? userName,
    String? userEmail,
    double? userCurrentBalance,
  });
}

/// @nodoc
class _$PaymentModelCopyWithImpl<$Res, $Val extends PaymentModel>
    implements $PaymentModelCopyWith<$Res> {
  _$PaymentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? amount = null,
    Object? paymentMethodId = null,
    Object? referenceNumber = freezed,
    Object? paymentType = freezed,
    Object? status = null,
    Object? reviewedBy = freezed,
    Object? reviewedAt = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? paymentMethodName = freezed,
    Object? reviewerName = freezed,
    Object? userName = freezed,
    Object? userEmail = freezed,
    Object? userCurrentBalance = freezed,
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
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentMethodId: null == paymentMethodId
                ? _value.paymentMethodId
                : paymentMethodId // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceNumber: freezed == referenceNumber
                ? _value.referenceNumber
                : referenceNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentType: freezed == paymentType
                ? _value.paymentType
                : paymentType // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            reviewedBy: freezed == reviewedBy
                ? _value.reviewedBy
                : reviewedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewedAt: freezed == reviewedAt
                ? _value.reviewedAt
                : reviewedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            rejectionReason: freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            paymentMethodName: freezed == paymentMethodName
                ? _value.paymentMethodName
                : paymentMethodName // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewerName: freezed == reviewerName
                ? _value.reviewerName
                : reviewerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            userEmail: freezed == userEmail
                ? _value.userEmail
                : userEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            userCurrentBalance: freezed == userCurrentBalance
                ? _value.userCurrentBalance
                : userCurrentBalance // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentModelImplCopyWith<$Res>
    implements $PaymentModelCopyWith<$Res> {
  factory _$$PaymentModelImplCopyWith(
    _$PaymentModelImpl value,
    $Res Function(_$PaymentModelImpl) then,
  ) = __$$PaymentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    double amount,
    String paymentMethodId,
    String? referenceNumber,
    String? paymentType,
    String status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    DateTime createdAt,
    DateTime? updatedAt,
    String? paymentMethodName,
    String? reviewerName,
    String? userName,
    String? userEmail,
    double? userCurrentBalance,
  });
}

/// @nodoc
class __$$PaymentModelImplCopyWithImpl<$Res>
    extends _$PaymentModelCopyWithImpl<$Res, _$PaymentModelImpl>
    implements _$$PaymentModelImplCopyWith<$Res> {
  __$$PaymentModelImplCopyWithImpl(
    _$PaymentModelImpl _value,
    $Res Function(_$PaymentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? amount = null,
    Object? paymentMethodId = null,
    Object? referenceNumber = freezed,
    Object? paymentType = freezed,
    Object? status = null,
    Object? reviewedBy = freezed,
    Object? reviewedAt = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? paymentMethodName = freezed,
    Object? reviewerName = freezed,
    Object? userName = freezed,
    Object? userEmail = freezed,
    Object? userCurrentBalance = freezed,
  }) {
    return _then(
      _$PaymentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentMethodId: null == paymentMethodId
            ? _value.paymentMethodId
            : paymentMethodId // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceNumber: freezed == referenceNumber
            ? _value.referenceNumber
            : referenceNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentType: freezed == paymentType
            ? _value.paymentType
            : paymentType // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        reviewedBy: freezed == reviewedBy
            ? _value.reviewedBy
            : reviewedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewedAt: freezed == reviewedAt
            ? _value.reviewedAt
            : reviewedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        rejectionReason: freezed == rejectionReason
            ? _value.rejectionReason
            : rejectionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        paymentMethodName: freezed == paymentMethodName
            ? _value.paymentMethodName
            : paymentMethodName // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewerName: freezed == reviewerName
            ? _value.reviewerName
            : reviewerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        userEmail: freezed == userEmail
            ? _value.userEmail
            : userEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        userCurrentBalance: freezed == userCurrentBalance
            ? _value.userCurrentBalance
            : userCurrentBalance // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

class _$PaymentModelImpl extends _PaymentModel {
  const _$PaymentModelImpl({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentMethodId,
    this.referenceNumber,
    this.paymentType,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
    this.paymentMethodName,
    this.reviewerName,
    this.userName,
    this.userEmail,
    this.userCurrentBalance,
  }) : super._();

  @override
  final String id;
  @override
  final String userId;
  @override
  final double amount;
  @override
  final String paymentMethodId;
  @override
  final String? referenceNumber;
  @override
  final String? paymentType;
  @override
  final String status;
  @override
  final String? reviewedBy;
  @override
  final DateTime? reviewedAt;
  @override
  final String? rejectionReason;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? paymentMethodName;
  @override
  final String? reviewerName;
  @override
  final String? userName;
  @override
  final String? userEmail;
  @override
  final double? userCurrentBalance;

  @override
  String toString() {
    return 'PaymentModel(id: $id, userId: $userId, amount: $amount, paymentMethodId: $paymentMethodId, referenceNumber: $referenceNumber, paymentType: $paymentType, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt, paymentMethodName: $paymentMethodName, reviewerName: $reviewerName, userName: $userName, userEmail: $userEmail, userCurrentBalance: $userCurrentBalance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentMethodId, paymentMethodId) ||
                other.paymentMethodId == paymentMethodId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.paymentType, paymentType) ||
                other.paymentType == paymentType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.paymentMethodName, paymentMethodName) ||
                other.paymentMethodName == paymentMethodName) &&
            (identical(other.reviewerName, reviewerName) ||
                other.reviewerName == reviewerName) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userCurrentBalance, userCurrentBalance) ||
                other.userCurrentBalance == userCurrentBalance));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    amount,
    paymentMethodId,
    referenceNumber,
    paymentType,
    status,
    reviewedBy,
    reviewedAt,
    rejectionReason,
    createdAt,
    updatedAt,
    paymentMethodName,
    reviewerName,
    userName,
    userEmail,
    userCurrentBalance,
  );

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentModelImplCopyWith<_$PaymentModelImpl> get copyWith =>
      __$$PaymentModelImplCopyWithImpl<_$PaymentModelImpl>(this, _$identity);
}

abstract class _PaymentModel extends PaymentModel {
  const factory _PaymentModel({
    required final String id,
    required final String userId,
    required final double amount,
    required final String paymentMethodId,
    final String? referenceNumber,
    final String? paymentType,
    required final String status,
    final String? reviewedBy,
    final DateTime? reviewedAt,
    final String? rejectionReason,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final String? paymentMethodName,
    final String? reviewerName,
    final String? userName,
    final String? userEmail,
    final double? userCurrentBalance,
  }) = _$PaymentModelImpl;
  const _PaymentModel._() : super._();

  @override
  String get id;
  @override
  String get userId;
  @override
  double get amount;
  @override
  String get paymentMethodId;
  @override
  String? get referenceNumber;
  @override
  String? get paymentType;
  @override
  String get status;
  @override
  String? get reviewedBy;
  @override
  DateTime? get reviewedAt;
  @override
  String? get rejectionReason;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get paymentMethodName;
  @override
  String? get reviewerName;
  @override
  String? get userName;
  @override
  String? get userEmail;
  @override
  double? get userCurrentBalance;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentModelImplCopyWith<_$PaymentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
