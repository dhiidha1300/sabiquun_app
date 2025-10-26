class DeedTemplateEntity {
  final String id;
  final String name;
  final String description;
  final int displayOrder;
  final double penaltyAmount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeedTemplateEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.displayOrder,
    required this.penaltyAmount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeedTemplateEntity &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.displayOrder == displayOrder &&
        other.penaltyAmount == penaltyAmount &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        displayOrder.hashCode ^
        penaltyAmount.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
