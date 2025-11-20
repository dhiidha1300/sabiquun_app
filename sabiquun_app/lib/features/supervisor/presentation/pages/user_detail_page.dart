import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../widgets/date_range_picker_widget.dart';
import '../../domain/entities/detailed_report_entity.dart';

/// User Detail Page with comprehensive deed details table
class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final NumberFormat _currencyFormat = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));
    _loadDetailedReport();
  }

  void _loadDetailedReport() {
    context.read<SupervisorBloc>().add(LoadDetailedUserReportRequested(
          userId: widget.userId,
          startDate: _startDate,
          endDate: _endDate,
        ));
  }

  void _selectDateRange() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangePickerWidget(
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        onDateRangeSelected: (start, end) {
          setState(() {
            _startDate = start;
            _endDate = end;
          });
          _loadDetailedReport();
        },
      ),
    );
  }

  void _exportReport(String format) {
    context.read<SupervisorBloc>().add(ExportUserReportRequested(
          userId: widget.userId,
          startDate: _startDate,
          endDate: _endDate,
          format: format,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'User Report',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<SupervisorBloc, SupervisorState>(
        listener: (context, state) {
          if (state is ReportExporting) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                content: Row(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(child: Text(state.message)),
                  ],
                ),
              ),
            );
          } else if (state is ReportExported) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report exported successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is SupervisorError) {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SupervisorLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is SupervisorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDetailedReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DetailedUserReportLoaded) {
            return _buildReportView(state.detailedReport);
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildReportView(DetailedUserReportEntity report) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          _buildUserInfoCard(report),

          // Statistics Cards
          _buildStatisticsCards(report),

          // Date Range and Export Controls
          _buildControlsSection(),

          // Deed Details Table
          _buildDeedDetailsTable(report),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(DetailedUserReportEntity report) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Text(
              report.fullName.isNotEmpty ? report.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMembershipColor(report.membershipStatus),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatMembership(report.membershipStatus),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatisticsCards(DetailedUserReportEntity report) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Reports',
              '${report.totalReportsInRange}',
              Icons.description,
              AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Avg Deeds',
              report.averageDeeds.toStringAsFixed(1),
              Icons.trending_up,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Compliance',
              '${report.complianceRate.toStringAsFixed(0)}%',
              Icons.check_circle,
              report.complianceRate >= 80 ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Date Range:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Change'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportReport('pdf'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportReport('excel'),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeedDetailsTable(DetailedUserReportEntity report) {
    if (report.dailyReports.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 64, color: AppColors.textSecondary),
              SizedBox(height: 16),
              Text(
                'No reports found for selected date range',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Get deed names from first report
    final deedNames = report.dailyReports.first.deedEntries
        .map((e) => _abbreviateDeedName(e.deedName))
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Daily Deed Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.1)),
              columns: [
                const DataColumn(
                  label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...deedNames.map((name) => DataColumn(
                      label: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    )),
                const DataColumn(
                  label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: report.dailyReports.map((daily) {
                return DataRow(
                  cells: [
                    DataCell(Text(DateFormat('MMM dd').format(daily.reportDate))),
                    ...daily.deedEntries.map((entry) {
                      final value = entry.valueType == 'binary'
                          ? (entry.deedValue == 1 ? '✓' : '✗')
                          : entry.deedValue.toStringAsFixed(1);
                      return DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: entry.deedValue >= 1.0
                                ? AppColors.success.withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: entry.deedValue >= 1.0
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: daily.totalDeeds >= 10.0
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          daily.totalDeeds.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: daily.totalDeeds >= 10.0
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMembershipColor(String status) {
    switch (status) {
      case 'new':
        return AppColors.info;
      case 'exclusive':
        return AppColors.primary;
      case 'legacy':
        return AppColors.accent;
      default:
        return AppColors.grey;
    }
  }

  String _formatMembership(String status) {
    switch (status) {
      case 'new':
        return 'New Member';
      case 'exclusive':
        return 'Exclusive';
      case 'legacy':
        return 'Legacy';
      default:
        return status;
    }
  }

  String _abbreviateDeedName(String name) {
    final abbreviations = {
      'Fajr Prayer': 'Fajr',
      'Duha Prayer': 'Duha',
      'Dhuhr Prayer': 'Dhuhr',
      'Juz of Quran': 'Juz',
      'Asr Prayer': 'Asr',
      'Sunnah Prayers': 'Sunnah',
      'Maghrib Prayer': 'Maghrib',
      'Isha Prayer': 'Isha',
      'Athkar': 'Athkar',
      'Witr': 'Witr',
    };
    return abbreviations[name] ?? name;
  }
}
