import 'package:flutter/material.dart';
import '../../domain/entities/penalty_balance_entity.dart';
import '../../../../core/theme/app_colors.dart';

class PenaltyBalanceCard extends StatelessWidget {
  final PenaltyBalanceEntity balance;
  final VoidCallback? onPayNow;

  const PenaltyBalanceCard({
    super.key,
    required this.balance,
    this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      color: _getBackgroundColor(),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              'Penalty Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 16),

            // Balance Amount
            Text(
              balance.formattedBalance,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),

            // Unpaid Penalties Count
            if (balance.unpaidPenaltiesCount > 0)
              Text(
                '${balance.unpaidPenaltiesCount} unpaid ${balance.unpaidPenaltiesCount == 1 ? 'penalty' : 'penalties'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),

            // Warning Messages
            if (balance.isAtDeactivationThreshold) ...[
              const SizedBox(height: 16),
              _buildWarningMessage(
                context,
                icon: Icons.block,
                message: 'Account Deactivated',
                description: 'Contact admin for reactivation',
              ),
            ] else if (balance.isAtFinalWarning) ...[
              const SizedBox(height: 16),
              _buildWarningMessage(
                context,
                icon: Icons.warning_amber,
                message: 'URGENT: Final Warning',
                description:
                    '${balance.formattedDistanceToDeactivation} away from deactivation',
              ),
            ] else if (balance.isAtFirstWarning) ...[
              const SizedBox(height: 16),
              _buildWarningMessage(
                context,
                icon: Icons.warning,
                message: 'Warning: High Balance',
                description: 'Please pay to avoid deactivation',
              ),
            ],

            // Pay Now Button
            if (balance.balance > 0 && !balance.isAtDeactivationThreshold) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _getBackgroundColor(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWarningMessage(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.surface, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (balance.colorLevel) {
      case BalanceColorLevel.green:
        return AppColors.success;
      case BalanceColorLevel.yellow:
        return AppColors.warning;
      case BalanceColorLevel.red:
        return AppColors.error;
    }
  }
}
