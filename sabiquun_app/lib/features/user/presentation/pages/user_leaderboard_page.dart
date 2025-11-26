import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/supervisor/presentation/bloc/supervisor_bloc.dart';
import 'package:sabiquun_app/features/supervisor/presentation/bloc/supervisor_event.dart';
import 'package:sabiquun_app/features/supervisor/presentation/bloc/supervisor_state.dart';
import 'package:sabiquun_app/features/supervisor/domain/entities/leaderboard_entry_entity.dart';

/// Beautiful Interactive Leaderboard Page for Regular Users
/// Shows anonymized leaderboard with nicknames for privacy
class UserLeaderboardPage extends StatefulWidget {
  const UserLeaderboardPage({super.key});

  @override
  State<UserLeaderboardPage> createState() => _UserLeaderboardPageState();
}

class _UserLeaderboardPageState extends State<UserLeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentPeriod = 'weekly';
  String? _currentUserId;

  final List<String> _periods = ['daily', 'weekly', 'monthly', 'all-time'];
  final List<String> _periodLabels = ['Daily', 'Weekly', 'Monthly', 'All Time'];
  final List<IconData> _periodIcons = [
    Icons.today,
    Icons.calendar_view_week,
    Icons.calendar_month,
    Icons.emoji_events,
  ];

  // Nickname generation lists
  static const List<String> _adjectives = [
    'Swift', 'Brave', 'Wise', 'Noble', 'Mighty', 'Calm', 'Bold', 'Kind',
    'Pure', 'Bright', 'Strong', 'Gentle', 'Devoted', 'Faithful', 'Patient',
    'Humble', 'Graceful', 'Radiant', 'Steadfast', 'Resilient', 'Victorious',
    'Blessed', 'Sincere', 'Compassionate', 'Determined', 'Fearless'
  ];

  static const List<String> _nouns = [
    'Lion', 'Eagle', 'Falcon', 'Tiger', 'Wolf', 'Bear', 'Phoenix', 'Dragon',
    'Warrior', 'Knight', 'Guardian', 'Champion', 'Seeker', 'Traveler',
    'Scholar', 'Believer', 'Pilgrim', 'Sage', 'Hero', 'Pioneer', 'Explorer',
    'Defender', 'Achiever', 'Aspirant', 'Devotee', 'Striver'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);

    // Get current user ID
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }

    _loadLeaderboard();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentPeriod = _periods[_tabController.index];
        });
        HapticFeedback.selectionClick();
        _loadLeaderboard();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLeaderboard() {
    context.read<SupervisorBloc>().add(LoadLeaderboardRequested(
          period: _currentPeriod,
          limit: 100,
        ));
  }

  String _generateNickname(String userId) {
    // Generate deterministic nickname based on user ID
    final random = Random(userId.hashCode);
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final noun = _nouns[random.nextInt(_nouns.length)];
    return '$adjective $noun';
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppColors.primary;
  }

  IconData _getRankIcon(int rank) {
    if (rank <= 3) return Icons.emoji_events;
    if (rank <= 10) return Icons.star;
    return Icons.trending_up;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.go('/home');
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
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
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      top: 40,
                      right: -20,
                      child: Icon(
                        Icons.emoji_events,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -30,
                      child: Icon(
                        Icons.leaderboard,
                        size: 120,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: List.generate(
                    _periodLabels.length,
                    (index) => Tab(
                      icon: Icon(_periodIcons[index], size: 20),
                      text: _periodLabels[index],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                _loadLeaderboard();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: BlocBuilder<SupervisorBloc, SupervisorState>(
                builder: (context, state) {
                  if (state is SupervisorLoading) {
                    return _buildLoadingState();
                  }

                  if (state is SupervisorError) {
                    return _buildErrorState(state.message);
                  }

                  if (state is LeaderboardLoaded) {
                    if (state.leaderboard.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildLeaderboard(state.leaderboard);
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading rankings...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _loadLeaderboard();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Rankings Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start submitting your daily deeds\nto appear on the leaderboard!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(List<LeaderboardEntryEntity> entries) {
    // Find current user's position
    final currentUserIndex = entries.indexWhere((e) => e.userId == _currentUserId);
    final currentUserEntry = currentUserIndex != -1 ? entries[currentUserIndex] : null;

    return Column(
      children: [
        // Top 3 Podium
        if (entries.length >= 3) _buildPodium(entries.take(3).toList()),

        const SizedBox(height: 16),

        // Current User Sticky Card
        if (currentUserEntry != null) _buildCurrentUserCard(currentUserEntry),

        const SizedBox(height: 8),

        // Rest of the list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isCurrentUser = entry.userId == _currentUserId;

            return _buildLeaderboardCard(
              entry,
              isCurrentUser: isCurrentUser,
              index: index,
            );
          },
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPodium(List<LeaderboardEntryEntity> topThree) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            Colors.amber.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Trophy header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 40,
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Top Performers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Podium arrangement: 2nd, 1st, 3rd
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length > 1)
                _buildPodiumPlace(topThree[1], 2, height: 100),
              if (topThree.isNotEmpty)
                _buildPodiumPlace(topThree[0], 1, height: 130),
              if (topThree.length > 2)
                _buildPodiumPlace(topThree[2], 3, height: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    LeaderboardEntryEntity entry,
    int rank, {
    required double height,
  }) {
    final isCurrentUser = entry.userId == _currentUserId;
    final rankColor = _getRankColor(rank);

    return Column(
      children: [
        // Avatar/Icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                rankColor,
                rankColor.withValues(alpha: 0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: rankColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isCurrentUser
                ? const Icon(Icons.person, size: 32, color: Colors.white)
                : Icon(
                    _getRankIcon(rank),
                    size: 32,
                    color: Colors.white,
                  ),
          ),
        ),
        const SizedBox(height: 8),

        // Name
        SizedBox(
          width: 100,
          child: Text(
            isCurrentUser ? 'You' : _generateNickname(entry.userId),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
              color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Score
        Text(
          entry.averageDeeds.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: rankColor,
          ),
        ),
        const SizedBox(height: 8),

        // Podium
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                rankColor.withValues(alpha: 0.8),
                rankColor.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(
              color: rankColor,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserCard(LeaderboardEntryEntity entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  _getRankIcon(entry.rank),
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '#${entry.rank}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Ranking',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Keep up the great work!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.averageDeeds.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'avg deeds',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(
    LeaderboardEntryEntity entry, {
    required bool isCurrentUser,
    required int index,
  }) {
    final rankColor = _getRankColor(entry.rank);
    final isTopTen = entry.rank <= 10;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentUser
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            width: isCurrentUser ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrentUser
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: isTopTen
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          rankColor,
                          rankColor.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: isTopTen ? null : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getRankIcon(entry.rank),
                    size: 20,
                    color: isTopTen ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.rank}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isTopTen ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentUser ? 'You' : _generateNickname(entry.userId),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isCurrentUser
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.currentStreak} day streak',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.complianceRate.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.averageDeeds.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? AppColors.primary : rankColor,
                  ),
                ),
                Text(
                  'avg deeds',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
