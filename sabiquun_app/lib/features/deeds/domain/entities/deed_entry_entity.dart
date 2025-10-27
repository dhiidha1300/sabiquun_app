class DeedEntryEntity {
  final String id;
  final String reportId;
  final String deedTemplateId;
  final double deedValue; // 0.0 to 1.0, supports 0.1 increments
  final DateTime createdAt;

  const DeedEntryEntity({
    required this.id,
    required this.reportId,
    required this.deedTemplateId,
    required this.deedValue,
    required this.createdAt,
  });

  bool get isCompleted => deedValue > 0;
  bool get isMissed => deedValue == 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeedEntryEntity &&
        other.id == id &&
        other.reportId == reportId &&
        other.deedTemplateId == deedTemplateId &&
        other.deedValue == deedValue &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        reportId.hashCode ^
        deedTemplateId.hashCode ^
        deedValue.hashCode ^
        createdAt.hashCode;
  }
}
