import 'package:sabiquun_app/features/analytics/domain/entities/user_stats_entity.dart';
import 'package:sabiquun_app/features/analytics/domain/entities/monthly_report_entity.dart';
import 'package:sabiquun_app/features/analytics/domain/entities/deed_performance_entity.dart';

/// Analytics repository interface
abstract class AnalyticsRepository {
  /// Get overall user statistics
  Future<UserStatsEntity> getUserStats(String userId);

  /// Get monthly report statistics for the last N months
  Future<List<MonthlyReportEntity>> getMonthlyReports({
    required String userId,
    int months = 6,
  });

  /// Get performance statistics for each deed
  Future<List<DeedPerformanceEntity>> getDeedPerformance(String userId);

  /// Get report submission calendar data (for heatmap)
  Future<Map<DateTime, int>> getReportCalendar({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
