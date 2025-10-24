import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/shared/services/permission_service.dart';

/// Main home page that adapts based on user role
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          // Should not happen due to auth guard, but handle gracefully
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final permissions = PermissionService(user);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sabiquun'),
            actions: [
              // Profile Menu
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  }
                },
                itemBuilder: (context) => [
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
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(user.role.displayName),
                          backgroundColor: _getRoleColor(user),
                          labelStyle: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: AppColors.error),
                      title: Text('Logout', style: TextStyle(color: AppColors.error)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Role-specific features
                Expanded(
                  child: _buildRoleSpecificContent(user, permissions),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleSpecificContent(UserEntity user, PermissionService permissions) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Common features for all users
        _FeatureCard(
          icon: Icons.library_books,
          title: 'My Reports',
          color: AppColors.primary,
          onTap: () {},
        ),
        _FeatureCard(
          icon: Icons.event_note,
          title: 'Today\'s Deeds',
          color: AppColors.accent,
          onTap: () {},
        ),
        _FeatureCard(
          icon: Icons.payment,
          title: 'Payments',
          color: AppColors.info,
          onTap: () {},
        ),
        _FeatureCard(
          icon: Icons.medical_services,
          title: 'Excuses',
          color: AppColors.warning,
          onTap: () {},
        ),

        // Admin-specific features
        if (permissions.canApproveUsers())
          _FeatureCard(
            icon: Icons.people,
            title: 'User Management',
            color: AppColors.adminColor,
            onTap: () {},
          ),

        // Supervisor features
        if (permissions.canViewAllReports())
          _FeatureCard(
            icon: Icons.assessment,
            title: 'Analytics',
            color: AppColors.supervisorColor,
            onTap: () {},
          ),

        // Cashier features
        if (permissions.canViewAllPayments())
          _FeatureCard(
            icon: Icons.account_balance_wallet,
            title: 'Payment Review',
            color: AppColors.cashierColor,
            onTap: () {},
          ),
      ],
    );
  }

  Color _getRoleColor(UserEntity user) {
    if (user.isAdmin) return AppColors.adminColor;
    if (user.isSupervisor) return AppColors.supervisorColor;
    if (user.isCashier) return AppColors.cashierColor;
    return AppColors.userColor;
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
