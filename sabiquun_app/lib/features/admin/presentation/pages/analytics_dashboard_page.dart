import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/analytics_metric_card.dart';
import '../../data/services/analytics_export_service.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedView = 'overview'; // overview, users, deeds, financial

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
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

  void _exportData() async {
    final state = context.read<AdminBloc>().state;
    if (state is! AnalyticsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    // Show export options
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as Excel'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
          ],
        ),
      ),
    );

    if (format == null || !mounted) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating export...')),
    );

    try {
      if (format == 'pdf') {
        await AnalyticsExportService.exportToPdf(
          analytics: state.analytics,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else if (format == 'excel') {
        await AnalyticsExportService.exportToExcel(
          analytics: state.analytics,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
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
      body: Column(
        children: [
          // View selector
          Container(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildViewChip('Overview', 'overview', Icons.dashboard),
                  const SizedBox(width: 8),
                  _buildViewChip('Users', 'users', Icons.people),
                  const SizedBox(width: 8),
                  _buildViewChip('Deeds', 'deeds', Icons.assignment_turned_in),
                  const SizedBox(width: 8),
                  _buildViewChip('Financial', 'financial', Icons.account_balance_wallet),
                  const SizedBox(width: 8),
                  _buildViewChip('Engagement', 'engagement', Icons.trending_up),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AdminError) {
                  return _buildErrorState(state.message);
                }

                if (state is AnalyticsLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async => _loadAnalytics(),
                    child: _buildContent(state),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewChip(String label, String value, IconData icon) {
    final isSelected = _selectedView == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() => _selectedView = value);
      },
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildContent(AnalyticsLoaded state) {
    final analytics = state.analytics;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Display
          if (_startDate != null || _endDate != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.date_range,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Period: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_startDate != null || _endDate != null)
            const SizedBox(height: 16),

          // Content based on selected view
          if (_selectedView == 'overview') ...[
            _buildOverviewSection(analytics),
          ] else if (_selectedView == 'users') ...[
            _buildUserMetricsSection(analytics.userMetrics),
          ] else if (_selectedView == 'deeds') ...[
            _buildDeedMetricsSection(analytics.deedMetrics),
          ] else if (_selectedView == 'financial') ...[
            _buildFinancialMetricsSection(analytics.financialMetrics),
          ] else if (_selectedView == 'engagement') ...[
            _buildEngagementSection(analytics.engagementMetrics, analytics.excuseMetrics),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewSection(dynamic analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Overview', Icons.dashboard),
        const SizedBox(height: 16),

        // Key metrics grid - increased aspect ratio to prevent overflow
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _buildHighlightCard(
              'Active Users',
              analytics.userMetrics.activeUsers.toString(),
              Icons.people,
              Colors.green,
            ),
            _buildHighlightCard(
              'Pending',
              analytics.userMetrics.pendingUsers.toString(),
              Icons.hourglass_empty,
              Colors.orange,
            ),
            _buildHighlightCard(
              'Compliance',
              '${(analytics.deedMetrics.complianceRateToday * 100).toStringAsFixed(0)}%',
              Icons.check_circle,
              Colors.blue,
            ),
            _buildHighlightCard(
              'Outstanding',
              _formatCurrency(analytics.financialMetrics.outstandingBalance),
              Icons.account_balance,
              Colors.red,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _buildUserMetricsSection(analytics.userMetrics),
        const SizedBox(height: 24),
        _buildDeedMetricsSection(analytics.deedMetrics),
        const SizedBox(height: 24),
        _buildFinancialMetricsSection(analytics.financialMetrics),
        const SizedBox(height: 24),
        _buildEngagementSection(analytics.engagementMetrics, analytics.excuseMetrics),
      ],
    );
  }

  Widget _buildHighlightCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      letterSpacing: 0.1,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.08),
            Theme.of(context).primaryColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMetricsSection(dynamic userMetrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('User Metrics', Icons.people),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            AnalyticsMetricCard(
              title: 'Pending',
              value: userMetrics.pendingUsers.toString(),
              icon: Icons.hourglass_empty,
              color: Colors.orange,
            ),
            AnalyticsMetricCard(
              title: 'Active',
              value: userMetrics.activeUsers.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            AnalyticsMetricCard(
              title: 'Suspended',
              value: userMetrics.suspendedUsers.toString(),
              icon: Icons.block,
              color: Colors.red,
            ),
            AnalyticsMetricCard(
              title: 'Deactivated',
              value: userMetrics.deactivatedUsers.toString(),
              icon: Icons.cancel,
              color: Colors.grey,
            ),
            AnalyticsMetricCard(
              title: 'At Risk',
              value: userMetrics.usersAtRisk.toString(),
              subtitle: 'Balance > 400k',
              icon: Icons.warning,
              color: Colors.deepOrange,
            ),
            AnalyticsMetricCard(
              title: 'New This Week',
              value: userMetrics.newRegistrationsThisWeek.toString(),
              icon: Icons.person_add,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeedMetricsSection(dynamic deedMetrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Deed Performance', Icons.assignment_turned_in),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            AnalyticsMetricCard(
              title: 'Today',
              value: deedMetrics.totalDeedsToday.toString(),
              subtitle: 'Avg: ${deedMetrics.averagePerUserToday.toStringAsFixed(1)}',
              icon: Icons.today,
              color: Colors.blue,
            ),
            AnalyticsMetricCard(
              title: 'This Week',
              value: deedMetrics.totalDeedsWeek.toString(),
              subtitle: 'Avg: ${deedMetrics.averagePerUserWeek.toStringAsFixed(1)}',
              icon: Icons.date_range,
              color: Colors.indigo,
            ),
            AnalyticsMetricCard(
              title: 'Compliance Today',
              value: '${(deedMetrics.complianceRateToday * 100).toStringAsFixed(1)}%',
              subtitle: '${deedMetrics.usersCompletedToday}/${deedMetrics.totalActiveUsers} users',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            AnalyticsMetricCard(
              title: 'Faraid',
              value: '${(deedMetrics.faraidComplianceRate * 100).toStringAsFixed(1)}%',
              subtitle: 'Compliance',
              icon: Icons.stars,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialMetricsSection(dynamic financialMetrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Financial Overview', Icons.account_balance_wallet),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            AnalyticsMetricCard(
              title: 'Outstanding',
              value: _formatCurrency(financialMetrics.outstandingBalance),
              icon: Icons.account_balance,
              color: Colors.red,
            ),
            AnalyticsMetricCard(
              title: 'Pending Payments',
              value: financialMetrics.pendingPaymentsCount.toString(),
              subtitle: _formatCurrency(financialMetrics.pendingPaymentsAmount),
              icon: Icons.pending,
              color: Colors.orange,
            ),
            AnalyticsMetricCard(
              title: 'This Month',
              value: _formatCurrency(financialMetrics.penaltiesIncurredThisMonth),
              subtitle: 'Penalties',
              icon: Icons.trending_up,
              color: Colors.deepOrange,
            ),
            AnalyticsMetricCard(
              title: 'This Month',
              value: _formatCurrency(financialMetrics.paymentsReceivedThisMonth),
              subtitle: 'Payments',
              icon: Icons.trending_down,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEngagementSection(dynamic engagementMetrics, dynamic excuseMetrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Engagement & Excuses', Icons.trending_up),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            AnalyticsMetricCard(
              title: 'Daily Active',
              value: engagementMetrics.dailyActiveUsers.toString(),
              subtitle: '${((engagementMetrics.dailyActiveUsers / engagementMetrics.totalActiveUsers) * 100).toStringAsFixed(0)}% of total',
              icon: Icons.people,
              color: Colors.blue,
            ),
            AnalyticsMetricCard(
              title: 'Submission Rate',
              value: '${(engagementMetrics.reportSubmissionRate * 100).toStringAsFixed(0)}%',
              subtitle: 'Time: ${engagementMetrics.averageSubmissionTime}',
              icon: Icons.send,
              color: Colors.green,
            ),
            AnalyticsMetricCard(
              title: 'Pending Excuses',
              value: excuseMetrics.pendingExcuses.toString(),
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
            AnalyticsMetricCard(
              title: 'Approval Rate',
              value: '${(excuseMetrics.approvalRate * 100).toStringAsFixed(0)}%',
              icon: Icons.check,
              color: Colors.green,
            ),
          ],
        ),
        if (excuseMetrics.mostCommonReason != null) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            shadowColor: Colors.blue.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.05),
                    Colors.blue.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.blue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Common Excuse',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${excuseMetrics.mostCommonReason} (${excuseMetrics.mostCommonReasonCount})',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildErrorState(String message) {
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
              message,
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
