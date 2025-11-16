import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:sabiquun_app/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:sabiquun_app/features/analytics/presentation/bloc/analytics_state.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<AnalyticsBloc>().add(LoadAllAnalyticsRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnalyticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load analytics',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadAnalytics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AllAnalyticsLoaded) {
            final stats = state.stats;
            final monthlyReports = state.monthlyReports;
            final deedPerformance = state.deedPerformance;

            return RefreshIndicator(
              onRefresh: () async => _loadAnalytics(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Overview Cards
                    _buildOverviewCards(stats),
                    const SizedBox(height: 24),

                    // Monthly Performance Chart
                    _buildMonthlyPerformanceCard(monthlyReports),
                    const SizedBox(height: 24),

                    // Deed Performance
                    _buildDeedPerformanceCard(deedPerformance),
                    const SizedBox(height: 24),

                    // Additional Stats
                    _buildAdditionalStatsCard(stats),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No analytics data available',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadAnalytics,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(state) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Reports',
            value: '${state.totalReportsSubmitted}',
            icon: Icons.assignment,
            color: AppColors.primary,
            subtitle: 'All time',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Current Streak',
            value: '${state.currentStreak}',
            icon: Icons.local_fire_department,
            color: AppColors.warning,
            subtitle: 'days',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'This Month',
            value: '${state.thisMonthReports}',
            icon: Icons.calendar_today,
            color: AppColors.success,
            subtitle: 'reports',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyPerformanceCard(List monthlyReports) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.show_chart, color: AppColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: monthlyReports.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: monthlyReports.length,
                      itemBuilder: (context, index) {
                        final report = monthlyReports[monthlyReports.length - 1 - index];
                        final height = (report.completionRate / 100 * 150).clamp(20.0, 150.0);

                        return Container(
                          width: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${report.completionRate.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 40,
                                height: height,
                                decoration: BoxDecoration(
                                  color: _getPerformanceColor(report.completionRate),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                report.monthName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedPerformanceCard(List deedPerformance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deed Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            if (deedPerformance.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No deed data available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ...deedPerformance.map((deed) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            deed.deedName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${deed.completionRate.toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getPerformanceColor(deed.completionRate),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: deed.completionRate / 100,
                          backgroundColor: Colors.grey[200],
                          color: _getPerformanceColor(deed.completionRate),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${deed.totalSubmitted} completed • ${deed.totalMissed} missed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStatsCard(state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              icon: Icons.trending_up,
              label: 'Longest Streak',
              value: '${state.longestStreak} days',
              color: AppColors.primary,
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.calendar_month,
              label: 'This Year',
              value: '${state.thisYearReports} reports',
              color: AppColors.success,
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.percent,
              label: 'Completion Rate',
              value: '${state.completionRate.toStringAsFixed(1)}%',
              color: _getPerformanceColor(state.completionRate),
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.event_busy,
              label: 'Total Excuses',
              value: '${state.totalExcuses}',
              color: AppColors.warning,
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.check_circle,
              label: 'Approved Excuses',
              value: '${state.approvedExcuses}',
              color: AppColors.success,
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.warning,
              label: 'Total Penalties',
              value: '${state.totalPenalties}',
              color: AppColors.error,
            ),
            if (state.totalPenaltyAmount > 0) ...[
              const Divider(height: 24),
              _buildStatRow(
                icon: Icons.attach_money,
                label: 'Penalty Amount',
                value: 'SLSH ${state.totalPenaltyAmount.toStringAsFixed(2)}',
                color: AppColors.error,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor(double rate) {
    if (rate >= 90) return AppColors.success;
    if (rate >= 75) return AppColors.info;
    if (rate >= 50) return AppColors.warning;
    return AppColors.error;
  }
}
