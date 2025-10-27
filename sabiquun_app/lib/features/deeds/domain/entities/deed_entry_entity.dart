class DeedEntryEntity {
  final String id;
  final String reportId;
  final String templateId;
  final int value;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeedEntryEntity({
    required this.id,
    required this.reportId,
    required this.templateId,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => value > 0;
  bool get isMissed => value == 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeedEntryEntity &&
        other.id == id &&
        other.reportId == reportId &&
        other.templateId == templateId &&
        other.value == value &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        reportId.hashCode ^
        templateId.hashCode ^
        value.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
