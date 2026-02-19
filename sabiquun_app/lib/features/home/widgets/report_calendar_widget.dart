import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sabiquun_app/core/constants/date_constants.dart';
import 'package:sabiquun_app/core/services/hijri_date_service.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/core/utils/date_formatter.dart';
import 'package:sabiquun_app/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:sabiquun_app/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';

/// Beautiful calendar widget showing user's report submission status
/// with color-coded days for quick visual overview
class ReportCalendarWidget extends StatefulWidget {
  const ReportCalendarWidget({super.key});

  @override
  State<ReportCalendarWidget> createState() => _ReportCalendarWidgetState();
}

class _ReportCalendarWidgetState extends State<ReportCalendarWidget>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, DeedReportEntity> _reports = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadMonthReports(_focusedDay);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadMonthReports(DateTime month) {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    context.read<DeedBloc>().add(LoadMyReportsRequested(
          startDate: startDate,
          endDate: endDate,
        ));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }

    HapticFeedback.selectionClick();

    // Normalize the date to midnight for comparison
    final normalizedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    // Find report for selected date
    DeedReportEntity? report;
    for (var entry in _reports.entries) {
      final reportDate = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (isSameDay(reportDate, normalizedDate)) {
        report = entry.value;
        break;
      }
    }

    if (report != null) {
      // Navigate to report detail page
      HapticFeedback.mediumImpact();
      final result = await context.push('/report-detail/${report.id}');

      // Reload reports if user made changes
      if (result == true) {
        _loadMonthReports(_focusedDay);
      }
    } else {
      // Show "No report" dialog
      HapticFeedback.lightImpact();
      _showNoReportDialog(selectedDay);
    }
  }

  void _showNoReportDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[50]!,
                Colors.grey[100]!,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  size: 48,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'No Report Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12),

              // Message
              Text(
                'You haven\'t submitted a report for',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, calendarState) {
                  return Text(
                    DateFormatter.format(
                      date,
                      preference: calendarState.preference,
                      fullFormat: true,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForDay(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Future dates are gray
    if (normalizedDate.isAfter(today)) {
      return Colors.grey[300]!;
    }

    // Find report for this date
    DeedReportEntity? report;
    for (var entry in _reports.entries) {
      final reportDate = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (isSameDay(reportDate, normalizedDate)) {
        report = entry.value;
        break;
      }
    }

    if (report != null) {
      // Green for submitted reports
      if (report.status.isSubmitted) {
        return AppColors.success;
      }
      // Yellow for draft reports
      return const Color(0xFFFFB300);
    }

    // Red for missed days (past dates with no report)
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeedBloc, DeedState>(
      listener: (context, state) {
        if (state is MyReportsLoaded) {
          setState(() {
            // Map reports by date
            _reports = {
              for (var report in state.reports)
                DateTime(
                  report.reportDate.year,
                  report.reportDate.month,
                  report.reportDate.day,
                ): report
            };
          });
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Report Calendar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/my-reports'),
                  icon: Icon(Icons.list_rounded, size: 18),
                  label: Text('List View'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Calendar card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Calendar
                    TableCalendar(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      onDaySelected: _onDaySelected,
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        _loadMonthReports(focusedDay);
                        _animationController.forward(from: 0);
                      },
                      calendarStyle: CalendarStyle(
                        // Today's styling
                        todayDecoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        todayTextStyle: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),

                        // Selected day styling
                        selectedDecoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        selectedTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),

                        // Default day styling
                        defaultTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),

                        // Weekend styling
                        weekendTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),

                        // Outside month styling
                        outsideTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),

                        // Marker styling
                        markersMaxCount: 1,
                        markerDecoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: AppColors.primary,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: AppColors.primary,
                        ),
                        headerPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        weekendStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        headerTitleBuilder: (context, day) {
                          return BlocBuilder<CalendarBloc, CalendarState>(
                            builder: (context, calendarState) {
                              // Get Hijri date for the focused month
                              final hijri = HijriDateService.instance.toHijri(day);
                              final hijriMonthName = DateConstants.hijriMonthsEnglish[hijri.hMonth - 1];

                              // Gregorian month name
                              final gregorianMonths = ['January', 'February', 'March', 'April', 'May', 'June',
                                'July', 'August', 'September', 'October', 'November', 'December'];
                              final gregorianMonthName = gregorianMonths[day.month - 1];

                              // Show based on preference (Google Calendar style: primary on top, secondary below)
                              final pref = calendarState.preference;
                              final showHijriPrimary = pref == CalendarPreference.hijriPrimary || pref == CalendarPreference.hijriOnly;
                              final showBoth = pref == CalendarPreference.hijriPrimary || pref == CalendarPreference.gregorianPrimary;

                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Primary date (larger)
                                    Text(
                                      showHijriPrimary
                                        ? '$hijriMonthName ${hijri.hYear}'
                                        : '$gregorianMonthName ${day.year}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Secondary date (smaller, only if showing both)
                                    if (showBoth)
                                      Text(
                                        showHijriPrimary
                                          ? '$gregorianMonthName ${day.year}'
                                          : '$hijriMonthName ${hijri.hYear}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          return _buildCalendarDay(day, false, false);
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return _buildCalendarDay(day, true, false);
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return _buildCalendarDay(day, false, true);
                        },
                        outsideBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Legend
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        border: Border(
                          top: BorderSide(color: Theme.of(context).colorScheme.surfaceVariant!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(
                            color: AppColors.success,
                            label: 'Submitted',
                          ),
                          _buildLegendItem(
                            color: Color(0xFFFFB300),
                            label: 'Draft',
                          ),
                          _buildLegendItem(
                            color: AppColors.error,
                            label: 'Missed',
                          ),
                          _buildLegendItem(
                            color: Theme.of(context).colorScheme.surfaceVariant!,
                            label: 'Future',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, bool isSelected, bool isToday) {
    final color = _getColorForDay(day);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isToday ? AppColors.primary : Theme.of(context).colorScheme.onSurface),
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          // Status indicator dot
          if (!isSelected)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
