import 'package:equatable/equatable.dart';
import '../../../../core/constants/user_role.dart';
import '../../../../core/constants/account_status.dart';

/// Entity representing a user in the admin management system
/// Extends the basic user data with admin-specific statistics
class UserManagementEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final String membershipStatus; // 'new', 'exclusive', 'legacy'
  final AccountStatus accountStatus;
  final bool excuseMode;
  final DateTime createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime updatedAt;

  // Admin-specific statistics
  final int totalReports;
  final double complianceRate;
  final double currentBalance;
  final DateTime? lastReportDate;

  const UserManagementEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    required this.role,
    required this.membershipStatus,
    required this.accountStatus,
    required this.excuseMode,
    required this.createdAt,
    this.approvedBy,
    this.approvedAt,
    required this.updatedAt,
    this.totalReports = 0,
    this.complianceRate = 0.0,
    this.currentBalance = 0.0,
    this.lastReportDate,
  });

  /// Check if user is pending approval
  bool get isPending => accountStatus == AccountStatus.pending;

  /// Check if user is active
  bool get isActive => accountStatus == AccountStatus.active;

  /// Check if user is suspended
  bool get isSuspended => accountStatus == AccountStatus.suspended;

  /// Check if user is in training period (new member)
  bool get isInTrainingPeriod => membershipStatus == 'new';

  /// Get formatted membership status display
  String get membershipStatusDisplay {
    switch (membershipStatus) {
      case 'new':
        return 'New Member';
      case 'exclusive':
        return 'Exclusive';
      case 'legacy':
        return 'Legacy';
      default:
        return membershipStatus;
    }
  }

  /// Get membership badge emoji
  String get membershipBadge {
    switch (membershipStatus) {
      case 'new':
        return '🌱';
      case 'exclusive':
        return '💎';
      case 'legacy':
        return '👑';
      default:
        return '';
    }
  }

  /// Get formatted balance string
  String get formattedBalance => '${currentBalance.toStringAsFixed(0)} Shillings';

  /// Get formatted compliance rate percentage
  String get formattedComplianceRate => '${(complianceRate * 100).toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        photoUrl,
        role,
        membershipStatus,
        accountStatus,
        excuseMode,
        createdAt,
        approvedBy,
        approvedAt,
        updatedAt,
        totalReports,
        complianceRate,
        currentBalance,
        lastReportDate,
      ];
}
