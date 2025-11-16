// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_day_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestDayModelImpl _$$RestDayModelImplFromJson(Map<String, dynamic> json) =>
    _$RestDayModelImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      description: json['description'] as String,
      isRecurring: json['is_recurring'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RestDayModelImplToJson(_$RestDayModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'description': instance.description,
      'is_recurring': instance.isRecurring,
      'created_at': instance.createdAt.toIso8601String(),
    };
