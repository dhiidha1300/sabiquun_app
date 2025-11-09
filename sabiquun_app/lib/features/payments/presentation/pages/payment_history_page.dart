import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/constants/payment_status.dart';
import 'package:sabiquun_app/features/home/widgets/main_scaffold.dart';

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

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
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
            if (state.payments.isEmpty) {
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
                itemCount: state.payments.length,
                itemBuilder: (context, index) {
                  return _buildPaymentCard(state.payments[index]);
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(payment.createdAt),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _buildStatusBadge(payment.status),
              ],
            ),
            const SizedBox(height: 12),

            // Amount
            Text(
              payment.formattedAmount,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(payment.status),
                  ),
            ),
            const SizedBox(height: 12),

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
                onPressed: () {
                  // TODO: Implement receipt download
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt download coming soon')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Receipt'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
