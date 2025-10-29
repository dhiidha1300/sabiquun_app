import 'package:flutter/material.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Empty State Widget for when there's no data to display
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;
  final Color color;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionButtonText,
    this.onActionPressed,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: color,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),

            // Action Button
            if (actionButtonText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionButtonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Factory constructor for "No Reports" state
  factory EmptyStateWidget.noReports({VoidCallback? onActionPressed}) {
    return EmptyStateWidget(
      icon: Icons.library_books,
      title: 'No Reports Yet',
      description: 'You haven\'t submitted any deed reports yet.\nTrack your daily Islamic deeds and build consistency!',
      actionButtonText: 'Submit Your First Report',
      onActionPressed: onActionPressed,
      color: AppColors.primary,
    );
  }

  /// Factory constructor for "No Payments" state
  factory EmptyStateWidget.noPayments({VoidCallback? onActionPressed}) {
    return EmptyStateWidget(
      icon: Icons.account_balance_wallet,
      title: 'No Payment History',
      description: 'You haven\'t made any payments yet.\nKeep your balance clear by submitting deeds daily!',
      actionButtonText: 'View Penalty Balance',
      onActionPressed: onActionPressed,
      color: AppColors.success,
    );
  }

  /// Factory constructor for "No Excuses" state
  factory EmptyStateWidget.noExcuses({VoidCallback? onActionPressed}) {
    return EmptyStateWidget(
      icon: Icons.medical_services,
      title: 'No Excuses Submitted',
      description: 'You haven\'t submitted any excuse requests yet.\nSubmit excuses for sickness, travel, or rain when needed.',
      actionButtonText: 'Learn About Excuse System',
      onActionPressed: onActionPressed,
      color: AppColors.warning,
    );
  }

  /// Factory constructor for "No Activity" state
  factory EmptyStateWidget.noActivity() {
    return const EmptyStateWidget(
      icon: Icons.history,
      title: 'No Recent Activity',
      description: 'Your recent activity will appear here once you start using the app.',
      color: AppColors.info,
    );
  }
}
