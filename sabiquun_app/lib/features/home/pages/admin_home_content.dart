import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_state.dart';
import 'package:sabiquun_app/features/admin/presentation/widgets/analytics_metric_card.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/home/widgets/enhanced_feature_card.dart';
import 'package:sabiquun_app/features/home/widgets/collapsible_deed_tracker.dart';

/// Admin Home Content - Analytics Dashboard as Default Home
class AdminHomeContent extends StatefulWidget {
  final UserEntity user;

  const AdminHomeContent({
    super.key,
    required this.user,
  });

  @override
  State<AdminHomeContent> createState() => _AdminHomeContentState();
}

class _AdminHomeContentState extends State<AdminHomeContent> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AdminBloc>().add(const LoadAnalyticsRequested());
  }

  Future<void> _onRefresh() async {
    _loadData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header with user profile
                _buildHeader(),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions Grid
                      _buildQuickActionsSection(),
                      const SizedBox(height: 20),

                      // Personal Deed Tracker (Collapsible)
                      const CollapsibleDeedTracker(),
                      const SizedBox(height: 20),

                      // Analytics Dashboard Content
                      _buildAnalyticsDashboard(),
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
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar with modern shadow effect
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.user.initials,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User info with elegant styling
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.15),
                        AppColors.accentDark.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.accentDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Admin',
                        style: TextStyle(
                          color: AppColors.accentDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modern notification bell with badge
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: Navigate to notifications
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildQuickActionsGrid(),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        int pendingUsers = 0;
        int pendingExcuses = 0;
        int pendingPayments = 0;

        if (state is AnalyticsLoaded) {
          pendingUsers = state.analytics.userMetrics.pendingUsers;
          pendingExcuses = state.analytics.excuseMetrics.pendingExcuses;
          pendingPayments = state.analytics.financialMetrics.pendingPaymentsCount;
        }

        final actions = [
          _QuickAction(
            icon: Icons.people_outline,
            title: 'User Management',
            subtitle: 'Manage users',
            color: Colors.blue,
            route: '/admin/user-management',
            badgeCount: pendingUsers,
            hasUrgentItem: pendingUsers > 0,
          ),
          _QuickAction(
            icon: Icons.assignment_turned_in,
            title: 'Deed Management',
            subtitle: 'Manage deeds',
            color: Colors.teal,
            route: '/admin/deed-management',
          ),
          _QuickAction(
            icon: Icons.settings,
            title: 'System Settings',
            subtitle: 'Configure app',
            color: Colors.purple,
            route: '/admin/system-settings',
          ),
          _QuickAction(
            icon: Icons.history,
            title: 'Audit Logs',
            subtitle: 'System activity',
            color: Colors.blueGrey,
            route: '/admin/audit-logs',
          ),
          _QuickAction(
            icon: Icons.analytics,
            title: 'Analytics',
            subtitle: 'View reports',
            color: Colors.indigo,
            route: '/admin/analytics',
          ),
          _QuickAction(
            icon: Icons.event_busy,
            title: 'Excuses',
            subtitle: 'Review requests',
            color: Colors.orange,
            route: '/admin/excuses',
            badgeCount: pendingExcuses,
            hasUrgentItem: pendingExcuses > 5,
          ),
          _QuickAction(
            icon: Icons.account_balance_wallet,
            title: 'Payments',
            subtitle: 'Review payments',
            color: Colors.green,
            route: '/payment-review',
            badgeCount: pendingPayments,
            hasUrgentItem: pendingPayments > 5,
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return EnhancedFeatureCard(
              icon: action.icon,
              title: action.title,
              subtitle: action.subtitle,
              color: action.color,
              badgeCount: action.badgeCount,
              hasUrgentItem: action.hasUrgentItem,
              onTap: () => context.push(action.route),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsDashboard() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading analytics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AnalyticsLoaded) {
          final analytics = state.analytics;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Metrics Section
              _buildSectionTitle('User Overview', Icons.people),
              const SizedBox(height: 16),
              _buildUserMetrics(analytics.userMetrics),
              const SizedBox(height: 24),

              // Deed Metrics Section
              _buildSectionTitle('Deed Performance', Icons.assignment_turned_in),
              const SizedBox(height: 16),
              _buildDeedMetrics(analytics.deedMetrics),
              const SizedBox(height: 24),

              // Financial Metrics Section
              _buildSectionTitle('Financial Overview', Icons.account_balance_wallet),
              const SizedBox(height: 16),
              _buildFinancialMetrics(analytics.financialMetrics),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMetrics(userMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Pending',
                value: userMetrics.pendingUsers.toString(),
                icon: Icons.hourglass_empty,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Active',
                value: userMetrics.activeUsers.toString(),
                icon: Icons.check_circle,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'At Risk',
                value: userMetrics.usersAtRisk.toString(),
                subtitle: 'Balance > 400k',
                icon: Icons.warning,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'New This Week',
                value: userMetrics.newRegistrationsThisWeek.toString(),
                icon: Icons.person_add,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeedMetrics(deedMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Today',
                value: deedMetrics.totalDeedsToday.toString(),
                subtitle: 'Avg: ${deedMetrics.averagePerUserToday.toStringAsFixed(1)}',
                icon: Icons.today,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Compliance',
                value: '${(deedMetrics.complianceRateToday * 100).toStringAsFixed(1)}%',
                subtitle: 'Today',
                icon: Icons.check_circle_outline,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialMetrics(financialMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Outstanding',
                value: _formatCurrency(financialMetrics.outstandingBalance),
                icon: Icons.account_balance,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Pending',
                value: financialMetrics.pendingPaymentsCount.toString(),
                subtitle: _formatCurrency(financialMetrics.pendingPaymentsAmount),
                icon: Icons.pending,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'This Month',
                value: _formatCurrency(financialMetrics.penaltiesIncurredThisMonth),
                subtitle: 'Penalties',
                icon: Icons.trending_up,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'This Month',
                value: _formatCurrency(financialMetrics.paymentsReceivedThisMonth),
                subtitle: 'Payments',
                icon: Icons.trending_down,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

// Helper class for quick actions
class _QuickAction {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final String route;
  final int badgeCount;
  final bool hasUrgentItem;

  const _QuickAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.route,
    this.badgeCount = 0,
    this.hasUrgentItem = false,
  });
}
