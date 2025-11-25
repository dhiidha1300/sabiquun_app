import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_state.dart';
import 'package:sabiquun_app/features/admin/presentation/widgets/analytics_metric_card.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/home/widgets/collapsible_deed_tracker.dart';
import 'package:sabiquun_app/features/home/widgets/admin_menu_grid.dart';
import 'package:sabiquun_app/features/home/widgets/admin_menu_button.dart';
import 'package:sabiquun_app/features/notifications/presentation/widgets/notification_bell.dart';

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

class _AdminHomeContentState extends State<AdminHomeContent> with RouteAware {
  final GlobalKey<AdminMenuGridState> _menuKey = GlobalKey<AdminMenuGridState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load data on initial mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _isInitialized = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when coming back from another route, but not on initial build
    if (_isInitialized && ModalRoute.of(context)?.isCurrent == true) {
      _loadData();
    }
  }

  void _loadData() {
    if (mounted) {
      context.read<AdminBloc>().add(const LoadAnalyticsRequested());
    }
  }

  Future<void> _onRefresh() async {
    _loadData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          SafeArea(
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

          // Sidebar Drawer Overlay (full screen)
          AdminMenuGrid(key: _menuKey),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Row(
        children: [
          // Menu button integrated in header
          AdminMenuButton(
            onPressed: () {
              _menuKey.currentState?.toggleDrawer();
            },
          ),
          const SizedBox(width: 16),

          // Welcome text with user greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      widget.user.fullName.split(' ').first,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.2),
                            AppColors.accentDark.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield,
                            size: 12,
                            color: AppColors.accentDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: AppColors.accentDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Modern notification bell with badge
          NotificationBell(userId: widget.user.id),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        _buildModernQuickActions(),
      ],
    );
  }

  Widget _buildModernQuickActions() {
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
          _QuickAction(
            icon: Icons.calendar_today,
            title: 'Rest Days',
            subtitle: 'Manage rest days',
            color: Colors.amber,
            route: '/admin/rest-days',
          ),
          _QuickAction(
            icon: Icons.analytics,
            title: 'Analytics',
            subtitle: 'View reports',
            color: Colors.indigo,
            route: '/admin/analytics',
          ),
        ];

        return Column(
          children: actions.map((action) => _buildModernActionItem(action)).toList(),
        );
      },
    );
  }

  Widget _buildModernActionItem(_QuickAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(action.route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: action.color.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon with colored background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.color.withValues(alpha: 0.15),
                        action.color.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (action.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          action.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Badge or arrow
                if (action.badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: action.hasUrgentItem
                            ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
                            : [action.color, action.color.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (action.hasUrgentItem ? AppColors.error : action.color)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      action.badgeCount > 99 ? '99+' : '${action.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
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
