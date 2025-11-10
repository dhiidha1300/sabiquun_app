enum ExcuseType {
  sickness,
  travel,
  raining,
  other;

  String get displayName {
    switch (this) {
      case ExcuseType.sickness:
        return 'Sickness';
      case ExcuseType.travel:
        return 'Travel';
      case ExcuseType.raining:
        return 'Raining';
      case ExcuseType.other:
        return 'Other';
    }
  }

  static ExcuseType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sickness':
        return ExcuseType.sickness;
      case 'travel':
        return ExcuseType.travel;
      case 'raining':
        return ExcuseType.raining;
      case 'other':
        return ExcuseType.other;
      default:
        return ExcuseType.other;
    }
  }
}

enum ExcuseStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ExcuseStatus.pending:
        return 'Pending';
      case ExcuseStatus.approved:
        return 'Approved';
      case ExcuseStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isPending => this == ExcuseStatus.pending;
  bool get isApproved => this == ExcuseStatus.approved;
  bool get isRejected => this == ExcuseStatus.rejected;

  static ExcuseStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ExcuseStatus.pending;
      case 'approved':
        return ExcuseStatus.approved;
      case 'rejected':
        return ExcuseStatus.rejected;
      default:
        return ExcuseStatus.pending;
    }
  }
}

class ExcuseEntity {
  final String id;
  final String userId;
  final DateTime excuseDate;
  final ExcuseType excuseType;
  final List<String> affectedDeeds;
  final String? description;
  final ExcuseStatus status;
  final String? reviewedBy;
  final String? reviewNotes;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExcuseEntity({
    required this.id,
    required this.userId,
    required this.excuseDate,
    required this.excuseType,
    required this.affectedDeeds,
    this.description,
    required this.status,
    this.reviewedBy,
    this.reviewNotes,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAllDeeds => affectedDeeds.isEmpty || affectedDeeds.contains('all');

  String get affectedDeedsDisplay {
    if (isAllDeeds) return 'All deeds';
    if (affectedDeeds.length <= 3) {
      return affectedDeeds.join(', ');
    }
    return '${affectedDeeds.take(3).join(', ')} +${affectedDeeds.length - 3} more';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExcuseEntity &&
        other.id == id &&
        other.userId == userId &&
        other.excuseDate == excuseDate &&
        other.excuseType == excuseType &&
        other.status == status &&
        other.reviewedBy == reviewedBy &&
        other.reviewNotes == reviewNotes &&
        other.reviewedAt == reviewedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        excuseDate.hashCode ^
        excuseType.hashCode ^
        status.hashCode ^
        reviewedBy.hashCode ^
        reviewNotes.hashCode ^
        reviewedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
