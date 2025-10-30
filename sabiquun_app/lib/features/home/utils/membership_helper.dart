import 'package:flutter/material.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Helper class for membership status operations
class MembershipHelper {
  /// Get membership type based on account age
  static MembershipType getMembershipType(DateTime createdAt) {
    final duration = DateTime.now().difference(createdAt);

    if (duration.inDays <= 30) {
      return MembershipType.newMember;
    } else if (duration.inDays <= 1095) {
      // 3 years = 1095 days
      return MembershipType.exclusive;
    } else {
      return MembershipType.legacy;
    }
  }

  /// Get membership badge data
  static MembershipBadge getBadge(DateTime createdAt) {
    final type = getMembershipType(createdAt);
    final duration = DateTime.now().difference(createdAt);

    switch (type) {
      case MembershipType.newMember:
        final daysRemaining = 30 - duration.inDays;
        return MembershipBadge(
          icon: Icons.school,
          emoji: '🆕',
          label: 'New Member',
          subtitle: '$daysRemaining days remaining',
          description: 'Training period - No penalties',
          color: AppColors.info,
        );

      case MembershipType.exclusive:
        final daysSinceJoining = duration.inDays;
        final yearsActive = (daysSinceJoining / 365).floor();
        return MembershipBadge(
          icon: Icons.star,
          emoji: '⭐',
          label: 'Exclusive Member',
          subtitle: yearsActive > 0 ? '$yearsActive ${yearsActive == 1 ? 'year' : 'years'} active' : 'Active member',
          description: 'Full accountability',
          color: AppColors.success,
        );

      case MembershipType.legacy:
        final yearsActive = (duration.inDays / 365).floor();
        return MembershipBadge(
          icon: Icons.emoji_events,
          emoji: '👑',
          label: 'Legacy Member',
          subtitle: '$yearsActive+ years member',
          description: 'Long-term dedication',
          color: AppColors.accent,
        );
    }
  }

  /// Check if user is in training period (no penalties)
  static bool isInTrainingPeriod(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inDays < 30;
  }

  /// Get days remaining in training period
  static int getDaysRemainingInTraining(DateTime createdAt) {
    final daysSinceJoining = DateTime.now().difference(createdAt).inDays;
    if (daysSinceJoining >= 30) {
      return 0;
    }
    return 30 - daysSinceJoining;
  }

  /// Get membership status display text
  static String getMembershipStatusText(DateTime createdAt) {
    final type = getMembershipType(createdAt);
    switch (type) {
      case MembershipType.newMember:
        return 'Training Period';
      case MembershipType.exclusive:
        return 'Exclusive Member';
      case MembershipType.legacy:
        return 'Legacy Member';
    }
  }
}

/// Enum for membership types
enum MembershipType {
  newMember,
  exclusive,
  legacy,
}

/// Data class for membership badge information
class MembershipBadge {
  final IconData icon;
  final String emoji;
  final String label;
  final String subtitle;
  final String description;
  final Color color;

  MembershipBadge({
    required this.icon,
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
