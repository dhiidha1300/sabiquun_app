import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sabiquun_app/features/home/widgets/collapsible_deed_tracker.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_state.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_bloc.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_event.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_state.dart';
import 'package:sabiquun_app/features/notifications/presentation/widgets/notification_bell.dart';

/// Cashier Home Content - Payment Management Dashboard
class CashierHomeContent extends StatefulWidget {
  final UserEntity user;

  const CashierHomeContent({
    super.key,
    required this.user,
  });

  @override
  State<CashierHomeContent> createState() => CashierHomeContentState();
}

class CashierHomeContentState extends State<CashierHomeContent>
    with WidgetsBindingObserver, RouteAware, TickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  late Animation<double> _drawerSlideAnimation;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentFadeAnimation;
  bool _isDrawerOpen = false;

  // Expose animation controllers for overlay builder
  AnimationController get drawerAnimationController => _drawerAnimationController;
  AnimationController get fabAnimationController => _fabAnimationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize drawer animation
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _drawerSlideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize FAB animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    // Initialize content fade animation
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeIn,
    ));

    _loadData();

    // Trigger animations after short delays
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _fabAnimationController.dispose();
    _contentAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _drawerAnimationController.forward();
      } else {
        _drawerAnimationController.reverse();
      }
    });
  }

  void _closeDrawer() {
    if (_isDrawerOpen) {
      setState(() {
        _isDrawerOpen = false;
        _drawerAnimationController.reverse();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadData();
    }
  }

  void _loadData() {
    // Load pending payments for cashier review
    context.read<PaymentBloc>().add(const LoadPendingPaymentsRequested());

    // Load recent approved payments
    context.read<PaymentBloc>().add(const LoadRecentApprovedPaymentsRequested(limit: 5));

    // Load total outstanding balance for all users
    context.read<PenaltyBloc>().add(const LoadTotalOutstandingBalanceRequested());
  }

  Future<void> _onRefresh() async {
    _loadData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Close drawer if open, otherwise reload data
        if (!didPop) {
          if (_isDrawerOpen) {
            _closeDrawer();
          } else {
            _loadData();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header with user profile
                  _buildHeader(),

                  // Main content with fade animation
                  FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: Padding(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build overlay widgets (drawer, backdrop, FAB) that will be rendered above bottom nav
  Widget _buildOverlayElements() {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Semi-transparent backdrop when drawer is open (covers entire screen including bottom nav)
        if (_isDrawerOpen)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _closeDrawer,
              child: AnimatedOpacity(
                opacity: _isDrawerOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),

        // Animated drawer overlay (extends full height to cover bottom nav)
        _buildAnimatedDrawer(),

        // Floating Action Button for daily deeds (positioned above bottom nav)
        Positioned(
          right: 20,
          bottom: 100, // Above bottom nav
          child: ScaleTransition(
            scale: _fabScaleAnimation,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Navigate to daily deeds submission
                context.push('/today-deeds');
              },
              backgroundColor: AppColors.primary,
              elevation: 6,
              icon: const Icon(Icons.add_task, color: Colors.white),
              label: const Text(
                'Log Deeds',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build overlay widgets (drawer, backdrop, FAB) that will be rendered above bottom nav
  // This method is called from RoleBasedScaffold overlay parameter
  Widget buildOverlay(BuildContext context) {
    return _buildOverlayElements();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Row(
        children: [
          // Menu Icon
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _toggleDrawer,
              icon: Icon(
                Icons.menu_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User info with badge icon above name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge icon above name
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withValues(alpha: 0.2),
                        Colors.green.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 14,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                // Profile name
                Text(
                  widget.user.fullName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          // Notification bell
          NotificationBell(userId: widget.user.id),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        _buildModernQuickActions(),
      ],
    );
  }

  Widget _buildModernQuickActions() {
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

        return Column(
          children: actions.map((action) => _buildModernActionItem(action)).toList(),
        );
      },
    );
  }

  Widget _buildModernActionItem(_QuickAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(action.route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: action.color.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon with colored background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.color.withValues(alpha: 0.15),
                        action.color.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (action.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          action.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Badge or arrow
                if (action.badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: action.hasUrgentItem
                            ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
                            : [action.color, action.color.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (action.hasUrgentItem ? AppColors.error : action.color)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      action.badgeCount > 99 ? '99+' : '${action.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
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

              // Total outstanding balance (all users)
              BlocBuilder<PenaltyBloc, PenaltyState>(
                builder: (context, penaltyState) {
                  String totalOutstandingText = 'Loading...';

                  if (penaltyState is TotalOutstandingBalanceLoaded) {
                    totalOutstandingText = '${NumberFormat('#,###').format(penaltyState.totalBalance)} Sh';
                  } else if (penaltyState is PenaltyError) {
                    totalOutstandingText = 'Error';
                  }

                  return Row(
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
                        totalOutstandingText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: penaltyState is TotalOutstandingBalanceLoaded
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                },
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
                if (payment.paymentMethodName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    payment.paymentMethodName!,
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

// Add drawer methods at the end of CashierHomeContentState class
extension _CashierHomeContentDrawer on CashierHomeContentState {
  Widget _buildAnimatedDrawer() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      child: AnimatedBuilder(
        animation: _drawerSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_drawerSlideAnimation.value * 280, 0),
            child: Material(
              elevation: 16,
              color: AppColors.surface,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              child: SizedBox(
                width: 280,
                child: _buildDrawerContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerContent() {
    return Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.user.initials,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Cashier Features Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Text(
                    'CASHIER FEATURES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () {
                    _closeDrawer();
                    context.go('/home');
                  },
                  isSelected: true,
                ),
                _buildDrawerItem(
                  icon: Icons.pending_actions_rounded,
                  title: 'Pending Payments',
                  onTap: () {
                    _closeDrawer();
                    context.push('/payment-review');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'All Payments',
                  onTap: () {
                    _closeDrawer();
                    context.push('/payment-history', extra: widget.user.id);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.people_rounded,
                  title: 'User Balances',
                  onTap: () {
                    _closeDrawer();
                    context.push('/user-balances');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.analytics_rounded,
                  title: 'Payment Analytics',
                  onTap: () {
                    _closeDrawer();
                    context.push('/payment-analytics');
                  },
                ),

                // Personal Features Section
                const Divider(height: 24, thickness: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Text(
                    'MY FEATURES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.event_note_rounded,
                  title: 'My Daily Deeds',
                  onTap: () {
                    _closeDrawer();
                    context.push('/today-deeds');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'My Reports',
                  onTap: () {
                    _closeDrawer();
                    context.push('/my-reports');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'My Payments',
                  onTap: () {
                    _closeDrawer();
                    context.push('/payment-history', extra: widget.user.id);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.warning_amber_rounded,
                  title: 'My Penalties',
                  onTap: () {
                    _closeDrawer();
                    context.push('/penalty-history');
                  },
                ),

                // Other Options
                const Divider(height: 24, thickness: 1),
                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  onTap: () {
                    _closeDrawer();
                    context.push('/profile');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    _closeDrawer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings page coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                _closeDrawer();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(const LogoutRequested());
                          context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
