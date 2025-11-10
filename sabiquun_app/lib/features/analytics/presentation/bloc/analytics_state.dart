import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/features/analytics/domain/entities/user_stats_entity.dart';
import 'package:sabiquun_app/features/analytics/domain/entities/monthly_report_entity.dart';
import 'package:sabiquun_app/features/analytics/domain/entities/deed_performance_entity.dart';

/// Analytics states
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// Loading state
class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

/// User stats loaded
class UserStatsLoaded extends AnalyticsState {
  final UserStatsEntity stats;

  const UserStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Monthly reports loaded
class MonthlyReportsLoaded extends AnalyticsState {
  final List<MonthlyReportEntity> reports;

  const MonthlyReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

/// Deed performance loaded
class DeedPerformanceLoaded extends AnalyticsState {
  final List<DeedPerformanceEntity> performance;

  const DeedPerformanceLoaded(this.performance);

  @override
  List<Object?> get props => [performance];
}

/// Report calendar loaded
class ReportCalendarLoaded extends AnalyticsState {
  final Map<DateTime, int> calendar;

  const ReportCalendarLoaded(this.calendar);

  @override
  List<Object?> get props => [calendar];
}

/// All analytics data loaded
class AllAnalyticsLoaded extends AnalyticsState {
  final UserStatsEntity stats;
  final List<MonthlyReportEntity> monthlyReports;
  final List<DeedPerformanceEntity> deedPerformance;

  const AllAnalyticsLoaded({
    required this.stats,
    required this.monthlyReports,
    required this.deedPerformance,
  });

  @override
  List<Object?> get props => [stats, monthlyReports, deedPerformance];
}

/// Error state
class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
