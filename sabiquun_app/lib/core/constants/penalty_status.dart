enum PenaltyStatus {
  unpaid,
  partiallyPaid,
  paid,
  waived;

  String get displayName {
    switch (this) {
      case PenaltyStatus.unpaid:
        return 'Unpaid';
      case PenaltyStatus.partiallyPaid:
        return 'Partially Paid';
      case PenaltyStatus.paid:
        return 'Paid';
      case PenaltyStatus.waived:
        return 'Waived';
    }
  }

  String get databaseValue {
    switch (this) {
      case PenaltyStatus.unpaid:
        return 'unpaid';
      case PenaltyStatus.partiallyPaid:
        return 'partially_paid';
      case PenaltyStatus.paid:
        return 'paid';
      case PenaltyStatus.waived:
        return 'waived';
    }
  }

  static PenaltyStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'unpaid':
        return PenaltyStatus.unpaid;
      case 'partially_paid':
        return PenaltyStatus.partiallyPaid;
      case 'paid':
        return PenaltyStatus.paid;
      case 'waived':
        return PenaltyStatus.waived;
      default:
        return PenaltyStatus.unpaid;
    }
  }

  bool get isUnpaid => this == PenaltyStatus.unpaid;
  bool get isPartiallyPaid => this == PenaltyStatus.partiallyPaid;
  bool get isPaid => this == PenaltyStatus.paid;
  bool get isWaived => this == PenaltyStatus.waived;
  bool get hasOutstandingBalance => this == PenaltyStatus.unpaid || this == PenaltyStatus.partiallyPaid;
}
