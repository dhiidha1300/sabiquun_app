import 'package:sabiquun_app/core/constants/user_role.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';

/// Service for checking user permissions based on roles
class PermissionService {
  final UserEntity? currentUser;

  PermissionService(this.currentUser);

  UserRole? get currentRole => currentUser?.role;

  // =====================
  // Report Permissions
  // =====================

  bool canSubmitReport() => currentUser != null;

  bool canViewOwnReports() => currentUser != null;

  bool canViewAllReports() {
    return currentRole == UserRole.supervisor || currentRole == UserRole.admin;
  }

  bool canEditSubmittedReport() {
    return currentRole == UserRole.admin;
  }

  bool canDeleteReport() {
    return currentRole == UserRole.admin;
  }

  // =====================
  // Excuse Permissions
  // =====================

  bool canSubmitExcuse() => currentUser != null;

  bool canViewOwnExcuses() => currentUser != null;

  bool canApproveExcuse() {
    return currentRole == UserRole.supervisor || currentRole == UserRole.admin;
  }

  bool canRejectExcuse() {
    return currentRole == UserRole.supervisor || currentRole == UserRole.admin;
  }

  // =====================
  // Payment Permissions
  // =====================

  bool canSubmitPayment() => currentUser != null;

  bool canViewOwnPayments() => currentUser != null;

  bool canViewAllPayments() {
    return currentRole == UserRole.cashier || currentRole == UserRole.admin;
  }

  bool canApprovePayment() {
    return currentRole == UserRole.cashier || currentRole == UserRole.admin;
  }

  bool canRejectPayment() {
    return currentRole == UserRole.cashier || currentRole == UserRole.admin;
  }

  // =====================
  // Penalty Permissions
  // =====================

  bool canViewOwnPenalties() => currentUser != null;

  bool canViewAllPenalties() {
    return currentRole == UserRole.cashier || currentRole == UserRole.admin;
  }

  bool canAdjustPenalties() {
    return currentRole == UserRole.cashier || currentRole == UserRole.admin;
  }

  bool canWaivePenalties() {
    return currentRole == UserRole.admin;
  }

  // =====================
  // User Management Permissions
  // =====================

  bool canApproveUsers() {
    return currentRole == UserRole.admin;
  }

  bool canSuspendUsers() {
    return currentRole == UserRole.admin;
  }

  bool canChangeUserRoles() {
    return currentRole == UserRole.admin;
  }

  bool canDeleteUsers() {
    return currentRole == UserRole.admin;
  }

  bool canViewUserList() {
    return currentRole == UserRole.supervisor ||
        currentRole == UserRole.cashier ||
        currentRole == UserRole.admin;
  }

  // =====================
  // Analytics Permissions
  // =====================

  bool canViewOwnAnalytics() => currentUser != null;

  bool canViewUserAnalytics() {
    return currentRole == UserRole.supervisor || currentRole == UserRole.admin;
  }

  bool canViewFinancialAnalytics() {
    return currentRole == UserRole.cashier || currentRole == UserRole.admin;
  }

  bool canViewSystemAnalytics() {
    return currentRole == UserRole.supervisor ||
        currentRole == UserRole.cashier ||
        currentRole == UserRole.admin;
  }

  // =====================
  // Leaderboard Permissions
  // =====================

  bool canViewLeaderboard() => currentUser != null;

  bool canManageTags() {
    return currentRole == UserRole.supervisor || currentRole == UserRole.admin;
  }

  bool canAssignSpecialTags() {
    return currentRole == UserRole.supervisor || currentRole == UserRole.admin;
  }

  // =====================
  // System Settings Permissions
  // =====================

  bool canConfigureDeedTemplates() {
    return currentRole == UserRole.admin;
  }

  bool canConfigurePenalties() {
    return currentRole == UserRole.admin;
  }

  bool canConfigureNotifications() {
    return currentRole == UserRole.admin;
  }

  bool canManageRestDays() {
    return currentRole == UserRole.admin;
  }

  bool canManagePaymentMethods() {
    return currentRole == UserRole.admin;
  }

  bool canConfigureSystemSettings() {
    return currentRole == UserRole.admin;
  }

  // =====================
  // Notification Permissions
  // =====================

  bool canSendManualNotifications() {
    return currentRole == UserRole.supervisor || currentRole == UserRole.admin;
  }

  bool canSendSystemAnnouncements() {
    return currentRole == UserRole.admin;
  }

  // =====================
  // Audit & Logs Permissions
  // =====================

  bool canViewAuditLogs() {
    return currentRole == UserRole.admin;
  }

  bool canViewPaymentLogs() {
    return currentRole == UserRole.cashier || currentRole == UserRole.admin;
  }

  // =====================
  // Content Management Permissions
  // =====================

  bool canEditAppContent() {
    return currentRole == UserRole.admin;
  }

  bool canManageAnnouncements() {
    return currentRole == UserRole.admin;
  }

  // =====================
  // Role-Based Checks
  // =====================

  bool isAdmin() {
    return currentRole == UserRole.admin;
  }

  bool isSupervisor() {
    return currentRole == UserRole.supervisor;
  }

  bool isCashier() {
    return currentRole == UserRole.cashier;
  }

  bool isNormalUser() {
    return currentRole == UserRole.user;
  }

  bool hasElevatedPrivileges() {
    return currentRole != null && currentRole!.isElevated;
  }

  // =====================
  // Utility Methods
  // =====================

  /// Check if user has at least one of the specified roles
  bool hasAnyRole(List<UserRole> roles) {
    if (currentRole == null) return false;
    return roles.contains(currentRole);
  }

  /// Check if user can access a specific feature
  bool canAccessFeature(String feature) {
    switch (feature) {
      case 'reports':
        return canViewOwnReports();
      case 'all_reports':
        return canViewAllReports();
      case 'payments':
        return canViewOwnPayments();
      case 'all_payments':
        return canViewAllPayments();
      case 'excuses':
        return canSubmitExcuse();
      case 'approve_excuses':
        return canApproveExcuse();
      case 'user_management':
        return canApproveUsers();
      case 'system_settings':
        return canConfigureSystemSettings();
      case 'analytics':
        return canViewOwnAnalytics();
      case 'leaderboard':
        return canViewLeaderboard();
      default:
        return false;
    }
  }
}
