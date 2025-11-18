import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/fifo_payment_distribution.dart';
import '../../../penalties/domain/entities/penalty_entity.dart';
import '../../../penalties/domain/entities/penalty_balance_entity.dart';
import '../../../penalties/presentation/bloc/penalty_bloc.dart';
import '../../../penalties/presentation/bloc/penalty_event.dart';
import '../../../penalties/presentation/bloc/penalty_state.dart';
import 'fifo_preview_panel.dart';
import 'penalty_breakdown_list.dart';
import 'approve_payment_dialog.dart';
import 'reject_payment_dialog.dart';
import '../bloc/payment_bloc.dart';

/// Comprehensive payment details modal with FIFO preview
class PaymentDetailsModal extends StatefulWidget {
  final PaymentEntity payment;
  final VoidCallback? onPaymentApproved;
  final VoidCallback? onPaymentRejected;

  const PaymentDetailsModal({
    super.key,
    required this.payment,
    this.onPaymentApproved,
    this.onPaymentRejected,
  });

  @override
  State<PaymentDetailsModal> createState() => _PaymentDetailsModalState();
}

class _PaymentDetailsModalState extends State<PaymentDetailsModal> {
  @override
  void initState() {
    super.initState();
    // Load user penalties for FIFO calculation
    context.read<PenaltyBloc>().add(
          LoadUnpaidPenaltiesRequested(widget.payment.userId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: BlocBuilder<PenaltyBloc, PenaltyState>(
                builder: (context, state) {
                  if (state is PenaltyLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is UnpaidPenaltiesLoaded) {
                    return _buildContent(
                      context,
                      state.penalties,
                      state.balance,
                    );
                  }

                  if (state is PenaltyError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading penalty data',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Loading payment details...'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<PenaltyEntity> penalties,
    PenaltyBalanceEntity balance,
  ) {
    final distribution = FifoPaymentDistribution.calculate(
      paymentAmount: widget.payment.amount,
      currentBalance: balance.totalBalance,
      unpaidPenalties: penalties,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information Section
          _buildSection(
            context,
            icon: Icons.person,
            title: 'USER INFORMATION',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Name', widget.payment.userName ?? 'Unknown'),
                const SizedBox(height: 8),
                _buildInfoRow('Email', widget.payment.userEmail ?? 'N/A'),
                const SizedBox(height: 8),
                _buildInfoRow('User ID', widget.payment.userId),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Payment Details Section
          _buildSection(
            context,
            icon: Icons.payment,
            title: 'PAYMENT DETAILS',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Amount',
                  widget.payment.formattedAmount,
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Method',
                  widget.payment.paymentMethodName ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Reference',
                  widget.payment.referenceNumber ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Type',
                  widget.payment.amount >= balance.totalBalance
                      ? 'Full Payment'
                      : 'Partial Payment',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Submitted',
                  DateFormat('MMM dd, yyyy - hh:mm a')
                      .format(widget.payment.createdAt),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Balance Information Section
          _buildSection(
            context,
            icon: Icons.account_balance_wallet,
            title: 'BALANCE INFORMATION',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Current Balance',
                  '${balance.totalBalance.toStringAsFixed(0)} Shillings',
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'After Payment',
                  distribution.formattedNewBalance,
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: distribution.newBalance > 0
                        ? Colors.orange[700]
                        : Colors.green[700],
                  ),
                ),
                const SizedBox(height: 16),

                // Penalty breakdown
                if (penalties.isNotEmpty) ...[
                  Text(
                    'Penalty Breakdown (FIFO):',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: PenaltyBreakdownList(
                        penalties: penalties.take(5).toList(),
                      ),
                    ),
                  ),
                  if (penalties.length > 5) ...[
                    const SizedBox(height: 8),
                    Text(
                      '+ ${penalties.length - 5} more penalties',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // FIFO Payment Distribution Preview
          FifoPreviewPanel(distribution: distribution),

          const SizedBox(height: 24),

          // Action Buttons
          if (widget.payment.status.isPending) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject Payment'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[300]!, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.payment.status.isApproved
                    ? Colors.green[50]
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.payment.status.isApproved
                      ? Colors.green[300]!
                      : Colors.red[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.payment.status.isApproved
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: widget.payment.status.isApproved
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.payment.status.isApproved
                          ? 'Payment Already Approved'
                          : 'Payment Already Rejected',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.payment.status.isApproved
                            ? Colors.green[900]
                            : Colors.red[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PaymentBloc>(),
        child: ApprovePaymentDialog(
          payment: widget.payment,
          onApprove: (notes) {
            Navigator.of(dialogContext).pop(); // Close approve dialog
            Navigator.of(context).pop(); // Close details modal
            widget.onPaymentApproved?.call();
          },
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PaymentBloc>(),
        child: RejectPaymentDialog(
          payment: widget.payment,
          onReject: (reason) {
            Navigator.of(dialogContext).pop(); // Close reject dialog
            Navigator.of(context).pop(); // Close details modal
            widget.onPaymentRejected?.call();
          },
        ),
      ),
    );
  }
}
