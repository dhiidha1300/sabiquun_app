import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/home/utils/membership_helper.dart';
import 'package:sabiquun_app/features/home/utils/time_helper.dart';
import 'package:sabiquun_app/features/home/widgets/enhanced_feature_card.dart';
import 'package:sabiquun_app/features/home/widgets/enhanced_profile_menu.dart';
import 'package:sabiquun_app/features/home/widgets/home_statistics_card.dart';
import 'package:sabiquun_app/features/home/widgets/onboarding_card.dart';
import 'package:sabiquun_app/features/home/widgets/quick_stats_bar.dart';
import 'package:sabiquun_app/features/home/widgets/recent_activity_card.dart';
import 'package:sabiquun_app/features/home/widgets/shimmer_loading.dart';
import 'package:sabiquun_app/shared/services/permission_service.dart';

/// Enhanced Main Home Page with comprehensive UI/UX improvements
class EnhancedHomePage extends StatefulWidget {
  const EnhancedHomePage({super.key});

  @override
  State<EnhancedHomePage> createState() => _EnhancedHomePageState();
}

class _EnhancedHomePageState extends State<EnhancedHomePage> {
  bool _isLoading = false;
  bool _showFAB = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // TODO: Load data from BLoCs here
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Hide FAB when scrolling down, show when scrolling up
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showFAB) setState(() => _showFAB = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showFAB) setState(() => _showFAB = true);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulate loading data
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Actually load data from BLoCs
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final permissions = PermissionService(user);

        return Scaffold(
          appBar: _buildAppBar(user),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: _buildBody(user, permissions),
          ),
          floatingActionButton: _buildFAB(user),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(UserEntity user) {
    // Mock data - replace with actual data from BLoCs
    final penaltyBalance = 125000.0; // TODO: Load from PenaltyBloc
    final profileCompletion = 100; // TODO: Calculate based on user profile
    final unreadNotifications = 0; // TODO: Load from NotificationBloc

    return AppBar(
      title: const Text('Sabiquun'),
      actions: [
        EnhancedProfileMenu(
          user: user,
          penaltyBalance: penaltyBalance,
          profileCompletionPercentage: profileCompletion,
          unreadNotifications: unreadNotifications,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(UserEntity user, PermissionService permissions) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header with Greeting
          _buildWelcomeHeader(user),
          const SizedBox(height: 16),

          // Onboarding Card (for new members)
          _buildOnboardingSection(user),

          // Quick Stats Bar
          _buildQuickStatsSection(user),
          const SizedBox(height: 20),

          // Statistics Dashboard Card
          _buildStatisticsSection(user),
          const SizedBox(height: 20),

          // Recent Activity Section
          _buildRecentActivitySection(),
          const SizedBox(height: 20),

          // Feature Cards Grid
          _buildFeatureCardsSection(user, permissions),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(UserEntity user) {
    final greeting = TimeHelper.getGreeting();
    final currentDate = TimeHelper.getCurrentDateFormatted();
    final membershipBadge = MembershipHelper.getBadge(user.createdAt ?? DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Membership Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: membershipBadge.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: membershipBadge.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    membershipBadge.icon,
                    size: 16,
                    color: membershipBadge.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    membershipBadge.label,
                    style: TextStyle(
                      color: membershipBadge.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          currentDate,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildOnboardingSection(UserEntity user) {
    final membershipType = MembershipHelper.getMembershipType(user.createdAt ?? DateTime.now());
    final isNewMember = membershipType == MembershipType.newMember;

    if (!isNewMember) {
      return const SizedBox.shrink();
    }

    final daysRemaining = MembershipHelper.getDaysRemainingInTraining(user.createdAt ?? DateTime.now());

    return Column(
      children: [
        OnboardingCard(
          userName: user.fullName.split(' ').first,
          isNewMember: true,
          daysRemaining: daysRemaining,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuickStatsSection(UserEntity user) {
    // Mock data - replace with actual data from BLoCs
    final completionStreak = 0; // TODO: Calculate from DeedBloc
    final monthlyDeedsCompleted = 0; // TODO: Load from DeedBloc
    final monthlyDeedsTarget = DateTime.now().day * 10; // Days this month × 10
    final pendingApprovals = user.isAdmin || user.isSupervisor || user.isCashier ? null : null;

    return QuickStatsBar(
      completionStreak: completionStreak,
      currentRank: null, // Not implemented yet
      totalUsers: null, // Not implemented yet
      monthlyDeedsCompleted: monthlyDeedsCompleted,
      monthlyDeedsTarget: monthlyDeedsTarget,
      pendingApprovals: pendingApprovals,
    );
  }

  Widget _buildStatisticsSection(UserEntity user) {
    // Mock data - replace with actual data from BLoCs
    final todayDeedsCompleted = 0; // TODO: Load from DeedBloc
    final todayDeedsTarget = 10;
    final isTodayReportSubmitted = false; // TODO: Load from DeedBloc
    final penaltyBalance = 125000.0; // TODO: Load from PenaltyBloc
    final monthlyDeedsCompleted = 0; // TODO: Load from DeedBloc
    final monthlyDeedsTarget = DateTime.now().day * 10;

    return HomeStatisticsCard(
      todayDeedsCompleted: todayDeedsCompleted,
      todayDeedsTarget: todayDeedsTarget,
      isTodayReportSubmitted: isTodayReportSubmitted,
      penaltyBalance: penaltyBalance,
      monthlyDeedsCompleted: monthlyDeedsCompleted,
      monthlyDeedsTarget: monthlyDeedsTarget,
      userId: user.id,
    );
  }

  Widget _buildRecentActivitySection() {
    // Mock data - replace with actual data from BLoCs
    final activities = <ActivityItem>[
      // TODO: Load actual activities from various BLoCs
    ];

    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return RecentActivityCard(activities: activities);
  }

  Widget _buildFeatureCardsSection(UserEntity user, PermissionService permissions) {
    final cards = _buildPrioritizedFeatureCards(user, permissions);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  List<Widget> _buildPrioritizedFeatureCards(UserEntity user, PermissionService permissions) {
    final cards = <Widget>[];

    // Common features for all users
    cards.add(
      EnhancedFeatureCard(
        icon: Icons.event_note,
        title: 'Today\'s Deeds',
        subtitle: 'Submit daily report',
        color: AppColors.accent,
        onTap: () => context.push('/today-deeds'),
        hasUrgentItem: !_isTodayReportSubmitted(),
      ),
    );

    cards.add(
      EnhancedFeatureCard(
        icon: Icons.library_books,
        title: 'My Reports',
        subtitle: 'View submission history',
        color: AppColors.primary,
        onTap: () => context.push('/my-reports'),
      ),
    );

    cards.add(
      EnhancedFeatureCard(
        icon: Icons.account_balance_wallet,
        title: 'Penalty History',
        subtitle: 'Track penalties',
        color: Colors.deepOrange,
        onTap: () {
          final state = context.read<AuthBloc>().state;
          if (state is Authenticated) {
            context.push('/penalty-history', extra: state.user.id);
          }
        },
      ),
    );

    cards.add(
      EnhancedFeatureCard(
        icon: Icons.payment,
        title: 'Submit Payment',
        subtitle: 'Pay penalties',
        color: AppColors.success,
        onTap: () {
          final state = context.read<AuthBloc>().state;
          if (state is Authenticated) {
            context.push('/submit-payment', extra: state.user.id);
          }
        },
      ),
    );

    cards.add(
      EnhancedFeatureCard(
        icon: Icons.history,
        title: 'Payment History',
        subtitle: 'View payments',
        color: AppColors.info,
        onTap: () {
          final state = context.read<AuthBloc>().state;
          if (state is Authenticated) {
            context.push('/payment-history', extra: state.user.id);
          }
        },
      ),
    );

    cards.add(
      EnhancedFeatureCard(
        icon: Icons.medical_services,
        title: 'Excuses',
        subtitle: 'Submit excuse request',
        color: AppColors.warning,
        onTap: () => context.push('/excuses'),
      ),
    );

    // Role-specific features
    if (permissions.canApproveUsers()) {
      cards.add(
        EnhancedFeatureCard(
          icon: Icons.people,
          title: 'User Management',
          subtitle: 'Manage users',
          color: AppColors.adminColor,
          onTap: () => context.push('/user-management'),
        ),
      );
    }

    if (permissions.canViewAllReports()) {
      cards.add(
        EnhancedFeatureCard(
          icon: Icons.assessment,
          title: 'Analytics',
          subtitle: 'View insights',
          color: AppColors.supervisorColor,
          onTap: () => context.push('/analytics'),
        ),
      );
    }

    if (permissions.canViewAllPayments()) {
      cards.add(
        EnhancedFeatureCard(
          icon: Icons.account_balance,
          title: 'Payment Review',
          subtitle: 'Review payments',
          color: AppColors.cashierColor,
          onTap: () => context.push('/payment-history'),
        ),
      );
    }

    return cards;
  }

  bool _isTodayReportSubmitted() {
    // TODO: Check from DeedBloc
    return false;
  }

  Widget? _buildFAB(UserEntity user) {
    if (!_showFAB || _isTodayReportSubmitted()) {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: () => context.push('/today-deeds'),
      icon: const Icon(Icons.add_task),
      label: const Text('Submit Deeds'),
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header shimmer
          const ShimmerBox(width: 200, height: 24),
          const SizedBox(height: 8),
          const ShimmerBox(width: 150, height: 32),
          const SizedBox(height: 20),

          // Quick stats shimmer
          SizedBox(
            height: 60,
            child: ShimmerLoading(
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    const ShimmerBox(width: 150, height: 50),
                    const SizedBox(width: 12),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Statistics card shimmer
          const StatisticsCardShimmer(),
          const SizedBox(height: 20),

          // Feature cards shimmer
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const FeatureCardShimmer(),
          ),
        ],
      ),
    );
  }
}
