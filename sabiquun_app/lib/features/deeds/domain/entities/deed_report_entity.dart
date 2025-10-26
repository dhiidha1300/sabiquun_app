import 'package:sabiquun_app/features/deeds/domain/entities/deed_entry_entity.dart';

enum ReportStatus {
  pending,
  submitted,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.approved:
        return 'Approved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isEditable => this == ReportStatus.pending;
  bool get isSubmitted => this == ReportStatus.submitted;
  bool get isApproved => this == ReportStatus.approved;
  bool get isRejected => this == ReportStatus.rejected;
}

class DeedReportEntity {
  final String id;
  final String userId;
  final DateTime reportDate;
  final ReportStatus status;
  final String? notes;
  final double penaltyAmount;
  final DateTime submittedAt;
  final String? approvedByUserId;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DeedEntryEntity>? entries;

  const DeedReportEntity({
    required this.id,
    required this.userId,
    required this.reportDate,
    required this.status,
    this.notes,
    required this.penaltyAmount,
    required this.submittedAt,
    this.approvedByUserId,
    this.approvedAt,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.entries,
  });

  int get completedDeedsCount =>
      entries?.where((e) => e.isCompleted).length ?? 0;
  int get missedDeedsCount => entries?.where((e) => e.isMissed).length ?? 0;
  int get totalDeeds => entries?.length ?? 0;

  double get completionPercentage {
    if (totalDeeds == 0) return 0.0;
    return (completedDeedsCount / totalDeeds) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeedReportEntity &&
        other.id == id &&
        other.userId == userId &&
        other.reportDate == reportDate &&
        other.status == status &&
        other.notes == notes &&
        other.penaltyAmount == penaltyAmount &&
        other.submittedAt == submittedAt &&
        other.approvedByUserId == approvedByUserId &&
        other.approvedAt == approvedAt &&
        other.rejectionReason == rejectionReason &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        reportDate.hashCode ^
        status.hashCode ^
        notes.hashCode ^
        penaltyAmount.hashCode ^
        submittedAt.hashCode ^
        approvedByUserId.hashCode ^
        approvedAt.hashCode ^
        rejectionReason.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
