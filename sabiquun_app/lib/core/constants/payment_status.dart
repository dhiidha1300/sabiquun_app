enum PaymentStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.approved:
        return 'Approved';
      case PaymentStatus.rejected:
        return 'Rejected';
    }
  }

  String get databaseValue {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.approved:
        return 'approved';
      case PaymentStatus.rejected:
        return 'rejected';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'approved':
        return PaymentStatus.approved;
      case 'rejected':
        return PaymentStatus.rejected;
      default:
        return PaymentStatus.pending;
    }
  }

  bool get isPending => this == PaymentStatus.pending;
  bool get isApproved => this == PaymentStatus.approved;
  bool get isRejected => this == PaymentStatus.rejected;
}
