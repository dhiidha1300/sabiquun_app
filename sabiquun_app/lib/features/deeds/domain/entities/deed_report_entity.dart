import 'package:sabiquun_app/features/deeds/domain/entities/deed_entry_entity.dart';

enum ReportStatus {
  draft,
  submitted;

  String get displayName {
    switch (this) {
      case ReportStatus.draft:
        return 'Draft';
      case ReportStatus.submitted:
        return 'Submitted';
    }
  }

  bool get isDraft => this == ReportStatus.draft;
  bool get isEditable => this == ReportStatus.draft;
  bool get isSubmitted => this == ReportStatus.submitted;
}

class DeedReportEntity {
  final String id;
  final String userId;
  final DateTime reportDate;
  final double totalDeeds;
  final double sunnahCount;
  final double faraidCount;
  final ReportStatus status;
  final DateTime? submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DeedEntryEntity>? entries;

  const DeedReportEntity({
    required this.id,
    required this.userId,
    required this.reportDate,
    required this.totalDeeds,
    required this.sunnahCount,
    required this.faraidCount,
    required this.status,
    this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    this.entries,
  });

  // Total possible deeds (number of deed templates)
  int get totalDeedsCount => entries?.length ?? 0;

  // For backward compatibility - count of deeds with any completion
  int get completedDeedsCount =>
      entries?.where((e) => e.isCompleted).length ?? 0;
  int get missedDeedsCount => entries?.where((e) => e.isMissed).length ?? 0;

  double get completionPercentage {
    if (totalDeedsCount == 0) return 0.0;
    // Use the totalDeeds field from database which has the actual sum
    // Max possible is totalDeedsCount (each deed worth 1.0)
    return (totalDeeds / totalDeedsCount) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeedReportEntity &&
        other.id == id &&
        other.userId == userId &&
        other.reportDate == reportDate &&
        other.totalDeeds == totalDeeds &&
        other.sunnahCount == sunnahCount &&
        other.faraidCount == faraidCount &&
        other.status == status &&
        other.submittedAt == submittedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        reportDate.hashCode ^
        totalDeeds.hashCode ^
        sunnahCount.hashCode ^
        faraidCount.hashCode ^
        status.hashCode ^
        submittedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
