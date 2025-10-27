import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';

class DeedTemplateModel extends DeedTemplateEntity {
  const DeedTemplateModel({
    required super.id,
    required super.deedName,
    required super.deedKey,
    required super.category,
    required super.valueType,
    required super.sortOrder,
    required super.isActive,
    required super.isSystemDefault,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DeedTemplateModel.fromJson(Map<String, dynamic> json) {
    return DeedTemplateModel(
      id: json['id'] as String,
      deedName: json['deed_name'] as String,
      deedKey: json['deed_key'] as String,
      category: json['category'] as String,
      valueType: json['value_type'] as String,
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool? ?? true,
      isSystemDefault: json['is_system_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deed_name': deedName,
      'deed_key': deedKey,
      'category': category,
      'value_type': valueType,
      'sort_order': sortOrder,
      'is_active': isActive,
      'is_system_default': isSystemDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeedTemplateEntity toEntity() {
    return DeedTemplateEntity(
      id: id,
      deedName: deedName,
      deedKey: deedKey,
      category: category,
      valueType: valueType,
      sortOrder: sortOrder,
      isActive: isActive,
      isSystemDefault: isSystemDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
