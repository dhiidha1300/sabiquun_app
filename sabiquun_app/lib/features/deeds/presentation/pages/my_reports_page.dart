import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';
import 'package:sabiquun_app/features/home/widgets/role_based_scaffold.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

enum QuickFilter { last7Days, last30Days, last3Months, allTime, custom }

enum StatusFilter { all, submitted, draft }

class _MyReportsPageState extends State<MyReportsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  QuickFilter _selectedQuickFilter = QuickFilter.allTime;
  StatusFilter _selectedStatusFilter = StatusFilter.all;
  bool _showStats = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    context.read<DeedBloc>().add(
          LoadMyReportsRequested(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  void _applyQuickFilter(QuickFilter filter) {
    setState(() {
      _selectedQuickFilter = filter;
      final now = DateTime.now();

      switch (filter) {
        case QuickFilter.last7Days:
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case QuickFilter.last30Days:
          _startDate = now.subtract(const Duration(days: 30));
          _endDate = now;
          break;
        case QuickFilter.last3Months:
          _startDate = DateTime(now.year, now.month - 3, now.day);
          _endDate = now;
          break;
        case QuickFilter.allTime:
          _startDate = null;
          _endDate = null;
          break;
        case QuickFilter.custom:
          // Custom filter will open date picker
          break;
      }
    });

    if (filter != QuickFilter.custom) {
      HapticFeedback.selectionClick();
      _loadReports();
    }
  }

  List<DeedReportEntity> _filterReportsByStatus(List<DeedReportEntity> reports) {
    if (_selectedStatusFilter == StatusFilter.all) {
      return reports;
    }

    return reports.where((report) {
      if (_selectedStatusFilter == StatusFilter.submitted) {
        return report.status.isSubmitted;
      } else {
        return report.status.isDraft;
      }
    }).toList();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return RoleBasedScaffold(
      currentIndex: 1,
      child: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            SafeArea(
              child: BlocConsumer<DeedBloc, DeedState>(
                listener: (context, state) {
                  if (state is DeedError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is DeedLoading) {
                    return _buildLoadingState();
                  }

                  if (state is MyReportsLoaded) {
                    final filteredReports = _filterReportsByStatus(state.reports);

                    return RefreshIndicator(
                      onRefresh: () async {
                        HapticFeedback.lightImpact();
                        _loadReports();
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      color: AppColors.primary,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Custom Header
                          SliverToBoxAdapter(
                            child: _buildHeader(),
                          ),

                          // Statistics Card
                          if (_showStats)
                            SliverToBoxAdapter(
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 400),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildStatsCard(state.reports),
                              ),
                            ),

                          // Filter Chips
                          SliverToBoxAdapter(
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildFilterChips(),
                            ),
                          ),

                          // Reports List or Empty State
                          if (filteredReports.isEmpty)
                            SliverFillRemaining(
                              child: _buildEmptyState(),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return TweenAnimationBuilder<double>(
                                      duration: Duration(milliseconds: 600 + (index * 100)),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(30 * (1 - value), 0),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _buildReportCard(filteredReports[index], index),
                                    );
                                  },
                                  childCount: filteredReports.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return _buildEmptyState();
                },
              ),
            ),

            // FAB positioned absolutely
            Positioned(
              right: 16,
              bottom: 86,
              child: FloatingActionButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await context.push('/today-deeds');
                  _loadReports();
                },
                backgroundColor: AppColors.success,
                elevation: 6,
                highlightElevation: 12,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(3, (index) => _buildSkeletonCard()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonBox(width: 150, height: 20),
          const SizedBox(height: 12),
          _buildSkeletonBox(width: double.infinity, height: 8),
          const SizedBox(height: 12),
          _buildSkeletonBox(width: 200, height: 16),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'My Reports',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(List<DeedReportEntity> reports) {
    final totalReports = reports.length;
    final submittedReports = reports.where((r) => r.status.isSubmitted).length;
    final avgCompletion = reports.isEmpty
        ? 0.0
        : reports.map((r) => r.completionPercentage).reduce((a, b) => a + b) / reports.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _showStats = !_showStats;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        _showStats ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  if (_showStats) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.assignment_outlined,
                            label: 'Total Reports',
                            value: totalReports.toString(),
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.check_circle_outline,
                            label: 'Submitted',
                            value: submittedReports.toString(),
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.trending_up,
                            label: 'Avg Complete',
                            value: '${avgCompletion.toStringAsFixed(0)}%',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Date Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
          child: Text(
            'Date Range',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Last 7 Days',
                isSelected: _selectedQuickFilter == QuickFilter.last7Days,
                onTap: () => _applyQuickFilter(QuickFilter.last7Days),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Last 30 Days',
                isSelected: _selectedQuickFilter == QuickFilter.last30Days,
                onTap: () => _applyQuickFilter(QuickFilter.last30Days),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Last 3 Months',
                isSelected: _selectedQuickFilter == QuickFilter.last3Months,
                onTap: () => _applyQuickFilter(QuickFilter.last3Months),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'All Time',
                isSelected: _selectedQuickFilter == QuickFilter.allTime,
                onTap: () => _applyQuickFilter(QuickFilter.allTime),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Custom Range',
                icon: Icons.calendar_today,
                isSelected: _selectedQuickFilter == QuickFilter.custom,
                onTap: () {
                  _applyQuickFilter(QuickFilter.custom);
                  _showCustomDatePicker();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Status Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
          child: Text(
            'Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: _selectedStatusFilter == StatusFilter.all,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedStatusFilter = StatusFilter.all;
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Submitted',
                icon: Icons.check_circle,
                isSelected: _selectedStatusFilter == StatusFilter.submitted,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedStatusFilter = StatusFilter.submitted;
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Draft',
                icon: Icons.edit,
                isSelected: _selectedStatusFilter == StatusFilter.draft,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedStatusFilter = StatusFilter.draft;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: isSelected ? 4 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomDatePicker() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
        _selectedQuickFilter = QuickFilter.custom;
      });
      HapticFeedback.selectionClick();
      _loadReports();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Reports Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedStatusFilter != StatusFilter.all
                  ? 'No ${_selectedStatusFilter == StatusFilter.submitted ? "submitted" : "draft"} reports found'
                  : 'Start tracking your daily deeds\nby creating your first report',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await context.push('/today-deeds');
                _loadReports();
              },
              icon: const Icon(Icons.add, size: 22),
              label: const Text('Create First Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                minimumSize: const Size(200, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(DeedReportEntity report, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final completionPercentage = report.completionPercentage;

    // Determine border color based on completion
    Color borderColor;
    if (completionPercentage >= 80) {
      borderColor = AppColors.success;
    } else if (completionPercentage >= 50) {
      borderColor = AppColors.warning;
    } else {
      borderColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            await context.push('/report-detail/${report.id}');
            _loadReports();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Date and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: borderColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormat.format(report.reportDate),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${report.totalDeeds.toStringAsFixed(1)}/${report.totalDeedsCount} deeds',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatusChip(report.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Ring
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: completionPercentage / 100,
                              strokeWidth: 5,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                            ),
                          ),
                          Text(
                            '${completionPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: borderColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Deed Breakdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDeedBreakdownRow(
                            icon: Icons.book_rounded,
                            label: 'Fara\'id',
                            value: '${report.faraidCount.toStringAsFixed(1)}/5',
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          _buildDeedBreakdownRow(
                            icon: Icons.nights_stay_rounded,
                            label: 'Sunnah',
                            value: '${report.sunnahCount.toStringAsFixed(1)}/5',
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Action Button (if draft)
                if (report.status.isDraft) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await context.push('/report-detail/${report.id}');
                        _loadReports();
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Continue Editing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeedBreakdownRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
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

  Widget _buildStatusChip(ReportStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ReportStatus.draft:
        backgroundColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        icon = Icons.edit_rounded;
        break;
      case ReportStatus.submitted:
        backgroundColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
