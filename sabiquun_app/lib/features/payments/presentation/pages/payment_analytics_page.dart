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
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_state.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as excel_pkg;
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Trend Chart
        Text(
          'Payment Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentTrendChart(),
        const SizedBox(height: 24),

        // Payment Distribution Pie Chart
        Text(
          'Payment Method Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentMethodPieChart(),
      ],
    );
  }

  Widget _buildPaymentTrendChart() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        // Generate sample data for the last 7 days
        // In production, this should come from actual payment data
        final List<FlSpot> spots = [];
        final now = DateTime.now();

        // Sample data - replace with actual data from state
        for (int i = 6; i >= 0; i--) {
          spots.add(FlSpot(
            (6 - i).toDouble(),
            (50000 + (i * 10000) + (i % 3 * 15000)).toDouble(),
          ));
        }

        return Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final date = now.subtract(Duration(days: 6 - value.toInt()));
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 50000,
                    reservedSize: 50,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '${(value / 1000).toInt()}K',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                ),
              ),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 200000,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.5),
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => AppColors.primary,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      return LineTooltipItem(
                        '${NumberFormat('#,###').format(barSpot.y)} Sh',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodPieChart() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        // Calculate payment method distribution
        Map<String, double> methodTotals = {};
        double total = 0;

        if (state is RecentApprovedPaymentsLoaded) {
          for (var payment in state.payments) {
            final method = payment.paymentMethodName ?? 'Unknown';
            methodTotals[method] = (methodTotals[method] ?? 0) + payment.amount;
            total += payment.amount;
          }
        }

        if (methodTotals.isEmpty) {
          return _buildEmptyState('No payment data available for chart');
        }

        return Container(
          height: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch for interactivity
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _buildPieSections(methodTotals, total),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Legend
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: methodTotals.entries.map((entry) {
                    final percentage = (entry.value / total * 100).toStringAsFixed(1);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getMethodColor(entry.key),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> methodTotals,
    double total,
  ) {
    return methodTotals.entries.map((entry) {
      final percentage = entry.value / total * 100;
      return PieChartSectionData(
        color: _getMethodColor(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
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
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AdminError) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading user balances',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is UsersLoaded) {
          final users = state.users;

          if (users.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate total balance
          double totalBalance = 0;
          for (var user in users) {
            totalBalance += user.currentBalance;
          }

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
                    children: const [
                      Expanded(
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
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
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

                // Table Body
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isOdd = index % 2 == 1;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isOdd
                            ? AppColors.background.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              NumberFormat('#,###').format(user.currentBalance),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: user.currentBalance > 0
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Total Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Total Balance (${users.length} users)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          NumberFormat('#,###').format(totalBalance),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: totalBalance > 0 ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Initial state - load users
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<AdminBloc>().add(
                  const LoadUsersRequested(accountStatus: 'active'),
                );
          }
        });

        return Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: const Center(child: CircularProgressIndicator()),
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
    final adminState = context.read<AdminBloc>().state;

    if (adminState is! UsersLoaded || adminState.users.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No user data available to export'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final users = adminState.users;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating ${format.toUpperCase()} file...',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      if (format == 'pdf') {
        await _exportAsPDF(users);
      } else if (format == 'excel') {
        await _exportAsExcel(users);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${format.toUpperCase()} exported successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportAsPDF(List<dynamic> users) async {
    final pdf = pw.Document();
    final dateRange = _getDateRangeText();

    // Calculate total balance
    double totalBalance = 0;
    for (var user in users) {
      totalBalance += user.currentBalance;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'User Balances Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Period: $dateRange',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Users: ${users.length}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Total Balance: ${NumberFormat('#,###').format(totalBalance)} Sh',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Table
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
              },
              headers: ['User Name', 'Email', 'Balance (Sh)'],
              data: users.map((user) {
                return [
                  user.name,
                  user.email,
                  NumberFormat('#,###').format(user.currentBalance),
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    // Save and share the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/user_balances_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'User Balances Report - $dateRange',
    );
  }

  Future<void> _exportAsExcel(List<dynamic> users) async {
    final excel = excel_pkg.Excel.createExcel();
    final sheet = excel['User Balances'];

    // Calculate total balance
    double totalBalance = 0;
    for (var user in users) {
      totalBalance += user.currentBalance;
    }

    // Title and metadata
    sheet.merge(
      excel_pkg.CellIndex.indexByString('A1'),
      excel_pkg.CellIndex.indexByString('C1'),
    );
    var titleCell = sheet.cell(excel_pkg.CellIndex.indexByString('A1'));
    titleCell.value = excel_pkg.TextCellValue('User Balances Report');
    titleCell.cellStyle = excel_pkg.CellStyle(
      bold: true,
      fontSize: 16,
    );

    // Date range
    sheet.merge(
      excel_pkg.CellIndex.indexByString('A2'),
      excel_pkg.CellIndex.indexByString('C2'),
    );
    var dateCell = sheet.cell(excel_pkg.CellIndex.indexByString('A2'));
    dateCell.value = excel_pkg.TextCellValue('Period: ${_getDateRangeText()}');

    // Generated date
    sheet.merge(
      excel_pkg.CellIndex.indexByString('A3'),
      excel_pkg.CellIndex.indexByString('C3'),
    );
    var generatedCell = sheet.cell(excel_pkg.CellIndex.indexByString('A3'));
    generatedCell.value = excel_pkg.TextCellValue(
      'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
    );

    // Headers
    final headerStyle = excel_pkg.CellStyle(
      bold: true,
      backgroundColorHex: excel_pkg.ExcelColor.fromHexString('#D3D3D3'),
    );

    var headerRow = 5;
    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: headerRow))
      ..value = excel_pkg.TextCellValue('User Name')
      ..cellStyle = headerStyle;
    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: headerRow))
      ..value = excel_pkg.TextCellValue('Email')
      ..cellStyle = headerStyle;
    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: headerRow))
      ..value = excel_pkg.TextCellValue('Balance (Sh)')
      ..cellStyle = headerStyle;

    // Data rows
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final rowIndex = headerRow + 1 + i;

      sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = excel_pkg.TextCellValue(user.name);
      sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = excel_pkg.TextCellValue(user.email);
      sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = excel_pkg.DoubleCellValue(user.currentBalance);
    }

    // Total row
    final totalRowIndex = headerRow + 1 + users.length;
    final totalStyle = excel_pkg.CellStyle(
      bold: true,
      backgroundColorHex: excel_pkg.ExcelColor.fromHexString('#D3D3D3'),
    );

    sheet.merge(
      excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRowIndex),
      excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: totalRowIndex),
    );
    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRowIndex))
      ..value = excel_pkg.TextCellValue('Total (${users.length} users)')
      ..cellStyle = totalStyle;
    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRowIndex))
      ..value = excel_pkg.DoubleCellValue(totalBalance)
      ..cellStyle = totalStyle;

    // Set column widths
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 15);

    // Save and share
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/user_balances_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'User Balances Report - ${_getDateRangeText()}',
    );
  }
}
