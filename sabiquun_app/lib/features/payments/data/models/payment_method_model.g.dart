// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentMethodModelImpl _$$PaymentMethodModelImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentMethodModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  displayName: json['display_name'] as String,
  isActive: json['is_active'] as bool,
  sortOrder: (json['sort_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$PaymentMethodModelImplToJson(
  _$PaymentMethodModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'display_name': instance.displayName,
  'is_active': instance.isActive,
  'sort_order': instance.sortOrder,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
