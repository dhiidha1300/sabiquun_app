import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/home/widgets/enhanced_feature_card.dart';
import 'package:sabiquun_app/features/home/widgets/collapsible_deed_tracker.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_state.dart';

/// Cashier Home Content - Payment Management Dashboard
class CashierHomeContent extends StatefulWidget {
  final UserEntity user;

  const CashierHomeContent({
    super.key,
    required this.user,
  });

  @override
  State<CashierHomeContent> createState() => _CashierHomeContentState();
}

class _CashierHomeContentState extends State<CashierHomeContent> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load pending payments for cashier review
    context.read<PaymentBloc>().add(const LoadPendingPaymentsRequested());

    // Load recent approved payments
    context.read<PaymentBloc>().add(const LoadRecentApprovedPaymentsRequested(limit: 5));
  }

  Future<void> _onRefresh() async {
    _loadData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header with user profile
                _buildHeader(),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions Grid
                      _buildQuickActionsSection(),
                      const SizedBox(height: 20),

                      // Personal Deed Tracker (Collapsible)
                      const CollapsibleDeedTracker(),
                      const SizedBox(height: 20),

                      // Payment Overview Card
                      _buildPaymentOverviewCard(),
                      const SizedBox(height: 20),

                      // Recent Approved Payments Section
                      _buildRecentPaymentsSection(),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.user.initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Cashier',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification bell
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Navigate to notifications
                },
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickActionsGrid(),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        int pendingPaymentsCount = 0;

        if (state is PendingPaymentsLoaded) {
          pendingPaymentsCount = state.payments.length;
        }

        final actions = [
          _QuickAction(
            icon: Icons.pending_actions,
            title: 'Pending Payments',
            subtitle: 'Review now',
            color: Colors.orange,
            route: '/payment-review',
            badgeCount: pendingPaymentsCount,
            hasUrgentItem: pendingPaymentsCount > 5,
          ),
          _QuickAction(
            icon: Icons.history,
            title: 'All Payments',
            subtitle: 'View history',
            color: Colors.blue,
            route: '/payment-history',
          ),
          _QuickAction(
            icon: Icons.people_outline,
            title: 'User Balances',
            subtitle: 'Search users',
            color: Colors.purple,
            route: '/user-balances',
          ),
          _QuickAction(
            icon: Icons.analytics,
            title: 'Payment Analytics',
            subtitle: 'View reports',
            color: Colors.green,
            route: '/payment-analytics',
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return EnhancedFeatureCard(
              icon: action.icon,
              title: action.title,
              subtitle: action.subtitle,
              color: action.color,
              badgeCount: action.badgeCount,
              hasUrgentItem: action.hasUrgentItem,
              onTap: () => context.push(action.route),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOverviewCard() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        int pendingCount = 0;
        double pendingAmount = 0;

        if (state is PendingPaymentsLoaded) {
          pendingCount = state.payments.length;
          // Calculate total pending amount
          for (var payment in state.payments) {
            pendingAmount += payment.amount;
          }
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Payment Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pending Payments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Approvals',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF558B2F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$pendingCount payments',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Pending Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF558B2F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(pendingAmount)} Sh',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Divider
              Divider(color: Colors.green.shade300, thickness: 1),
              const SizedBox(height: 16),

              // Placeholder for total penalty (requires API)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Outstanding (All Users)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF558B2F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentPaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Approved Payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/payment-history'),
              child: const Row(
                children: [
                  Text('View All'),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecentPaymentsList(),
      ],
    );
  }

  Widget _buildRecentPaymentsList() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is RecentApprovedPaymentsLoaded) {
          final payments = state.payments;

          if (payments.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No recent payments',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Approved payments will appear here',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: payments.map((payment) => _buildPaymentItem(payment)).toList(),
          );
        }

        // Loading or initial state
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildPaymentItem(payment) {
    final date = DateFormat('MMM dd, yyyy').format(payment.createdAt);
    final time = DateFormat('HH:mm').format(payment.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Payment details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${NumberFormat('#,###').format(payment.amount)} Sh',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date at $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (payment.paymentMethod != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    payment.paymentMethod,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Approved',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for quick actions
class _QuickAction {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final String route;
  final int badgeCount;
  final bool hasUrgentItem;

  const _QuickAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.route,
    this.badgeCount = 0,
    this.hasUrgentItem = false,
  });
}
