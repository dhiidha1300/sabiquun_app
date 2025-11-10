import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/features/analytics/data/models/user_stats_model.dart';
import 'package:sabiquun_app/features/analytics/data/models/monthly_report_model.dart';
import 'package:sabiquun_app/features/analytics/data/models/deed_performance_model.dart';

class AnalyticsRemoteDataSource {
  final SupabaseClient _supabase;

  AnalyticsRemoteDataSource(this._supabase);

  /// Get overall user statistics
  Future<UserStatsModel> getUserStats(String userId) async {
    try {
      // For now, we'll calculate stats from reports
      // TODO: Create a database view or function for better performance

      final now = DateTime.now();
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final thisYearStart = DateTime(now.year, 1, 1);

      // Get all reports for the user
      final reportsResponse = await _supabase
          .from('deeds_reports')
          .select('report_date, status')
          .eq('user_id', userId)
          .order('report_date', ascending: false);

      final reports = reportsResponse as List;

      // Get penalties
      final penaltiesResponse = await _supabase
          .from('penalties')
          .select('amount')
          .eq('user_id', userId);

      final penalties = penaltiesResponse as List;

      // Get excuses
      final excusesResponse = await _supabase
          .from('excuses')
          .select('status')
          .eq('user_id', userId);

      final excuses = excusesResponse as List;

      // Calculate statistics
      final totalReports = reports.length;
      final thisMonthReports = reports
          .where((r) {
            final date = DateTime.parse(r['report_date']);
            return date.isAfter(thisMonthStart) || date.isAtSameMomentAs(thisMonthStart);
          })
          .length;

      final lastMonthReports = reports
          .where((r) {
            final date = DateTime.parse(r['report_date']);
            return date.isAfter(lastMonthStart) && date.isBefore(thisMonthStart);
          })
          .length;

      final thisYearReports = reports
          .where((r) {
            final date = DateTime.parse(r['report_date']);
            return date.isAfter(thisYearStart) || date.isAtSameMomentAs(thisYearStart);
          })
          .length;

      // Calculate streak (simplified version)
      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak = 0;
      DateTime? lastDate;

      for (var report in reports) {
        final reportDate = DateTime.parse(report['report_date']);

        if (lastDate == null) {
          tempStreak = 1;
        } else {
          final diff = lastDate.difference(reportDate).inDays;
          if (diff == 1) {
            tempStreak++;
          } else {
            if (tempStreak > longestStreak) longestStreak = tempStreak;
            tempStreak = 1;
          }
        }

        lastDate = reportDate;
      }

      if (tempStreak > longestStreak) longestStreak = tempStreak;

      // Current streak is the temp streak if last report was recent
      if (lastDate != null) {
        final daysSinceLastReport = DateTime.now().difference(lastDate).inDays;
        if (daysSinceLastReport <= 1) {
          currentStreak = tempStreak;
        }
      }

      // Calculate completion rate (simplified - assumes 1 report per day expected)
      final daysSinceJoining = DateTime.now().difference(thisYearStart).inDays + 1;
      final completionRate = daysSinceJoining > 0
          ? (thisYearReports / daysSinceJoining * 100).clamp(0.0, 100.0)
          : 0.0;

      // Penalty stats
      final totalPenalties = penalties.length;
      final totalPenaltyAmount = penalties.fold<double>(
        0.0,
        (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0.0),
      );

      // Excuse stats
      final totalExcuses = excuses.length;
      final approvedExcuses = excuses.where((e) => e['status'] == 'approved').length;
      final rejectedExcuses = excuses.where((e) => e['status'] == 'rejected').length;

      final lastReportDate = reports.isNotEmpty
          ? DateTime.parse(reports.first['report_date'])
          : DateTime.now();

      return UserStatsModel(
        userId: userId,
        totalReportsSubmitted: totalReports,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        thisMonthReports: thisMonthReports,
        lastMonthReports: lastMonthReports,
        thisYearReports: thisYearReports,
        completionRate: completionRate,
        totalPenalties: totalPenalties,
        totalPenaltyAmount: totalPenaltyAmount,
        totalExcuses: totalExcuses,
        approvedExcuses: approvedExcuses,
        rejectedExcuses: rejectedExcuses,
        lastReportDate: lastReportDate,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to fetch user stats: $e');
    }
  }

  /// Get monthly report statistics
  Future<List<MonthlyReportModel>> getMonthlyReports({
    required String userId,
    int months = 6,
  }) async {
    try {
      final now = DateTime.now();
      final List<MonthlyReportModel> monthlyReports = [];

      for (int i = 0; i < months; i++) {
        final month = now.month - i;
        final year = month > 0 ? now.year : now.year - 1;
        final adjustedMonth = month > 0 ? month : 12 + month;

        final monthStart = DateTime(year, adjustedMonth, 1);
        final monthEnd = DateTime(year, adjustedMonth + 1, 0);

        // Get reports for this month
        final reportsResponse = await _supabase
            .from('deeds_reports')
            .select('id')
            .eq('user_id', userId)
            .gte('report_date', monthStart.toIso8601String().split('T')[0])
            .lte('report_date', monthEnd.toIso8601String().split('T')[0]);

        final reports = (reportsResponse as List).length;

        // Get penalties for this month
        final penaltiesResponse = await _supabase
            .from('penalties')
            .select('amount')
            .eq('user_id', userId)
            .gte('created_at', monthStart.toIso8601String())
            .lt('created_at', DateTime(year, adjustedMonth + 1, 1).toIso8601String());

        final penalties = penaltiesResponse as List;
        final penaltyAmount = penalties.fold<double>(
          0.0,
          (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0.0),
        );

        // Expected reports (simplified - 1 per day)
        final daysInMonth = monthEnd.day;
        final expectedReports = daysInMonth;
        final completionRate = expectedReports > 0
            ? (reports / expectedReports * 100).clamp(0.0, 100.0)
            : 0.0;

        monthlyReports.add(MonthlyReportModel(
          year: year,
          month: adjustedMonth,
          reportsSubmitted: reports,
          expectedReports: expectedReports,
          completionRate: completionRate,
          penaltiesIncurred: penalties.length,
          penaltyAmount: penaltyAmount,
        ));
      }

      return monthlyReports;
    } catch (e) {
      throw Exception('Failed to fetch monthly reports: $e');
    }
  }

  /// Get deed performance statistics
  Future<List<DeedPerformanceModel>> getDeedPerformance(String userId) async {
    try {
      // Get all deed templates
      final templatesResponse = await _supabase
          .from('deed_templates')
          .select('id, deed_name')
          .eq('is_active', true);

      final templates = templatesResponse as List;

      // Get all reports for the user
      final reportsResponse = await _supabase
          .from('deeds_reports')
          .select('id, report_date')
          .eq('user_id', userId)
          .eq('status', 'submitted');

      final reports = reportsResponse as List;

      // Calculate performance for each deed
      final List<DeedPerformanceModel> performances = [];

      // If no reports, return empty performance for all deeds
      if (reports.isEmpty) {
        for (var template in templates) {
          final deedName = template['deed_name'] as String;
          performances.add(DeedPerformanceModel(
            deedName: deedName,
            totalSubmitted: 0,
            totalMissed: 0,
            completionRate: 0.0,
            currentStreak: 0,
            longestStreak: 0,
          ));
        }
        return performances;
      }

      final reportIds = reports.map((r) => r['id']).toList();

      for (var template in templates) {
        final deedName = template['deed_name'] as String;
        final templateId = template['id'] as String;

        // Count how many times this deed was completed
        final entriesResponse = await _supabase
            .from('deed_entries')
            .select('report_id, deed_value')
            .eq('deed_template_id', templateId)
            .inFilter('report_id', reportIds);

        final entries = entriesResponse as List;

        // Count entries where deed_value > 0
        final totalSubmitted = entries.where((e) =>
          (e['deed_value'] as num?) != null && (e['deed_value'] as num) > 0
        ).length;

        final totalReports = reports.length;
        final totalMissed = totalReports - totalSubmitted;
        final completionRate = totalReports > 0
            ? (totalSubmitted / totalReports * 100).clamp(0.0, 100.0)
            : 0.0;

        // TODO: Calculate actual streaks from report dates
        final currentStreak = 0;
        final longestStreak = 0;

        performances.add(DeedPerformanceModel(
          deedName: deedName,
          totalSubmitted: totalSubmitted,
          totalMissed: totalMissed,
          completionRate: completionRate,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
        ));
      }

      return performances;
    } catch (e) {
      throw Exception('Failed to fetch deed performance: $e');
    }
  }

  /// Get report calendar data
  Future<Map<DateTime, int>> getReportCalendar({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final reportsResponse = await _supabase
          .from('deeds_reports')
          .select('report_date, total_deeds')
          .eq('user_id', userId)
          .gte('report_date', startDate.toIso8601String().split('T')[0])
          .lte('report_date', endDate.toIso8601String().split('T')[0]);

      final reports = reportsResponse as List;

      final Map<DateTime, int> calendar = {};

      for (var report in reports) {
        final date = DateTime.parse(report['report_date']);
        final totalDeeds = ((report['total_deeds'] as num?)?.toInt() ?? 0);
        calendar[date] = totalDeeds;
      }

      return calendar;
    } catch (e) {
      throw Exception('Failed to fetch report calendar: $e');
    }
  }
}
