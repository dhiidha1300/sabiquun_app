import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/core/utils/date_formatter.dart';
import 'package:sabiquun_app/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:sabiquun_app/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';

enum DateSelection { today, yesterday }

class TodayDeedsPage extends StatefulWidget {
  const TodayDeedsPage({super.key});

  @override
  State<TodayDeedsPage> createState() => _TodayDeedsPageState();
}

class _TodayDeedsPageState extends State<TodayDeedsPage> {
  final Map<String, double> _deedValues = {};
  DateSelection _selectedDate = DateSelection.today;
  DateTime _currentReportDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<DeedBloc>().add(const LoadTodayReportRequested());
  }

  bool _isYesterdayAvailable() {
    // Check if within grace period (12 hours after midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final gracePeriodEnd = midnight.add(const Duration(hours: 12));

    return now.isBefore(gracePeriodEnd);
  }

  void _onDateSelectionChanged(DateSelection selection) {
    if (_selectedDate == selection) return;

    HapticFeedback.selectionClick();

    setState(() {
      _selectedDate = selection;
      _currentReportDate = selection == DateSelection.today
          ? DateTime.now()
          : DateTime.now().subtract(const Duration(days: 1));
      // Clear deed values when switching dates
      _deedValues.clear();
    });

    // Reload data for new date
    context.read<DeedBloc>().add(const LoadTodayReportRequested());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Deeds'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<DeedBloc, DeedState>(
        listener: (context, state) {
          if (state is DeedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DeedReportCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DeedBloc>().add(const LoadTodayReportRequested());
          } else if (state is DeedReportUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DeedBloc>().add(const LoadTodayReportRequested());
          } else if (state is DeedReportSubmitted) {
            _showSuccessDialog();
          }
        },
        builder: (context, state) {
          if (state is DeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TodayReportLoaded) {
            // Initialize values from existing report
            if (state.report != null && _deedValues.isEmpty) {
              for (var entry in state.report!.entries ?? []) {
                _deedValues[entry.deedTemplateId] = entry.deedValue;
              }
            } else if (_deedValues.isEmpty) {
              // Initialize with zeros for new report
              for (var template in state.templates) {
                _deedValues[template.id] = 0.0;
              }
            }

            final canEdit = state.report == null ||
                           state.report!.status.isEditable;

            return _buildForm(
              templates: state.templates,
              canEdit: canEdit,
              existingReport: state.report,
            );
          }

          return const Center(
            child: Text('Unable to load deed templates'),
          );
        },
      ),
    );
  }

  Widget _buildForm({
    required List<DeedTemplateEntity> templates,
    required bool canEdit,
    dynamic existingReport,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateCard(),
          const SizedBox(height: 24),
          _buildDeedsSection(templates, canEdit),
          const SizedBox(height: 24),
          _buildSummaryCard(templates),
          const SizedBox(height: 24),
          if (canEdit) _buildActionButtons(existingReport),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final yesterdayAvailable = _isYesterdayAvailable();

    return Column(
      children: [
        // Date selector toggle
        if (yesterdayAvailable)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateSelectorButton(
                    label: 'Today',
                    selection: DateSelection.today,
                  ),
                ),
                Expanded(
                  child: _buildDateSelectorButton(
                    label: 'Yesterday',
                    selection: DateSelection.yesterday,
                  ),
                ),
              ],
            ),
          ),

        // Date display card with Hijri support
        BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, calendarState) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.surface,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekdays[_currentReportDate.weekday - 1],
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.format(
                            _currentReportDate,
                            preference: calendarState.preference,
                            shortFormat: false,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateSelectorButton({
    required String label,
    required DateSelection selection,
  }) {
    final isSelected = _selectedDate == selection;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onDateSelectionChanged(selection),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
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
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeedsSection(List<DeedTemplateEntity> templates, bool canEdit) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.checklist_rounded,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Daily Deeds Checklist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...templates.map((template) => _buildDeedItem(template, canEdit)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedItem(DeedTemplateEntity template, bool canEdit) {
    final value = _deedValues[template.id] ?? 0;
    final isCompleted = value > 0;
    final isFractional = template.valueType == 'fractional';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF2E7D32).withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: template.category == 'faraid'
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  template.category == 'faraid'
                      ? Icons.star_rounded
                      : Icons.favorite_rounded,
                  color: template.category == 'faraid'
                      ? Colors.blue.shade700
                      : Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.deedName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      template.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: template.category == 'faraid'
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (canEdit && !isFractional)
                Switch(
                  value: isCompleted,
                  onChanged: (val) {
                    setState(() {
                      _deedValues[template.id] = val ? 1.0 : 0.0;
                    });
                  },
                  activeTrackColor: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                  activeThumbColor: const Color(0xFF2E7D32),
                )
              else if (!canEdit)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.cancel,
                    color: isCompleted ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
            ],
          ),
          // Show slider for fractional deeds when editing
          if (canEdit && isFractional) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF2E7D32),
                      inactiveTrackColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                      thumbColor: const Color(0xFF2E7D32),
                      overlayColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: value,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: value.toStringAsFixed(1),
                      onChanged: (newValue) {
                        setState(() {
                          _deedValues[template.id] = newValue;
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ],
          // Show value for fractional deeds when not editing
          if (!canEdit && isFractional) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(value * 100).toInt()}% completed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildSummaryCard(List<DeedTemplateEntity> templates) {
    double totalDeeds = 0.0;
    double missedDeeds = 0.0;
    double sunnahCount = 0.0;
    double faraidCount = 0.0;

    const penaltyPerDeed = 5000.0; // System setting: 5000 shillings per deed (500 per 0.1)

    for (var template in templates) {
      final value = _deedValues[template.id] ?? 0.0;
      final maxValue = 1.0; // Each deed is worth 1.0 max

      totalDeeds += value;
      missedDeeds += (maxValue - value);

      // Categorize by type
      if (template.category == 'sunnah') {
        sunnahCount += value;
      } else if (template.category == 'faraid') {
        faraidCount += value;
      }
    }

    final totalPenalty = missedDeeds * penaltyPerDeed;
    final completionPercentage = (totalDeeds / templates.length * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.indigo.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assessment_rounded,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completionPercentage%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total',
                    '${totalDeeds.toStringAsFixed(1)}/${templates.length}',
                    Icons.assignment_turned_in,
                    const Color(0xFF2E7D32),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _buildSummaryItem(
                    'Sunnah',
                    sunnahCount.toStringAsFixed(1),
                    Icons.favorite,
                    Colors.green.shade700,
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _buildSummaryItem(
                    'Faraid',
                    faraidCount.toStringAsFixed(1),
                    Icons.star,
                    Colors.blue.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Missed Deeds:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        missedDeeds.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Penalty:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${totalPenalty.toStringAsFixed(0)} TSh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(dynamic existingReport) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveReport(submit: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Draft',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveReport(submit: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Submit Report',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _saveReport({required bool submit}) {
    // Use createDeedReport with submitImmediately flag
    // This handles both new reports and updates to existing reports
    context.read<DeedBloc>().add(
          CreateDeedReportRequested(
            reportDate: _currentReportDate,
            deedValues: _deedValues,
            submitImmediately: submit,
          ),
        );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SuccessDialog(),
    ).then((_) {
      if (mounted) {
        context.pop();
      }
    });
  }
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _checkAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(60, 60),
                            painter: _CheckPainter(
                              progress: _checkAnimation.value,
                              color: const Color(0xFF2E7D32),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Report Submitted!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your daily deeds have been recorded successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Check mark path
    final startPoint = Offset(size.width * 0.2, size.height * 0.5);
    final midPoint = Offset(size.width * 0.4, size.height * 0.7);
    final endPoint = Offset(size.width * 0.8, size.height * 0.3);

    if (progress <= 0.5) {
      // First part of check (down stroke)
      final t = progress * 2;
      final currentPoint = Offset(
        startPoint.dx + (midPoint.dx - startPoint.dx) * t,
        startPoint.dy + (midPoint.dy - startPoint.dy) * t,
      );
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Full first stroke + partial second stroke
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(midPoint.dx, midPoint.dy);

      final t = (progress - 0.5) * 2;
      final currentPoint = Offset(
        midPoint.dx + (endPoint.dx - midPoint.dx) * t,
        midPoint.dy + (endPoint.dy - midPoint.dy) * t,
      );
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
