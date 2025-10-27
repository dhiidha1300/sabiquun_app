class DeedTemplateEntity {
  final String id;
  final String deedName;
  final String deedKey;
  final String category; // 'sunnah' or 'faraid'
  final String valueType; // 'binary' or 'fractional'
  final int sortOrder;
  final bool isActive;
  final bool isSystemDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeedTemplateEntity({
    required this.id,
    required this.deedName,
    required this.deedKey,
    required this.category,
    required this.valueType,
    required this.sortOrder,
    required this.isActive,
    required this.isSystemDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeedTemplateEntity &&
        other.id == id &&
        other.deedName == deedName &&
        other.deedKey == deedKey &&
        other.category == category &&
        other.valueType == valueType &&
        other.sortOrder == sortOrder &&
        other.isActive == isActive &&
        other.isSystemDefault == isSystemDefault &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deedName.hashCode ^
        deedKey.hashCode ^
        category.hashCode ^
        valueType.hashCode ^
        sortOrder.hashCode ^
        isActive.hashCode ^
        isSystemDefault.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
