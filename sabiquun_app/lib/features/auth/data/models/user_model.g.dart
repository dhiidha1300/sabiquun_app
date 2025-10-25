// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['name'] as String,
      phoneNumber: json['phone'] as String?,
      profilePhotoUrl: json['photo_url'] as String?,
      role: json['role'] as String,
      accountStatus: json['account_status'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.fullName,
      'phone': instance.phoneNumber,
      'photo_url': instance.profilePhotoUrl,
      'role': instance.role,
      'account_status': instance.accountStatus,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.lastLoginAt?.toIso8601String(),
    };
