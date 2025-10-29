import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Recent Activity Card showing horizontal scrollable list of activities
class RecentActivityCard extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityCard({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full activity page
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        // Horizontal scrollable list
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ActivityItemCard(activity: activities[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual Activity Item Card
class ActivityItemCard extends StatelessWidget {
  final ActivityItem activity;

  const ActivityItemCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: activity.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: activity.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        activity.icon,
                        color: activity.color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(context),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),

                // Timestamp
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(activity.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String statusText;

    switch (activity.status) {
      case ActivityStatus.approved:
        badgeColor = AppColors.success;
        statusText = 'Approved';
        break;
      case ActivityStatus.pending:
        badgeColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case ActivityStatus.rejected:
        badgeColor = AppColors.error;
        statusText = 'Rejected';
        break;
      case ActivityStatus.submitted:
        badgeColor = AppColors.info;
        statusText = 'Submitted';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

/// Activity Item Model
class ActivityItem {
  final ActivityType type;
  final String title;
  final String description;
  final ActivityStatus status;
  final DateTime timestamp;
  final VoidCallback? onTap;

  ActivityItem({
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.timestamp,
    this.onTap,
  });

  IconData get icon {
    switch (type) {
      case ActivityType.report:
        return Icons.library_books;
      case ActivityType.payment:
        return Icons.payment;
      case ActivityType.penalty:
        return Icons.warning;
      case ActivityType.excuse:
        return Icons.medical_services;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.report:
        return AppColors.primary;
      case ActivityType.payment:
        return AppColors.success;
      case ActivityType.penalty:
        return AppColors.error;
      case ActivityType.excuse:
        return AppColors.warning;
    }
  }
}

/// Activity Type Enum
enum ActivityType {
  report,
  payment,
  penalty,
  excuse,
}

/// Activity Status Enum
enum ActivityStatus {
  approved,
  pending,
  rejected,
  submitted,
}
