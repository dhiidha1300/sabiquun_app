import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';

class DeedTemplateModel extends DeedTemplateEntity {
  const DeedTemplateModel({
    required super.id,
    required super.name,
    required super.description,
    required super.displayOrder,
    required super.penaltyAmount,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DeedTemplateModel.fromJson(Map<String, dynamic> json) {
    return DeedTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      displayOrder: json['display_order'] as int,
      penaltyAmount: (json['penalty_amount'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'display_order': displayOrder,
      'penalty_amount': penaltyAmount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeedTemplateEntity toEntity() {
    return DeedTemplateEntity(
      id: id,
      name: name,
      description: description,
      displayOrder: displayOrder,
      penaltyAmount: penaltyAmount,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
