/// Account status for users in the system
enum AccountStatus {
  pending('pending', 'Pending Approval'),
  active('active', 'Active'),
  suspended('suspended', 'Suspended'),
  autoDeactivated('auto_deactivated', 'Auto-Deactivated'),
  deleted('deleted', 'Deleted');

  const AccountStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Convert string to AccountStatus enum
  static AccountStatus fromString(String status) {
    return AccountStatus.values.firstWhere(
      (s) => s.value == status.toLowerCase(),
      orElse: () => AccountStatus.pending,
    );
  }

  /// Check if account can access the app
  bool get canAccessApp {
    return this == AccountStatus.active;
  }

  /// Check if account is awaiting approval
  bool get isPending => this == AccountStatus.pending;

  /// Check if account is active
  bool get isActive => this == AccountStatus.active;

  /// Check if account is suspended
  bool get isSuspended => this == AccountStatus.suspended;

  /// Check if account is auto-deactivated
  bool get isAutoDeactivated => this == AccountStatus.autoDeactivated;

  /// Check if account is deleted
  bool get isDeleted => this == AccountStatus.deleted;
}
