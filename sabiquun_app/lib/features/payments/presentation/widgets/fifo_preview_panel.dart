import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/fifo_payment_distribution.dart';

/// Widget that displays the FIFO payment distribution preview
class FifoPreviewPanel extends StatelessWidget {
  final FifoPaymentDistribution distribution;

  const FifoPreviewPanel({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'PAYMENT DISTRIBUTION PREVIEW',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.blue[900],
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Payment summary
          _buildSummaryRow(
            context,
            'Payment Amount:',
            distribution.formattedPaymentAmount,
            Colors.blue[900]!,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'Current Balance:',
            distribution.formattedCurrentBalance,
            Colors.red[700]!,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'New Balance:',
            distribution.formattedNewBalance,
            distribution.newBalance > 0 ? Colors.orange[700]! : Colors.green[700]!,
            isBold: true,
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: Colors.blue[200],
          ),

          const SizedBox(height: 20),

          // Distribution details
          Text(
            'Distribution Details:',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[900],
                ),
          ),
          const SizedBox(height: 12),

          // List of applications
          if (distribution.applications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No penalties to apply payment to.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...distribution.applications.asMap().entries.map((entry) {
              final index = entry.key;
              final application = entry.value;
              return _buildApplicationItem(
                context,
                application,
                index + 1,
              );
            }),

          // Remaining payment
          if (distribution.remainingPaymentAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Remaining: ${distribution.remainingPaymentAmount.toStringAsFixed(0)} Shillings',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                'All penalties covered! Excess will reduce balance.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          // Summary
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Applied:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                Text(
                  distribution.formattedTotalApplied,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.blue[900],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationItem(
    BuildContext context,
    PenaltyPaymentApplication application,
    int position,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: application.isFullyPaid
              ? Colors.green[300]!
              : Colors.orange[300]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Position badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: application.isFullyPaid
                  ? Colors.green[100]
                  : Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: application.isFullyPaid
                      ? Colors.green[800]
                      : Colors.orange[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  DateFormat('MMM dd, yyyy')
                      .format(application.penalty.dateIncurred),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Application details
                Row(
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      application.formattedAmountApplied,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),

                if (!application.isFullyPaid) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Remaining: ${application.formattedRemainingAfter}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status badge
          if (application.isFullyPaid)
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 20,
            )
          else
            Icon(
              Icons.timelapse,
              color: Colors.orange[600],
              size: 20,
            ),
        ],
      ),
    );
  }
}
