import 'package:sabiquun_app/features/deeds/data/models/deed_entry_model.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';

class DeedReportModel extends DeedReportEntity {
  const DeedReportModel({
    required super.id,
    required super.userId,
    required super.reportDate,
    required super.status,
    super.notes,
    required super.penaltyAmount,
    required super.submittedAt,
    super.approvedByUserId,
    super.approvedAt,
    super.rejectionReason,
    required super.createdAt,
    required super.updatedAt,
    super.entries,
  });

  factory DeedReportModel.fromJson(Map<String, dynamic> json) {
    ReportStatus status;
    final statusStr = json['status'] as String;
    switch (statusStr) {
      case 'pending':
        status = ReportStatus.pending;
        break;
      case 'submitted':
        status = ReportStatus.submitted;
        break;
      case 'approved':
        status = ReportStatus.approved;
        break;
      case 'rejected':
        status = ReportStatus.rejected;
        break;
      default:
        status = ReportStatus.pending;
    }

    return DeedReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reportDate: DateTime.parse(json['report_date'] as String),
      status: status,
      notes: json['notes'] as String?,
      penaltyAmount: (json['penalty_amount'] as num?)?.toDouble() ?? 0.0,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      approvedByUserId: json['approved_by_user_id'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
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
      'status': status.name,
      'notes': notes,
      'penalty_amount': penaltyAmount,
      'submitted_at': submittedAt.toIso8601String(),
      'approved_by_user_id': approvedByUserId,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeedReportEntity toEntity() {
    return DeedReportEntity(
      id: id,
      userId: userId,
      reportDate: reportDate,
      status: status,
      notes: notes,
      penaltyAmount: penaltyAmount,
      submittedAt: submittedAt,
      approvedByUserId: approvedByUserId,
      approvedAt: approvedAt,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      entries: entries,
    );
  }
}
