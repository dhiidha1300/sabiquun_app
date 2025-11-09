import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/penalty_entity.dart';
import '../../../../core/theme/app_colors.dart';

class PenaltyCard extends StatelessWidget {
  final PenaltyEntity penalty;
  final VoidCallback? onTap;

  const PenaltyCard({
    super.key,
    required this.penalty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Text(
                    DateFormat('MMM dd, yyyy').format(penalty.dateIncurred),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  // Status Badge
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),

              // Amount
              Text(
                penalty.formattedAmount,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Missed Deeds (if available)
              if (penalty.missedDeeds != null) ...[
                Text(
                  '${penalty.missedDeeds!.toStringAsFixed(1)} deeds missed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
              ],

              // Payment Progress (if partially paid)
              if (penalty.status.isPartiallyPaid) ...[
                const SizedBox(height: 8),
                _buildPaymentProgress(context),
              ],

              // Waived Info (if waived)
              if (penalty.status.isWaived) ...[
                const SizedBox(height: 8),
                if (penalty.waivedReason != null)
                  Text(
                    'Reason: ${penalty.waivedReason}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Text(
        penalty.status.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildPaymentProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paid: ${penalty.formattedPaidAmount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            Text(
              'Remaining: ${penalty.formattedRemainingAmount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: penalty.paymentProgress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (penalty.status) {
      case var status when status.isUnpaid:
        return AppColors.error;
      case var status when status.isPartiallyPaid:
        return AppColors.warning;
      case var status when status.isPaid:
        return AppColors.success;
      case var status when status.isWaived:
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }
}
