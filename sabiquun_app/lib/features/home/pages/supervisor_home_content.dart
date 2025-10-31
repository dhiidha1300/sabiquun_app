import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/home/widgets/enhanced_feature_card.dart';
import 'package:sabiquun_app/features/home/widgets/collapsible_deed_tracker.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_state.dart';

/// Supervisor Home Content - Deed Analytics and User Tracking Dashboard
class SupervisorHomeContent extends StatefulWidget {
  final UserEntity user;

  const SupervisorHomeContent({
    super.key,
    required this.user,
  });

  @override
  State<SupervisorHomeContent> createState() => _SupervisorHomeContentState();
}

class _SupervisorHomeContentState extends State<SupervisorHomeContent> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load analytics for supervisor view
    context.read<AdminBloc>().add(const LoadAnalyticsRequested());

    // Load all reports for today
    context.read<DeedBloc>().add(LoadAllReportsRequested(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    ));
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

                      // Deed Analytics Overview
                      _buildDeedAnalyticsSection(),
                      const SizedBox(height: 20),

                      // User Overview Section
                      _buildUserOverviewSection(),
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
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Supervisor',
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
        int pendingExcuses = 0;
        int usersAtRisk = 0;

        if (state is AnalyticsLoaded) {
          pendingExcuses = state.analytics.excuseMetrics.pendingExcuses;
          usersAtRisk = state.analytics.userMetrics.usersAtRisk;
        }

        final actions = [
          _QuickAction(
            icon: Icons.people_outline,
            title: 'All Users',
            subtitle: 'View reports',
            color: Colors.blue,
            route: '/user-reports',
          ),
          _QuickAction(
            icon: Icons.event_busy,
            title: 'Pending Excuses',
            subtitle: 'Review requests',
            color: Colors.orange,
            route: '/excuse-management',
            badgeCount: pendingExcuses,
            hasUrgentItem: pendingExcuses > 5,
          ),
          _QuickAction(
            icon: Icons.leaderboard,
            title: 'Leaderboard',
            subtitle: 'Manage rankings',
            color: Colors.purple,
            route: '/leaderboard',
          ),
          _QuickAction(
            icon: Icons.warning_amber,
            title: 'Users at Risk',
            subtitle: 'High balance',
            color: Colors.red,
            route: '/users-at-risk',
            badgeCount: usersAtRisk,
            hasUrgentItem: usersAtRisk > 3,
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

  Widget _buildDeedAnalyticsSection() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AnalyticsLoaded) {
          final deedMetrics = state.analytics.deedMetrics;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Deed Performance', Icons.assignment_turned_in),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Today's Compliance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Today\'s Compliance',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(deedMetrics.complianceRateToday * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            Text(
                              '${deedMetrics.usersCompletedToday}/${deedMetrics.totalActiveUsers} users',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: Color(0xFF1976D2),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.blue.shade300, thickness: 1),
                    const SizedBox(height: 16),

                    // Average Deeds
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricItem(
                          'Avg Today',
                          '${deedMetrics.averagePerUserToday.toStringAsFixed(1)}/10',
                          Icons.today,
                        ),
                        _buildMetricItem(
                          'Avg This Week',
                          '${deedMetrics.averagePerUserWeek.toStringAsFixed(1)}/10',
                          Icons.date_range,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Faraid Compliance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricItem(
                          'Faraid',
                          '${(deedMetrics.faraidComplianceRate * 100).toStringAsFixed(0)}%',
                          Icons.stars,
                        ),
                        _buildMetricItem(
                          'Total Today',
                          deedMetrics.totalDeedsToday.toString(),
                          Icons.check_circle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1976D2)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1565C0),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserOverviewSection() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AnalyticsLoaded) {
          final userMetrics = state.analytics.userMetrics;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('User Overview', Icons.people),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildUserMetricCard(
                      'Active Users',
                      userMetrics.activeUsers.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUserMetricCard(
                      'At Risk',
                      userMetrics.usersAtRisk.toString(),
                      Icons.warning,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildUserMetricCard(
                      'Pending',
                      userMetrics.pendingUsers.toString(),
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUserMetricCard(
                      'New This Week',
                      userMetrics.newRegistrationsThisWeek.toString(),
                      Icons.person_add,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUserMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
