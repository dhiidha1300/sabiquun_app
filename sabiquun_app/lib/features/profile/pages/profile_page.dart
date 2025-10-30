import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/home/utils/membership_helper.dart';
import 'package:sabiquun_app/features/home/widgets/main_scaffold.dart';

/// Profile page with user information and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _excuseModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final membershipBadge = MembershipHelper.getBadge(user.createdAt ?? DateTime.now());

        return MainScaffold(
          currentIndex: 3,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: SafeArea(
              child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  _buildHeader(user, membershipBadge),

                  // Profile Information
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Excuse Mode Card
                        _buildExcuseModeCard(),
                        const SizedBox(height: 16),

                        // Account Information Card
                        _buildAccountInfoCard(user),
                        const SizedBox(height: 16),

                        // Settings Options
                        _buildSettingsCard(user),
                        const SizedBox(height: 16),

                        // Logout Button
                        _buildLogoutButton(context),
                        const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserEntity user, MembershipBadge badge) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.fullName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Membership Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badge.color.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badge.icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  badge.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcuseModeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _excuseModeEnabled
                  ? AppColors.warning.withValues(alpha: 0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medical_services,
              color: _excuseModeEnabled ? AppColors.warning : Colors.grey[600],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Excuse Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _excuseModeEnabled
                      ? 'You are currently excused from daily deeds'
                      : 'Enable when you have a valid excuse',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _excuseModeEnabled,
            onChanged: (value) {
              setState(() => _excuseModeEnabled = value);
              // TODO: Save excuse mode to backend
              _showExcuseModeDialog(value);
            },
            activeTrackColor: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(UserEntity user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.badge, 'Full Name', user.fullName),
          const Divider(height: 24),
          _buildInfoRow(Icons.email, 'Email', user.email),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone, 'Phone', user.phoneNumber ?? 'Not provided'),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.admin_panel_settings,
            'Role',
            _getUserRole(user),
          ),
          if (user.createdAt != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Member Since',
              _formatDate(user.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsCard(UserEntity user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              // TODO: Navigate to change password
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help or contact support',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              // TODO: Show about dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUserRole(UserEntity user) {
    if (user.isAdmin) return 'Admin';
    if (user.isSupervisor) return 'Supervisor';
    if (user.isCashier) return 'Cashier';
    return 'Member';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showExcuseModeDialog(bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(enabled ? 'Excuse Mode Enabled' : 'Excuse Mode Disabled'),
        content: Text(
          enabled
              ? 'You are now excused from daily deed submissions. Remember to disable this when your excuse period ends.'
              : 'Excuse mode has been disabled. You will need to submit your daily deeds.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
