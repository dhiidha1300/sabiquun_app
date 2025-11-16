import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/analytics_metric_card.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    context.read<AdminBloc>().add(LoadAnalyticsRequested(
          startDate: _startDate,
          endDate: _endDate,
        ));
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAnalytics();
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          if (_startDate != null || _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateRange,
              tooltip: 'Clear date filter',
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Select date range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading analytics',
                    style: Theme.of(context).textTheme.titleLarge,
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
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadAnalytics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AnalyticsLoaded) {
            final analytics = state.analytics;

            return RefreshIndicator(
              onRefresh: () async => _loadAnalytics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range Display
                    if (_startDate != null || _endDate != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Filtered: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_startDate != null || _endDate != null)
                      const SizedBox(height: 16),

                    // User Metrics Section
                    _buildSectionTitle(context, 'User Metrics', Icons.people),
                    const SizedBox(height: 12),
                    _buildUserMetrics(context, analytics.userMetrics),
                    const SizedBox(height: 24),

                    // Deed Metrics Section
                    _buildSectionTitle(context, 'Deed Metrics', Icons.assignment_turned_in),
                    const SizedBox(height: 12),
                    _buildDeedMetrics(context, analytics.deedMetrics),
                    const SizedBox(height: 24),

                    // Financial Metrics Section
                    _buildSectionTitle(context, 'Financial Overview', Icons.account_balance_wallet),
                    const SizedBox(height: 12),
                    _buildFinancialMetrics(context, analytics.financialMetrics),
                    const SizedBox(height: 24),

                    // Engagement Metrics Section
                    _buildSectionTitle(context, 'Engagement', Icons.trending_up),
                    const SizedBox(height: 12),
                    _buildEngagementMetrics(context, analytics.engagementMetrics),
                    const SizedBox(height: 24),

                    // Excuse Metrics Section
                    _buildSectionTitle(context, 'Excuse Requests', Icons.event_busy),
                    const SizedBox(height: 12),
                    _buildExcuseMetrics(context, analytics.excuseMetrics),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildUserMetrics(BuildContext context, userMetrics) {
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
                title: 'Suspended',
                value: userMetrics.suspendedUsers.toString(),
                icon: Icons.block,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Deactivated',
                value: userMetrics.deactivatedUsers.toString(),
                icon: Icons.cancel,
                color: Colors.grey,
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

  Widget _buildDeedMetrics(BuildContext context, deedMetrics) {
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
                title: 'This Week',
                value: deedMetrics.totalDeedsWeek.toString(),
                subtitle: 'Avg: ${deedMetrics.averagePerUserWeek.toStringAsFixed(1)}',
                icon: Icons.date_range,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Compliance Today',
                value: '${(deedMetrics.complianceRateToday * 100).toStringAsFixed(1)}%',
                subtitle: '${deedMetrics.usersCompletedToday}/${deedMetrics.totalActiveUsers} users',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Faraid',
                value: '${(deedMetrics.faraidComplianceRate * 100).toStringAsFixed(1)}%',
                subtitle: 'Compliance',
                icon: Icons.stars,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialMetrics(BuildContext context, financialMetrics) {
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
                title: 'Pending Payments',
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

  Widget _buildEngagementMetrics(BuildContext context, engagementMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Daily Active',
                value: engagementMetrics.dailyActiveUsers.toString(),
                subtitle: '${((engagementMetrics.dailyActiveUsers / engagementMetrics.totalActiveUsers) * 100).toStringAsFixed(0)}% of total',
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Submission Rate',
                value: '${(engagementMetrics.reportSubmissionRate * 100).toStringAsFixed(0)}%',
                subtitle: 'Avg time: ${engagementMetrics.averageSubmissionTime}',
                icon: Icons.send,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExcuseMetrics(BuildContext context, excuseMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Pending',
                value: excuseMetrics.pendingExcuses.toString(),
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Approval Rate',
                value: '${(excuseMetrics.approvalRate * 100).toStringAsFixed(0)}%',
                icon: Icons.check,
                color: Colors.green,
              ),
            ),
          ],
        ),
        if (excuseMetrics.mostCommonReason != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Common Reason',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${excuseMetrics.mostCommonReason} (${excuseMetrics.mostCommonReasonCount} requests)',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'All time';
    return '${date.day}/${date.month}/${date.year}';
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
