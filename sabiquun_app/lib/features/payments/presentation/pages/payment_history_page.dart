import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/fifo_payment_distribution.dart';
import '../../data/services/receipt_service.dart';
import '../../../../core/constants/payment_status.dart';
import 'package:sabiquun_app/features/home/widgets/role_based_scaffold.dart';

class PaymentHistoryPage extends StatefulWidget {
  final String userId;

  const PaymentHistoryPage({
    super.key,
    required this.userId,
  });

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  String? _selectedFilter;
  final ReceiptService _receiptService = ReceiptService();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    context.read<PaymentBloc>().add(LoadPaymentHistoryRequested(
          userId: widget.userId,
          statusFilter: _selectedFilter,
        ));
  }

  Future<void> _downloadReceipt(PaymentEntity payment) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // For approved payments, create a simplified distribution
      // The actual penalty applications were already done when payment was approved
      final distribution = FifoPaymentDistribution(
        paymentAmount: payment.amount,
        currentBalance: payment.amount, // Simplified - showing payment amount
        remainingPaymentAmount: 0, // Assume payment was fully applied
        applications: [], // Could be populated by fetching penalty_payments records
      );

      // Generate receipt
      final receiptNumber = _receiptService.generateReceiptNumber();
      final pdf = await _receiptService.generatePaymentReceipt(
        payment: payment,
        distribution: distribution,
        cashierName: payment.reviewerName ?? 'Cashier',
        receiptNumber: receiptNumber,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Share/download the PDF
      await _receiptService.sharePdf(pdf, receiptNumber);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Receipt downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleBasedScaffold(
      currentIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment History'),
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentHistoryLoaded) {
            // Apply filter if active
            final filteredPayments = _selectedFilter == null
                ? state.payments
                : state.payments.where((p) => p.status.name == _selectedFilter).toList();

            if (filteredPayments.isEmpty && _selectedFilter == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No payments found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your payment history will appear here',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }

            if (filteredPayments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_list_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No payments match your filter',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = null;
                        });
                        _loadPayments();
                      },
                      child: const Text('Clear Filter'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadPayments();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPayments.length,
                itemBuilder: (context, index) {
                  return _buildPaymentCard(filteredPayments[index]);
                },
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Load payment history'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPayments,
                  child: const Text('Load'),
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentEntity payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(payment.status).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Optional: Add tap animation or navigation to details
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Date and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(payment.createdAt),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(payment.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount
                Text(
                  payment.formattedAmount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: _getStatusColor(payment.status),
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(height: 16),

            // Payment Method
            if (payment.paymentMethodName != null) ...[
              Row(
                children: [
                  const Icon(Icons.payment, size: 16),
                  const SizedBox(width: 8),
                  Text(payment.paymentMethodName!),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Reference Number
            if (payment.referenceNumber != null) ...[
              Row(
                children: [
                  const Icon(Icons.tag, size: 16),
                  const SizedBox(width: 8),
                  Text('Ref: ${payment.referenceNumber}'),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Reviewed Info
            if (payment.reviewedBy != null) ...[
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 8),
                  Text('Reviewed by: ${payment.reviewerName ?? 'Admin'}'),
                ],
              ),
              if (payment.reviewedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(payment.reviewedAt!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ],

            // Rejection Reason
            if (payment.status.isRejected && payment.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: ${payment.rejectionReason}',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Download Receipt (if approved)
            if (payment.status.isApproved) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _downloadReceipt(payment),
                icon: const Icon(Icons.download),
                label: const Text('Download Receipt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  side: BorderSide(color: Colors.green[300]!),
                ),
              ),
            ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(status).withValues(alpha: 0.15),
            _getStatusColor(status).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.approved:
        return Colors.green;
      case PaymentStatus.rejected:
        return Colors.red;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Payments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedFilter = value;
                  });
                  _loadPayments();
                },
              ),
            ),
            ListTile(
              title: const Text('Pending'),
              leading: Radio<String?>(
                value: 'pending',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedFilter = value;
                  });
                  _loadPayments();
                },
              ),
            ),
            ListTile(
              title: const Text('Approved'),
              leading: Radio<String?>(
                value: 'approved',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedFilter = value;
                  });
                  _loadPayments();
                },
              ),
            ),
            ListTile(
              title: const Text('Rejected'),
              leading: Radio<String?>(
                value: 'rejected',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedFilter = value;
                  });
                  _loadPayments();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
