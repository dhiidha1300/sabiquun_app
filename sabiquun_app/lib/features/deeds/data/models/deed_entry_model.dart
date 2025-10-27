import 'package:sabiquun_app/features/deeds/domain/entities/deed_entry_entity.dart';

class DeedEntryModel extends DeedEntryEntity {
  const DeedEntryModel({
    required super.id,
    required super.reportId,
    required super.deedTemplateId,
    required super.deedValue,
    required super.createdAt,
  });

  factory DeedEntryModel.fromJson(Map<String, dynamic> json) {
    return DeedEntryModel(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      deedTemplateId: json['deed_template_id'] as String,
      deedValue: (json['deed_value'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'deed_template_id': deedTemplateId,
      'deed_value': deedValue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DeedEntryEntity toEntity() {
    return DeedEntryEntity(
      id: id,
      reportId: reportId,
      deedTemplateId: deedTemplateId,
      deedValue: deedValue,
      createdAt: createdAt,
    );
  }
}
