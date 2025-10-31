import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';

/// Collapsible Personal Deed Tracker for Elevated Roles
/// Shows a minimized version of today's progress that can be expanded
class CollapsibleDeedTracker extends StatefulWidget {
  const CollapsibleDeedTracker({super.key});

  @override
  State<CollapsibleDeedTracker> createState() => _CollapsibleDeedTrackerState();
}

class _CollapsibleDeedTrackerState extends State<CollapsibleDeedTracker> {
  bool _isExpanded = false;
  DeedReportEntity? _todayReport;

  @override
  void initState() {
    super.initState();
    context.read<DeedBloc>().add(const LoadTodayReportRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeedBloc, DeedState>(
      listener: (context, state) {
        if (state is TodayReportLoaded) {
          setState(() {
            _todayReport = state.report;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header - Always visible
            _buildHeader(),

            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    double totalDeeds = 0;
    bool isSubmitted = false;

    if (_todayReport != null) {
      totalDeeds = _todayReport!.totalDeeds;
      isSubmitted = _todayReport!.status.isSubmitted;
    }

    final progress = totalDeeds / 10;
    final color = isSubmitted
        ? AppColors.success
        : (progress >= 0.7 ? AppColors.success : AppColors.accent);

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Progress circle
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Text(
                    totalDeeds.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Title and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Deeds Today',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSubmitted ? 'Submitted' : 'Not Submitted',
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expand/collapse icon
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    if (_todayReport == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No report data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final faraid = _todayReport!.faraidCount;
    final sunnah = _todayReport!.sunnahCount;
    final isSubmitted = _todayReport!.status.isSubmitted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 12),

          // Deed breakdown
          Row(
            children: [
              Expanded(
                child: _buildDeedStat(
                  'Fara\'id',
                  faraid,
                  5,
                  Colors.purple,
                  Icons.stars,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeedStat(
                  'Sunnah',
                  sunnah,
                  5,
                  Colors.blue,
                  Icons.light_mode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitted
                  ? () => context.push('/my-reports')
                  : () => context.push('/today-deeds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubmitted ? AppColors.primary : AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: Icon(
                isSubmitted ? Icons.visibility : Icons.add,
                size: 20,
              ),
              label: Text(
                isSubmitted ? 'View My Reports' : 'Submit Today\'s Report',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeedStat(
    String label,
    double value,
    int max,
    Color color,
    IconData icon,
  ) {
    final progress = value / max;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}/$max',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
