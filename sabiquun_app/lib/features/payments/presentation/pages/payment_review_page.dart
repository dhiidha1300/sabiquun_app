import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/payments/domain/entities/payment_entity.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_state.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/payment_card.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/approve_payment_dialog.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/reject_payment_dialog.dart';

/// Payment Review Dashboard for Cashiers
/// Allows cashiers to review, approve, and reject pending payments
class PaymentReviewPage extends StatefulWidget {
  const PaymentReviewPage({super.key});

  @override
  State<PaymentReviewPage> createState() => _PaymentReviewPageState();
}

class _PaymentReviewPageState extends State<PaymentReviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<PaymentBloc>().add(const LoadPendingPaymentsRequested());
  }

  Future<void> _onRefresh() async {
    _loadData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showPaymentDetails(PaymentEntity payment) {
    // TODO: Show payment detail modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${NumberFormat('#,###').format(payment.amount)} Sh'),
            Text('Method: ${payment.paymentMethodName ?? 'N/A'}'),
            Text('Reference: ${payment.referenceNumber ?? 'None'}'),
            Text('Date: ${DateFormat('MMM dd, yyyy HH:mm').format(payment.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _approvePayment(PaymentEntity payment) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    showDialog(
      context: context,
      builder: (context) => ApprovePaymentDialog(
        payment: payment,
        onApprove: (notes) {
          context.read<PaymentBloc>().add(
                ApprovePaymentRequested(
                  paymentId: payment.id,
                  reviewedBy: authState.user.id,
                ),
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _rejectPayment(PaymentEntity payment) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    showDialog(
      context: context,
      builder: (context) => RejectPaymentDialog(
        payment: payment,
        onReject: (reason) {
          context.read<PaymentBloc>().add(
                RejectPaymentRequested(
                  paymentId: payment.id,
                  reviewedBy: authState.user.id,
                  reason: reason,
                ),
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Payment Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by user or reference...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                tabs: [
                  BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      int count = 0;
                      if (state is PendingPaymentsLoaded) {
                        count = state.payments.length;
                      }
                      return Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Pending'),
                            if (count > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const Tab(text: 'History'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentApproved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Payment approved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadData(); // Reload to update UI
          } else if (state is PaymentRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✗ Payment rejected'),
                backgroundColor: Colors.orange,
              ),
            );
            _loadData(); // Reload to update UI
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Pending Payments Tab
            _buildPendingTab(),
            // History Tab
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingPaymentsLoaded) {
            final payments = _filterPayments(state.payments);

            if (payments.isEmpty && _searchQuery.isEmpty) {
              return _buildEmptyState(
                icon: Icons.check_circle_outline,
                title: 'No Pending Payments',
                subtitle: 'All payments have been reviewed',
              );
            }

            if (payments.isEmpty) {
              return _buildEmptyState(
                icon: Icons.search_off,
                title: 'No Results Found',
                subtitle: 'Try adjusting your search',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return PaymentCard(
                  payment: payment,
                  onTap: () => _showPaymentDetails(payment),
                  onApprove: () => _approvePayment(payment),
                  onReject: () => _rejectPayment(payment),
                );
              },
            );
          }

          return _buildEmptyState(
            icon: Icons.pending_actions,
            title: 'Payment Review',
            subtitle: 'Pending payments will appear here',
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    // TODO: Load payment history with approved/rejected status
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Payment History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  List<PaymentEntity> _filterPayments(List<PaymentEntity> payments) {
    if (_searchQuery.isEmpty) return payments;

    return payments.where((payment) {
      final ref = payment.referenceNumber?.toLowerCase() ?? '';
      final method = payment.paymentMethodName?.toLowerCase() ?? '';
      // TODO: Add user name search when we have user data joined
      return ref.contains(_searchQuery) || method.contains(_searchQuery);
    }).toList();
  }
}
