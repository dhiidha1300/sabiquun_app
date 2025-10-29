import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';

/// Enhanced Profile Menu with additional information
class EnhancedProfileMenu extends StatelessWidget {
  final UserEntity user;
  final double penaltyBalance;
  final int profileCompletionPercentage;
  final int unreadNotifications;

  const EnhancedProfileMenu({
    super.key,
    required this.user,
    required this.penaltyBalance,
    this.profileCompletionPercentage = 100,
    this.unreadNotifications = 0,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.white,
            child: Text(
              user.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Notification badge
          if (unreadNotifications > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadNotifications > 9 ? '9+' : '$unreadNotifications',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      offset: const Offset(0, 56),
      itemBuilder: (context) => [
        // User Info Header
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(user.role.displayName),
                backgroundColor: _getRoleColor(user),
                labelStyle: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              // Profile Completion Progress
              if (profileCompletionPercentage < 100) ...[
                Text(
                  'Profile $profileCompletionPercentage% complete',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: profileCompletionPercentage / 100,
                  backgroundColor: AppColors.greyLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ],
            ],
          ),
        ),
        const PopupMenuDivider(),

        // Notifications
        PopupMenuItem(
          value: 'notifications',
          child: ListTile(
            leading: Stack(
              children: [
                const Icon(Icons.notifications),
                if (unreadNotifications > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              unreadNotifications > 0
                  ? 'Notifications ($unreadNotifications new)'
                  : 'Notifications',
            ),
            subtitle: unreadNotifications > 0
                ? const Text(
                    'Coming Soon',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  )
                : null,
            contentPadding: EdgeInsets.zero,
          ),
        ),

        // Penalty Balance
        PopupMenuItem(
          value: 'penalty_balance',
          child: ListTile(
            leading: Icon(
              Icons.account_balance_wallet,
              color: _getBalanceColor(penaltyBalance),
            ),
            title: const Text('Penalty Balance'),
            subtitle: Text(
              '${NumberFormat('#,###').format(penaltyBalance)} Shillings',
              style: TextStyle(
                color: _getBalanceColor(penaltyBalance),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),

        // Penalty History
        PopupMenuItem(
          value: 'penalty_history',
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('View Penalty History'),
            contentPadding: EdgeInsets.zero,
          ),
        ),

        const PopupMenuDivider(),

        // Profile
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            contentPadding: EdgeInsets.zero,
          ),
        ),

        // Settings
        const PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            contentPadding: EdgeInsets.zero,
          ),
        ),

        const PopupMenuDivider(),

        // Logout
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text('Logout', style: TextStyle(color: AppColors.error)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'notifications':
            // TODO: Navigate to notifications page (placeholder for now)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications feature coming soon')),
            );
            break;
          case 'penalty_balance':
          case 'penalty_history':
            context.push('/penalty-history', extra: user.id);
            break;
          case 'profile':
            // TODO: Navigate to profile page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile feature coming soon')),
            );
            break;
          case 'settings':
            // TODO: Navigate to settings page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings feature coming soon')),
            );
            break;
          case 'logout':
            context.read<AuthBloc>().add(const LogoutRequested());
            break;
        }
      },
    );
  }

  Color _getRoleColor(UserEntity user) {
    if (user.isAdmin) return AppColors.adminColor;
    if (user.isSupervisor) return AppColors.supervisorColor;
    if (user.isCashier) return AppColors.cashierColor;
    return AppColors.userColor;
  }

  Color _getBalanceColor(double balance) {
    if (balance == 0) return AppColors.success;
    if (balance < 100000) return AppColors.success;
    if (balance < 300000) return AppColors.warning;
    return AppColors.error;
  }
}
