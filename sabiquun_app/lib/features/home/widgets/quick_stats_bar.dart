import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Quick Stats Bar showing key metrics in a horizontal scrollable row
class QuickStatsBar extends StatelessWidget {
  final int completionStreak;
  final int? currentRank;
  final int? totalUsers;
  final int monthlyDeedsCompleted;
  final int monthlyDeedsTarget;
  final int? pendingApprovals;

  const QuickStatsBar({
    super.key,
    required this.completionStreak,
    this.currentRank,
    this.totalUsers,
    required this.monthlyDeedsCompleted,
    required this.monthlyDeedsTarget,
    this.pendingApprovals,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          // Completion Streak
          _QuickStatChip(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '$completionStreak days',
            color: completionStreak > 0 ? AppColors.accentDark : AppColors.grey,
            onTap: () {
              // TODO: Show streak calendar
            },
          ),
          const SizedBox(width: 12),

          // Current Rank (if available)
          if (currentRank != null && totalUsers != null)
            _QuickStatChip(
              icon: Icons.emoji_events,
              label: 'Rank',
              value: '#$currentRank of $totalUsers',
              color: AppColors.accent,
              onTap: () {
                // TODO: Navigate to leaderboard
              },
            )
          else
            _QuickStatChip(
              icon: Icons.emoji_events,
              label: 'Rank',
              value: 'Coming Soon',
              color: AppColors.grey,
              onTap: null,
            ),
          const SizedBox(width: 12),

          // Monthly Total
          _QuickStatChip(
            icon: Icons.trending_up,
            label: 'This Month',
            value: '$monthlyDeedsCompleted/$monthlyDeedsTarget',
            color: AppColors.info,
            onTap: () {
              // TODO: Show monthly breakdown
            },
          ),

          // Pending Approvals (for Admin/Supervisor/Cashier)
          if (pendingApprovals != null && pendingApprovals! > 0) ...[
            const SizedBox(width: 12),
            _QuickStatChip(
              icon: Icons.pending_actions,
              label: 'Pending',
              value: '$pendingApprovals items',
              color: AppColors.warning,
              onTap: () {
                // TODO: Navigate to review dashboard
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual Quick Stat Chip
class _QuickStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _QuickStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
