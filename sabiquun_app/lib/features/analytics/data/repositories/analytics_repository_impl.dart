import 'package:sabiquun_app/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:sabiquun_app/features/analytics/domain/entities/user_stats_entity.dart';
import 'package:sabiquun_app/features/analytics/domain/entities/monthly_report_entity.dart';
import 'package:sabiquun_app/features/analytics/domain/entities/deed_performance_entity.dart';
import 'package:sabiquun_app/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserStatsEntity> getUserStats(String userId) async {
    try {
      final model = await remoteDataSource.getUserStats(userId);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MonthlyReportEntity>> getMonthlyReports({
    required String userId,
    int months = 6,
  }) async {
    try {
      final models = await remoteDataSource.getMonthlyReports(
        userId: userId,
        months: months,
      );
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DeedPerformanceEntity>> getDeedPerformance(String userId) async {
    try {
      final models = await remoteDataSource.getDeedPerformance(userId);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<DateTime, int>> getReportCalendar({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await remoteDataSource.getReportCalendar(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}
