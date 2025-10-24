/// User roles in the system with role-based access control
enum UserRole {
  user('user', 'User'),
  supervisor('supervisor', 'Supervisor'),
  cashier('cashier', 'Cashier'),
  admin('admin', 'Admin');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Convert string to UserRole enum
  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.value == role.toLowerCase(),
      orElse: () => UserRole.user,
    );
  }

  /// Check if the role has elevated privileges
  bool get isElevated {
    return this == UserRole.supervisor ||
        this == UserRole.cashier ||
        this == UserRole.admin;
  }

  /// Check if the role is admin
  bool get isAdmin => this == UserRole.admin;

  /// Check if the role is supervisor
  bool get isSupervisor => this == UserRole.supervisor;

  /// Check if the role is cashier
  bool get isCashier => this == UserRole.cashier;

  /// Check if the role is normal user
  bool get isNormalUser => this == UserRole.user;
}
