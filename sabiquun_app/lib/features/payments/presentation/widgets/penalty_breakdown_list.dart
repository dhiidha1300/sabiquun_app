import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../penalties/domain/entities/penalty_entity.dart';

/// Widget that displays a list of penalties in FIFO order
class PenaltyBreakdownList extends StatelessWidget {
  final List<PenaltyEntity> penalties;
  final bool showWaived;

  const PenaltyBreakdownList({
    super.key,
    required this.penalties,
    this.showWaived = true,
  });

  @override
  Widget build(BuildContext context) {
    if (penalties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No penalties found',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'PENALTY BREAKDOWN (FIFO ORDER)',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                  letterSpacing: 0.5,
                ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: penalties.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _buildPenaltyItem(context, penalties[index], index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildPenaltyItem(
      BuildContext context, PenaltyEntity penalty, int position) {
    final isWaived = penalty.status.isWaived;
    final isFullyPaid = penalty.isFullyPaid;
    final hasPartialPayment = penalty.paidAmount > 0 && !isFullyPaid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isWaived
          ? Colors.grey[50]
          : isFullyPaid
              ? Colors.green[50]
              : hasPartialPayment
                  ? Colors.amber[50]
                  : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Position indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isWaived
                  ? Colors.grey[300]
                  : isFullyPaid
                      ? Colors.green[100]
                      : hasPartialPayment
                          ? Colors.amber[100]
                          : Colors.red[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: isWaived
                      ? Colors.grey[700]
                      : isFullyPaid
                          ? Colors.green[800]
                          : hasPartialPayment
                              ? Colors.amber[900]
                              : Colors.red[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Penalty details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  DateFormat('MMM dd, yyyy').format(penalty.dateIncurred),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),

                // Amount information
                if (isWaived) ...[
                  Text(
                    penalty.formattedAmount,
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Waived: ${penalty.waivedReason ?? "No reason provided"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else if (isFullyPaid) ...[
                  Text(
                    penalty.formattedAmount,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Fully Paid ✓',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (hasPartialPayment) ...[
                  Text(
                    'Total: ${penalty.formattedAmount}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Paid: ${penalty.formattedPaidAmount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Remaining: ${penalty.formattedRemainingAmount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  Text(
                    penalty.formattedAmount,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unpaid',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                // Missing deeds
                if (penalty.missedDeeds != null && penalty.missedDeeds! > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Missing: ${penalty.missedDeeds!.toStringAsFixed(1)} deed${penalty.missedDeeds! > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status badge
          _buildStatusBadge(penalty),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PenaltyEntity penalty) {
    if (penalty.status.isWaived) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'WAIVED',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    if (penalty.isFullyPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'PAID',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.green[800],
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    if (penalty.paidAmount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'PARTIAL',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.amber[900],
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'UNPAID',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
