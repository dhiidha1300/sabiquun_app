/// Helper class for time-related operations in the home page
class TimeHelper {
  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Calculate remaining time until deadline (12 PM next day)
  /// Grace period: User can submit today's report until 12 PM tomorrow
  static Duration getRemainingTime() {
    final now = DateTime.now();

    // Calculate deadline: 12 PM tomorrow
    DateTime deadline;
    if (now.hour < 12) {
      // If before noon today, deadline is today at 12 PM
      deadline = DateTime(now.year, now.month, now.day, 12, 0, 0);
    } else {
      // If after noon today, deadline is tomorrow at 12 PM
      deadline = DateTime(now.year, now.month, now.day + 1, 12, 0, 0);
    }

    return deadline.difference(now);
  }

  /// Format duration as "Xh Ym" or "Xm" if less than 1 hour
  static String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'Expired';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Format duration for display with "remaining" text
  static String formatRemainingTime(Duration duration) {
    if (duration.isNegative) {
      return 'Grace period expired';
    }

    return '${formatDuration(duration)} remaining';
  }

  /// Check if deadline is approaching (< 3 hours)
  static bool isDeadlineApproaching() {
    final remaining = getRemainingTime();
    return !remaining.isNegative && remaining.inHours < 3;
  }

  /// Check if deadline has passed
  static bool isDeadlinePassed() {
    return getRemainingTime().isNegative;
  }

  /// Get current date formatted as "Day, Month DD, YYYY"
  static String getCurrentDateFormatted() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];

    return '$weekday, $month ${now.day}, ${now.year}';
  }

  /// Get time of day for different UI states
  static TimeOfDay getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return TimeOfDay.morning;
    } else if (hour >= 12 && hour < 17) {
      return TimeOfDay.afternoon;
    } else if (hour >= 17 && hour < 21) {
      return TimeOfDay.evening;
    } else {
      return TimeOfDay.night;
    }
  }
}

/// Enum for time of day
enum TimeOfDay {
  morning,
  afternoon,
  evening,
  night,
}
