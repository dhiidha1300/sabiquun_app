import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_bloc.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_event.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_state.dart';
import 'package:sabiquun_app/features/home/utils/membership_helper.dart';
import 'package:sabiquun_app/features/home/utils/time_helper.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';

/// Normal User Home Content - Standard Dashboard
class UserHomeContent extends StatefulWidget {
  final UserEntity user;

  const UserHomeContent({
    super.key,
    required this.user,
  });

  @override
  State<UserHomeContent> createState() => _UserHomeContentState();
}

class _UserHomeContentState extends State<UserHomeContent> {
  // Cache data locally to persist across state changes
  DeedReportEntity? _todayReport;
  List<DeedReportEntity> _recentReports = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this screen
    _loadData();
  }

  void _loadData() {
    final userId = widget.user.id;

    // Load today's deeds report
    context.read<DeedBloc>().add(const LoadTodayReportRequested());

    // Load recent reports (last 30 days)
    context.read<DeedBloc>().add(LoadMyReportsRequested(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    ));

    // Load penalty balance
    context.read<PenaltyBloc>().add(LoadPenaltyBalanceRequested(userId));
  }

  Future<void> _onRefresh() async {
    _loadData();
    // Wait a bit for the data to load
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeedBloc, DeedState>(
      listener: (context, state) {
        // Cache data when it loads
        if (state is TodayReportLoaded) {
          setState(() {
            _todayReport = state.report;
          });
        } else if (state is MyReportsLoaded) {
          setState(() {
            _recentReports = state.reports;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _buildModernDrawer(),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header with user profile
                  _buildHeader(widget.user),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Penalty Balance Card
                        _buildPenaltyBalanceCard(),
                        const SizedBox(height: 16),

                        // Today's Progress Card
                        _buildTodayProgressCard(widget.user),
                        const SizedBox(height: 20),

                        // Recent Reports Section
                        _buildRecentReportsSection(),
                        const SizedBox(height: 100), // Space for floating bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70), // Lift above bottom nav
          child: FloatingActionButton(
            onPressed: () => context.push('/today-deeds'),
            backgroundColor: AppColors.success,
            child: const Icon(Icons.add, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserEntity user) {
    final membershipBadge = MembershipHelper.getBadge(user.createdAt ?? DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
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
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.menu_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar - Clickable
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
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
                  user.fullName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        membershipBadge.color.withValues(alpha: 0.15),
                        membershipBadge.color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: membershipBadge.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    membershipBadge.label,
                    style: TextStyle(
                      color: membershipBadge.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification bell
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
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyBalanceCard() {
    return BlocBuilder<PenaltyBloc, PenaltyState>(
      builder: (context, state) {
        double balance = 0;
        if (state is PenaltyBalanceLoaded) {
          balance = state.balance.balance;
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
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
              const Text(
                'Penalty Balance',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8D6E63),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${NumberFormat('#,###').format(balance)} Shillings',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await context.push('/submit-payment', extra: widget.user.id);
                    // If payment was submitted successfully, reload penalty balance
                    if (result == true && context.mounted) {
                      context.read<PenaltyBloc>().add(
                        LoadPenaltyBalanceRequested(widget.user.id),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayProgressCard(UserEntity user) {
    // Use cached data instead of BlocBuilder to prevent state loss
    double totalDeeds = 0;
    double faraid = 0;
    double sunnah = 0;
    bool isSubmitted = false;

    if (_todayReport != null) {
      isSubmitted = _todayReport!.status.isSubmitted;
      totalDeeds = _todayReport!.totalDeeds;
      faraid = _todayReport!.faraidCount;
      sunnah = _todayReport!.sunnahCount;
    }

    final double progress = totalDeeds / 10;
    final graceTime = TimeHelper.getRemainingTime();
    final isUrgent = graceTime.inHours < 3;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          const Text(
            'Today\'s Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Circular Progress
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSubmitted
                          ? AppColors.success
                          : (progress >= 0.7 ? AppColors.success : AppColors.accent),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: totalDeeds.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const TextSpan(
                            text: ' /10',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Deed breakdown
          Text(
            '${faraid.toStringAsFixed(1)}/5 Fara\'id | ${sunnah.toStringAsFixed(1)}/5 Sunnah',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          if (!isSubmitted) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isUrgent ? AppColors.error : AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Grace period ends in ${graceTime.inHours}h ${graceTime.inMinutes.remainder(60)}m',
                  style: TextStyle(
                    fontSize: 13,
                    color: isUrgent ? AppColors.error : AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitted ? null : () => context.push('/today-deeds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isSubmitted ? 'Report Submitted' : 'Submit Report',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsSection() {
    // Use cached data instead of BlocBuilder
    final reports = _recentReports.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/my-reports'),
              child: const Row(
                children: [
                  Text('View All Reports'),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (reports.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.description_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No reports yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ...reports.map((report) => _buildReportItem(report)),
      ],
    );
  }

  Widget _buildReportItem(DeedReportEntity report) {
    final date = DateFormat('MMM dd').format(report.reportDate);
    final score = report.totalDeeds;

    Color statusColor;
    String statusText;

    if (report.status.isSubmitted) {
      statusColor = AppColors.success;
      statusText = 'Submitted';
    } else {
      statusColor = Colors.grey;
      statusText = 'Draft';
    }

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
          // Date
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Text(
                  date.split(' ')[0],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  date.split(' ')[1],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${score.toStringAsFixed(1)}/10',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Completion percentage
          Text(
            '${score >= 10 ? '100' : (score * 10).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 13,
              color: score >= 8 ? AppColors.success : AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
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
                      widget.user.fullName.substring(0, 1).toUpperCase(),
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
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/home');
                  },
                  isSelected: true,
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_rounded,
                  title: 'Today\'s Deeds',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/today-deeds');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description_rounded,
                  title: 'My Reports',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/my-reports');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Payments',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/payment-history', extra: widget.user.id);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'Penalty History',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/penalty-history');
                  },
                ),
                const Divider(height: 24, thickness: 1),
                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to settings
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to help
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
                Navigator.pop(context);
                // Show confirmation dialog
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
      ),
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
