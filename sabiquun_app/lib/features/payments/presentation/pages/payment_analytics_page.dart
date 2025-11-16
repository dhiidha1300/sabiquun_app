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

class _PaymentAnalyticsPageState extends State<PaymentAnalyticsPage> {
  String _selectedPeriod = 'this_month';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
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
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Period Selector
              _buildPeriodSelector(),
              const SizedBox(height: 20),

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
        onTap: () {
          if (value == 'custom') {
            // TODO: Show date range picker
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Custom date range coming soon')),
            );
          } else {
            setState(() => _selectedPeriod = value);
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

  Widget _buildOverviewSection() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, paymentState) {
        int pendingCount = 0;
        double pendingAmount = 0;
        int approvedCount = 0;
        double approvedAmount = 0;
        double averageAmount = 0;

        // Calculate pending stats
        if (paymentState is PendingPaymentsLoaded) {
          pendingCount = paymentState.payments.length;
          for (var payment in paymentState.payments) {
            pendingAmount += payment.amount;
          }
        }

        // Calculate approved stats from recent payments
        if (paymentState is RecentApprovedPaymentsLoaded) {
          approvedCount = paymentState.payments.length;
          for (var payment in paymentState.payments) {
            approvedAmount += payment.amount;
          }
          if (approvedCount > 0) {
            averageAmount = approvedAmount / approvedCount;
          }
        }

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
                  child: _buildStatCard(
                    'Pending Review',
                    NumberFormat('#,###').format(pendingAmount),
                    'Sh',
                    '$pendingCount payments',
                    Colors.orange,
                    Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Approved',
                    NumberFormat('#,###').format(approvedAmount),
                    'Sh',
                    '$approvedCount payments',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Average Payment',
              NumberFormat('#,###').format(averageAmount),
              'Sh',
              approvedCount > 0 ? 'Based on $approvedCount approved payments' : 'No data',
              Colors.blue,
              Icons.trending_up,
              fullWidth: true,
            ),
          ],
        );
      },
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
}
