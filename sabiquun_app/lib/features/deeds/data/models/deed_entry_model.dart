import 'package:sabiquun_app/features/deeds/domain/entities/deed_entry_entity.dart';

class DeedEntryModel extends DeedEntryEntity {
  const DeedEntryModel({
    required super.id,
    required super.reportId,
    required super.templateId,
    required super.value,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DeedEntryModel.fromJson(Map<String, dynamic> json) {
    return DeedEntryModel(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      templateId: json['template_id'] as String,
      value: json['value'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'template_id': templateId,
      'value': value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeedEntryEntity toEntity() {
    return DeedEntryEntity(
      id: id,
      reportId: reportId,
      templateId: templateId,
      value: value,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
