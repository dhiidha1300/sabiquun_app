import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/home/utils/time_helper.dart';

/// Statistics Dashboard Card showing key metrics at a glance
class HomeStatisticsCard extends StatelessWidget {
  final int todayDeedsCompleted;
  final int todayDeedsTarget;
  final bool isTodayReportSubmitted;
  final double penaltyBalance;
  final int monthlyDeedsCompleted;
  final int monthlyDeedsTarget;
  final String userId;

  const HomeStatisticsCard({
    super.key,
    required this.todayDeedsCompleted,
    required this.todayDeedsTarget,
    required this.isTodayReportSubmitted,
    required this.penaltyBalance,
    required this.monthlyDeedsCompleted,
    required this.monthlyDeedsTarget,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  Icons.analytics,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics Grid
            Row(
              children: [
                // Today's Progress
                Expanded(
                  child: _TodayProgressWidget(
                    completed: todayDeedsCompleted,
                    target: todayDeedsTarget,
                    isSubmitted: isTodayReportSubmitted,
                    onTap: () => context.push('/today-deeds'),
                  ),
                ),
                const SizedBox(width: 16),

                // Grace Period Timer (only if not submitted)
                if (!isTodayReportSubmitted)
                  Expanded(
                    child: _GracePeriodTimerWidget(),
                  ),

                // Monthly Score (if submitted)
                if (isTodayReportSubmitted)
                  Expanded(
                    child: _MonthlyScoreWidget(
                      completed: monthlyDeedsCompleted,
                      target: monthlyDeedsTarget,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Penalty Balance
            _PenaltyBalanceWidget(
              balance: penaltyBalance,
              userId: userId,
            ),
          ],
        ),
      ),
    );
  }
}

/// Today's Deed Progress Widget
class _TodayProgressWidget extends StatelessWidget {
  final int completed;
  final int target;
  final bool isSubmitted;
  final VoidCallback onTap;

  const _TodayProgressWidget({
    required this.completed,
    required this.target,
    required this.isSubmitted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? completed / target : 0.0;
    final progressColor = _getProgressColor(progress);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: progressColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: progressColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            // Circular Progress
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.greyLight,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  Center(
                    child: Text(
                      '$completed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Today\'s Deeds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '$completed / $target',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (!isSubmitted)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Not submitted',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontSize: 10,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.success;
    if (progress >= 0.7) return AppColors.info;
    if (progress >= 0.5) return AppColors.warning;
    return AppColors.error;
  }
}

/// Grace Period Timer Widget
class _GracePeriodTimerWidget extends StatefulWidget {
  const _GracePeriodTimerWidget();

  @override
  State<_GracePeriodTimerWidget> createState() => _GracePeriodTimerWidgetState();
}

class _GracePeriodTimerWidgetState extends State<_GracePeriodTimerWidget> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = TimeHelper.getRemainingTime();
    // Update every minute
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _remaining = TimeHelper.getRemainingTime();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isApproaching = TimeHelper.isDeadlineApproaching();
    final color = isApproaching ? AppColors.error : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timer,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            'Grace Period',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            TimeHelper.formatDuration(_remaining),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'remaining',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

/// Monthly Score Widget
class _MonthlyScoreWidget extends StatelessWidget {
  final int completed;
  final int target;

  const _MonthlyScoreWidget({
    required this.completed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = target > 0 ? (completed / target * 100).round() : 0;
    final color = percentage >= 80 ? AppColors.success : AppColors.info;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            'This Month',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '$completed / $target',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

/// Penalty Balance Widget
class _PenaltyBalanceWidget extends StatelessWidget {
  final double balance;
  final String userId;

  const _PenaltyBalanceWidget({
    required this.balance,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getBalanceColor(balance);
    final warningLevel = _getWarningLevel(balance);
    final formatter = NumberFormat('#,###');

    return InkWell(
      onTap: () => context.push('/penalty-history', extra: userId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Balance info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penalty Balance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatter.format(balance)} Shillings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (warningLevel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        warningLevel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                      ),
                    ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBalanceColor(double balance) {
    if (balance == 0) return AppColors.success;
    if (balance < 100000) return AppColors.success;
    if (balance < 300000) return AppColors.warning;
    if (balance < 400000) return AppColors.accentDark;
    return AppColors.error;
  }

  String? _getWarningLevel(double balance) {
    if (balance >= 450000) return '⚠️ URGENT: Final Warning';
    if (balance >= 400000) return '⚠️ First Warning';
    if (balance >= 300000) return 'High Balance';
    return null;
  }
}
