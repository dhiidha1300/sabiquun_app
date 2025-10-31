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
      backgroundColor: const Color(0xFFF5F6FA),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.user.initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification bell
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Navigate to notifications
                },
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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
            icon: Icons.settings,
            title: 'System Settings',
            subtitle: 'Configure app',
            color: Colors.purple,
            route: '/admin/system-settings',
          ),
          _QuickAction(
            icon: Icons.event_busy,
            title: 'Excuses',
            subtitle: 'Review requests',
            color: Colors.orange,
            route: '/excuse-management',
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
            childAspectRatio: 1.1,
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
              const SizedBox(height: 12),
              _buildUserMetrics(analytics.userMetrics),
              const SizedBox(height: 20),

              // Deed Metrics Section
              _buildSectionTitle('Deed Performance', Icons.assignment_turned_in),
              const SizedBox(height: 12),
              _buildDeedMetrics(analytics.deedMetrics),
              const SizedBox(height: 20),

              // Financial Metrics Section
              _buildSectionTitle('Financial Overview', Icons.account_balance_wallet),
              const SizedBox(height: 12),
              _buildFinancialMetrics(analytics.financialMetrics),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Active',
                value: userMetrics.activeUsers.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
            const SizedBox(width: 12),
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
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Compliance',
                value: '${(deedMetrics.complianceRateToday * 100).toStringAsFixed(1)}%',
                subtitle: 'Today',
                icon: Icons.check_circle_outline,
                color: Colors.green,
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
            const SizedBox(width: 12),
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
        const SizedBox(height: 12),
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
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'This Month',
                value: _formatCurrency(financialMetrics.paymentsReceivedThisMonth),
                subtitle: 'Payments',
                icon: Icons.trending_down,
                color: Colors.green,
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
