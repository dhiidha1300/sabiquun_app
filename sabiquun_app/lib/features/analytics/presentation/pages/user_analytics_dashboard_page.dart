import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';
import 'package:sabiquun_app/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:sabiquun_app/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:sabiquun_app/features/analytics/presentation/bloc/analytics_state.dart';

enum DateRangeFilter {
  week('Last 7 Days'),
  month('Last 30 Days'),
  threeMonths('Last 3 Months'),
  custom('Custom Range');

  final String label;
  const DateRangeFilter(this.label);
}

class UserAnalyticsDashboardPage extends StatefulWidget {
  const UserAnalyticsDashboardPage({super.key});

  @override
  State<UserAnalyticsDashboardPage> createState() => _UserAnalyticsDashboardPageState();
}

class _UserAnalyticsDashboardPageState extends State<UserAnalyticsDashboardPage> {
  DateRangeFilter _selectedRange = DateRangeFilter.month;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final dates = _getDateRange();
      context.read<DeedBloc>().add(
        LoadMyReportsRequested(
          startDate: dates.$1,
          endDate: dates.$2,
        ),
      );
      context.read<AnalyticsBloc>().add(LoadAllAnalyticsRequested(authState.user.id));
    }
  }

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case DateRangeFilter.week:
        return (now.subtract(const Duration(days: 7)), now);
      case DateRangeFilter.month:
        return (now.subtract(const Duration(days: 30)), now);
      case DateRangeFilter.threeMonths:
        return (now.subtract(const Duration(days: 90)), now);
      case DateRangeFilter.custom:
        return (
          _customStartDate ?? now.subtract(const Duration(days: 30)),
          _customEndDate ?? now,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('My Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Range Indicator
              _buildDateRangeCard(),
              const SizedBox(height: 16),

              // Overview Stats
              _buildOverviewStats(),
              const SizedBox(height: 16),

              // Daily Deeds Line Chart
              _buildDailyDeedsChart(),
              const SizedBox(height: 16),

              // Performance Summary
              _buildPerformanceSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    final dates = _getDateRange();
    final formatter = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.date_range, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedRange.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatter.format(dates.$1)} - ${formatter.format(dates.$2)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_calendar),
              onPressed: _showFilterDialog,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AllAnalyticsLoaded) {
          final stats = state.stats;

          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Reports',
                  '${stats.thisMonthReports}',
                  Icons.assignment_turned_in,
                  AppColors.success,
                  subtitle: 'This period',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Current Streak',
                  '${stats.currentStreak}',
                  Icons.local_fire_department,
                  AppColors.warning,
                  subtitle: 'days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completion',
                  '${stats.completionRate.toInt()}%',
                  Icons.check_circle,
                  AppColors.primary,
                  subtitle: 'rate',
                ),
              ),
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
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
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyDeedsChart() {
    return BlocBuilder<DeedBloc, DeedState>(
      builder: (context, state) {
        if (state is MyReportsLoaded) {
          final reports = state.reports;

          if (reports.isEmpty) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No data available for selected period',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          // Prepare data for line chart
          final dates = _getDateRange();
          final daysDiff = dates.$2.difference(dates.$1).inDays;
          final dataPoints = <FlSpot>[];

          for (int i = 0; i <= daysDiff; i++) {
            final date = dates.$1.add(Duration(days: i));
            final dateStr = DateFormat('yyyy-MM-dd').format(date);

            final report = reports.firstWhere(
              (r) => DateFormat('yyyy-MM-dd').format(r.reportDate) == dateStr,
              orElse: () => reports.first.copyWith(totalDeeds: 0),
            );

            dataPoints.add(FlSpot(i.toDouble(), report.totalDeeds));
          }

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.show_chart, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Daily Deeds Trend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 2,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
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
                              interval: daysDiff > 30 ? 15 : 7,
                              getTitlesWidget: (value, meta) {
                                final date = dates.$1.add(Duration(days: value.toInt()));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('MMM dd').format(date),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                            left: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        minX: 0,
                        maxX: daysDiff.toDouble(),
                        minY: 0,
                        maxY: 12,
                        lineBarsData: [
                          LineChartBarData(
                            spots: dataPoints,
                            isCurved: true,
                            color: AppColors.primary,
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
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) => Colors.grey[800]!,
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final date = dates.$1.add(Duration(days: spot.x.toInt()));
                                return LineTooltipItem(
                                  '${DateFormat('MMM dd').format(date)}\n${spot.y.toStringAsFixed(1)} deeds',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                          handleBuiltInTouches: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceSummary() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AllAnalyticsLoaded) {
          final stats = state.stats;
          final currencyFormat = NumberFormat.currency(
            symbol: 'TSh ',
            decimalDigits: 0,
            locale: 'en_US',
          );

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.analytics_outlined, color: AppColors.info, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Performance Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryRow(
                    'Longest Streak',
                    '${stats.longestStreak} days',
                    Icons.trending_up,
                    AppColors.primary,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Total Reports',
                    '${stats.totalReportsSubmitted}',
                    Icons.assignment,
                    AppColors.success,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Completion Rate',
                    '${stats.completionRate.toStringAsFixed(1)}%',
                    Icons.percent,
                    _getPerformanceColor(stats.completionRate),
                  ),
                  if (stats.totalPenaltyAmount > 0) ...[
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total Penalties',
                      currencyFormat.format(stats.totalPenaltyAmount),
                      Icons.warning_amber_rounded,
                      AppColors.error,
                    ),
                  ],
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Excuses (Approved/Total)',
                    '${stats.approvedExcuses}/${stats.totalExcuses}',
                    Icons.event_busy,
                    AppColors.warning,
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, Color color) {
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Date Range'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...DateRangeFilter.values.map((filter) {
                      return RadioListTile<DateRangeFilter>(
                        title: Text(filter.label),
                        value: filter,
                        groupValue: _selectedRange,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedRange = value!;
                          });
                        },
                      );
                    }),
                    if (_selectedRange == DateRangeFilter.custom) ...[
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Start Date'),
                        subtitle: Text(
                          _customStartDate != null
                              ? DateFormat('MMM dd, yyyy').format(_customStartDate!)
                              : 'Select date',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: dialogContext,
                            initialDate: _customStartDate ?? DateTime.now().subtract(const Duration(days: 30)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _customStartDate = date;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('End Date'),
                        subtitle: Text(
                          _customEndDate != null
                              ? DateFormat('MMM dd, yyyy').format(_customEndDate!)
                              : 'Select date',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: dialogContext,
                            initialDate: _customEndDate ?? DateTime.now(),
                            firstDate: _customStartDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _customEndDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    setState(() {});
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

extension on dynamic {
  copyWith({required double totalDeeds}) {
    return this;
  }
}
