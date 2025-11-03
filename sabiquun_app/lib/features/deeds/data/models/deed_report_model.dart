import 'package:sabiquun_app/features/deeds/data/models/deed_entry_model.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';

class DeedReportModel extends DeedReportEntity {
  const DeedReportModel({
    required super.id,
    required super.userId,
    required super.reportDate,
    required super.totalDeeds,
    required super.sunnahCount,
    required super.faraidCount,
    required super.status,
    super.submittedAt,
    required super.createdAt,
    required super.updatedAt,
    super.entries,
  });

  factory DeedReportModel.fromJson(Map<String, dynamic> json) {
    ReportStatus status;
    final statusStr = json['status'] as String?;
    switch (statusStr) {
      case 'draft':
        status = ReportStatus.draft;
        break;
      case 'submitted':
        status = ReportStatus.submitted;
        break;
      default:
        status = ReportStatus.draft;
    }

    return DeedReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reportDate: DateTime.parse(json['report_date'] as String),
      totalDeeds: (json['total_deeds'] as num?)?.toDouble() ?? 0.0,
      sunnahCount: (json['sunnah_count'] as num?)?.toDouble() ?? 0.0,
      faraidCount: (json['faraid_count'] as num?)?.toDouble() ?? 0.0,
      status: status,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      entries: json['deed_entries'] != null
          ? (json['deed_entries'] as List)
              .map((e) => DeedEntryModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'report_date': reportDate.toIso8601String().split('T')[0],
      'total_deeds': totalDeeds,
      'sunnah_count': sunnahCount,
      'faraid_count': faraidCount,
      'status': status.name,
      'submitted_at': submittedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeedReportEntity toEntity() {
    return DeedReportEntity(
      id: id,
      userId: userId,
      reportDate: reportDate,
      totalDeeds: totalDeeds,
      sunnahCount: sunnahCount,
      faraidCount: faraidCount,
      status: status,
      submittedAt: submittedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      entries: entries?.map((e) => (e as DeedEntryModel).toEntity()).toList(),
    );
  }
}
