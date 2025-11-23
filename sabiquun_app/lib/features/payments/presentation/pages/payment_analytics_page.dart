import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_state.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_bloc.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_event.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_state.dart';

/// Payment Analytics Page
/// Shows payment trends, statistics, and financial metrics for cashiers
class PaymentAnalyticsPage extends StatefulWidget {
  const PaymentAnalyticsPage({super.key});

  @override
  State<PaymentAnalyticsPage> createState() => _PaymentAnalyticsPageState();
}

class _PaymentAnalyticsPageState extends State<PaymentAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'this_month';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAnalytics() {
    // Load pending payments for "Pending Review" stat
    context.read<PaymentBloc>().add(const LoadPendingPaymentsRequested());

    // Load recent approved payments to calculate stats
    context.read<PaymentBloc>().add(const LoadRecentApprovedPaymentsRequested(limit: 100));

    // Load total outstanding balance
    context.read<PenaltyBloc>().add(const LoadTotalOutstandingBalanceRequested());
  }

  Future<void> _onRefresh() async {
    _loadAnalytics();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics_outlined),
              text: 'Summary',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'User Balances',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Time Period Selector (moved outside tab view for both tabs)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: _buildPeriodSelector(),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildUserBalancesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildPeriodTab('This Week', 'this_week'),
          _buildPeriodTab('This Month', 'this_month'),
          _buildPeriodTab('Custom', 'custom'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, String value) {
    final isSelected = _selectedPeriod == value;

    return Expanded(
      child: InkWell(
        onTap: () async {
          if (value == 'custom') {
            await _showCustomDatePicker();
          } else {
            setState(() {
              _selectedPeriod = value;
              _customStartDate = null;
              _customEndDate = null;
            });
            _loadAnalytics();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewSection(),
            const SizedBox(height: 24),

            // Payment Method Distribution
            _buildPaymentMethodSection(),
            const SizedBox(height: 24),

            // Outstanding Balances Summary
            _buildOutstandingBalancesSection(),
            const SizedBox(height: 24),

            // Future: Charts section will go here
            _buildPlaceholderChartsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBalancesTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with export buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Balances Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => _exportUserBalances('pdf'),
                      icon: const Icon(Icons.picture_as_pdf, size: 20),
                      tooltip: 'Export as PDF',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _exportUserBalances('excel'),
                      icon: const Icon(Icons.table_chart, size: 20),
                      tooltip: 'Export as Excel',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User balances table
            _buildUserBalancesTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview - ${_selectedPeriod == 'this_week' ? 'This Week' : 'This Month'}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: BlocBuilder<PaymentBloc, PaymentState>(
                buildWhen: (previous, current) => current is PendingPaymentsLoaded,
                builder: (context, state) {
                  int pendingCount = 0;
                  double pendingAmount = 0;

                  if (state is PendingPaymentsLoaded) {
                    pendingCount = state.payments.length;
                    for (var payment in state.payments) {
                      pendingAmount += payment.amount;
                    }
                  }

                  return _buildStatCard(
                    'Pending Review',
                    NumberFormat('#,###').format(pendingAmount),
                    'Sh',
                    '$pendingCount payments',
                    Colors.orange,
                    Icons.pending_actions,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocBuilder<PaymentBloc, PaymentState>(
                buildWhen: (previous, current) => current is RecentApprovedPaymentsLoaded,
                builder: (context, state) {
                  int approvedCount = 0;
                  double approvedAmount = 0;

                  if (state is RecentApprovedPaymentsLoaded) {
                    approvedCount = state.payments.length;
                    for (var payment in state.payments) {
                      approvedAmount += payment.amount;
                    }
                  }

                  return _buildStatCard(
                    'Total Approved',
                    NumberFormat('#,###').format(approvedAmount),
                    'Sh',
                    '$approvedCount payments',
                    Colors.green,
                    Icons.check_circle,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<PaymentBloc, PaymentState>(
          buildWhen: (previous, current) => current is RecentApprovedPaymentsLoaded,
          builder: (context, state) {
            int approvedCount = 0;
            double approvedAmount = 0;
            double averageAmount = 0;

            if (state is RecentApprovedPaymentsLoaded) {
              approvedCount = state.payments.length;
              for (var payment in state.payments) {
                approvedAmount += payment.amount;
              }
              if (approvedCount > 0) {
                averageAmount = approvedAmount / approvedCount;
              }
            }

            return _buildStatCard(
              'Average Payment',
              NumberFormat('#,###').format(averageAmount),
              'Sh',
              approvedCount > 0 ? 'Based on $approvedCount approved payments' : 'No data',
              Colors.blue,
              Icons.trending_up,
              fullWidth: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    String subtitle,
    Color color,
    IconData icon, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: fullWidth ? 28 : 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        Map<String, int> methodCounts = {};
        Map<String, double> methodAmounts = {};

        // Aggregate payment methods from approved payments
        if (state is RecentApprovedPaymentsLoaded) {
          for (var payment in state.payments) {
            final method = payment.paymentMethodName ?? 'Unknown';
            methodCounts[method] = (methodCounts[method] ?? 0) + 1;
            methodAmounts[method] = (methodAmounts[method] ?? 0) + payment.amount;
          }
        }

        if (methodCounts.isEmpty) {
          return _buildEmptyState('No payment method data available');
        }

        final sortedMethods = methodCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: sortedMethods.map((entry) {
                  final method = entry.key;
                  final count = entry.value;
                  final amount = methodAmounts[method] ?? 0;
                  final percentage = (count / sortedMethods.fold(0, (sum, e) => sum + e.value) * 100).toStringAsFixed(1);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getMethodColor(method),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  method,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _getMethodColor(method),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: count / sortedMethods.fold(0, (sum, e) => sum + e.value),
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(_getMethodColor(method)),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$count payments',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(amount)} Sh',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOutstandingBalancesSection() {
    return BlocBuilder<PenaltyBloc, PenaltyState>(
      builder: (context, state) {
        double totalOutstanding = 0;

        if (state is TotalOutstandingBalanceLoaded) {
          totalOutstanding = state.totalBalance;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outstanding Balances',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.error.withValues(alpha: 0.1),
                    AppColors.error.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Total Outstanding',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${NumberFormat('#,###').format(totalOutstanding)} Shillings',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total unpaid penalties across all users',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholderChartsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Charts Coming Soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Payment trends chart and visual analytics will be available in the next update',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'zaad':
        return Colors.blue;
      case 'edahab':
        return Colors.green;
      case 'cash':
        return Colors.orange;
      case 'bank transfer':
      case 'bank':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildUserBalancesTable() {
    return BlocBuilder<PenaltyBloc, PenaltyState>(
      builder: (context, state) {
        // This is a placeholder - in a real implementation, you would load
        // all users with their balances from the backend
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'User Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Balance',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table Body - Placeholder
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'User Balances Table',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This feature requires backend support to fetch all user balances for the selected date range. The table will display user names, emails, and their current balances with export functionality.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Date Range: ${_getDateRangeText()}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDateRangeText() {
    if (_selectedPeriod == 'custom' && _customStartDate != null && _customEndDate != null) {
      return '${DateFormat('MMM dd, yyyy').format(_customStartDate!)} - ${DateFormat('MMM dd, yyyy').format(_customEndDate!)}';
    } else if (_selectedPeriod == 'this_week') {
      return 'This Week';
    } else {
      return 'This Month';
    }
  }

  Future<void> _exportUserBalances(String format) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exporting user balances as ${format.toUpperCase()}...',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // TODO: Implement actual export functionality
    // This would typically:
    // 1. Fetch all user balances from backend for the selected date range
    // 2. Generate PDF or Excel file
    // 3. Save/share the file
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export feature coming soon! Will export as ${format.toUpperCase()}',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
