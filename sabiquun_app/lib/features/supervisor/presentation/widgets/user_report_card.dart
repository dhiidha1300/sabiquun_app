import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_report_summary_entity.dart';

/// User report card widget
class UserReportCard extends StatelessWidget {
  final UserReportSummaryEntity userReport;
  final VoidCallback onTap;

  const UserReportCard({
    super.key,
    required this.userReport,
    required this.onTap,
  });

  Color _getMembershipColor() {
    switch (userReport.membershipStatus.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'exclusive':
        return Colors.purple;
      case 'legacy':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getMembershipIcon() {
    switch (userReport.membershipStatus.toLowerCase()) {
      case 'new':
        return Icons.star_border;
      case 'exclusive':
        return Icons.diamond_outlined;
      case 'legacy':
        return Icons.emoji_events_outlined;
      default:
        return Icons.person_outline;
    }
  }

  String _getRelativeTime() {
    if (userReport.lastReportTime == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(userReport.lastReportTime!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(userReport.lastReportTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = userReport.daysWithoutReport > 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isWarning ? Colors.orange.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - User info
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      userReport.fullName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userReport.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getMembershipIcon(),
                              size: 12,
                              color: _getMembershipColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              userReport.membershipStatus,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getMembershipColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Warning indicator
                  if (isWarning)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${userReport.todayDeeds}/${userReport.todayTarget}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: userReport.todayTarget > 0
                              ? userReport.todayDeeds / userReport.todayTarget
                              : 0,
                          backgroundColor: Colors.grey.shade200,
                          color: userReport.todayDeeds >= userReport.todayTarget
                              ? Colors.green
                              : AppColors.primary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(
                    'Last Report',
                    _getRelativeTime(),
                    isWarning ? Colors.orange : Colors.grey,
                  ),
                  _buildStat(
                    'Compliance',
                    '${(userReport.complianceRate * 100).toStringAsFixed(0)}%',
                    userReport.complianceRate >= 0.8 ? Colors.green : Colors.orange,
                  ),
                ],
              ),

              if (userReport.isAtRisk) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'High balance: ${userReport.currentBalance.toStringAsFixed(0)} shillings',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
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
}
