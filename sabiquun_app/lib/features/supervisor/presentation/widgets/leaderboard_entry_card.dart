import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';

/// Leaderboard entry card widget
class LeaderboardEntryCard extends StatelessWidget {
  final LeaderboardEntryEntity entry;
  final VoidCallback onTap;

  const LeaderboardEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  Color _getMembershipColor() {
    switch (entry.membershipStatus.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'exclusive':
        return Colors.purple;
      case 'legacy':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getMembershipIcon() {
    switch (entry.membershipStatus.toLowerCase()) {
      case 'new':
        return Icons.star_border;
      case 'exclusive':
        return Icons.diamond_outlined;
      case 'legacy':
        return Icons.emoji_events_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Widget _buildRankBadge() {
    if (entry.rank <= 3) {
      // Medal for top 3
      final medals = ['🥇', '🥈', '🥉'];
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: entry.rank == 1
                ? [Colors.amber.shade300, Colors.amber.shade600]
                : entry.rank == 2
                    ? [Colors.grey.shade300, Colors.grey.shade500]
                    : [Colors.orange.shade300, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            medals[entry.rank - 1],
            style: const TextStyle(fontSize: 28),
          ),
        ),
      );
    } else {
      // Number for others
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '#${entry.rank}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTopThree = entry.rank <= 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isTopThree ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isTopThree
            ? BorderSide(
                color: entry.rank == 1
                    ? Colors.amber.withOpacity(0.5)
                    : entry.rank == 2
                        ? Colors.grey.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.5),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank Badge
              _buildRankBadge(),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getMembershipIcon(),
                          size: 12,
                          color: _getMembershipColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.membershipStatus,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getMembershipColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (entry.hasFajrChampion) ...[
                          const SizedBox(width: 8),
                          const Text('🌅', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 2),
                          const Text(
                            'Fajr',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStat(
                          '${entry.averageDeeds.toStringAsFixed(1)} avg',
                          Icons.assignment_turned_in_outlined,
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          '${(entry.complianceRate * 100).toStringAsFixed(0)}%',
                          Icons.check_circle_outline,
                        ),
                        if (entry.currentStreak > 0) ...[
                          const SizedBox(width: 16),
                          _buildStat(
                            '${entry.currentStreak}🔥',
                            Icons.local_fire_department_outlined,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
