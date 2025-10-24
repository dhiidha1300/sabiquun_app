// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      role: json['role'] as String,
      accountStatus: json['account_status'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] == null
          ? null
          : DateTime.parse(json['last_login_at'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'profile_photo_url': instance.profilePhotoUrl,
      'role': instance.role,
      'account_status': instance.accountStatus,
      'created_at': instance.createdAt?.toIso8601String(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
    };
