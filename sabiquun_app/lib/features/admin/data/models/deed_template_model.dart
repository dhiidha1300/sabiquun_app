import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../deeds/domain/entities/deed_template_entity.dart';

part 'deed_template_model.freezed.dart';

/// Data model for deed templates with JSON serialization
@freezed
class DeedTemplateModel with _$DeedTemplateModel {
  const factory DeedTemplateModel({
    required String id,
    required String deedName,
    required String deedKey,
    required String category, // 'faraid' or 'sunnah'
    required String valueType, // 'binary' or 'fractional'
    required int sortOrder,
    required bool isActive,
    required bool isSystemDefault,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DeedTemplateModel;

  const DeedTemplateModel._();

  /// Create from JSON (Supabase response)
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

  /// Convert to JSON (for Supabase insert/update)
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

  /// Convert to domain entity
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

  /// Create from domain entity
  factory DeedTemplateModel.fromEntity(DeedTemplateEntity entity) {
    return DeedTemplateModel(
      id: entity.id,
      deedName: entity.deedName,
      deedKey: entity.deedKey,
      category: entity.category,
      valueType: entity.valueType,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      isSystemDefault: entity.isSystemDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
