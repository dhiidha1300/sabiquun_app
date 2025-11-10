import 'package:equatable/equatable.dart';

/// Analytics events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Load user statistics
class LoadUserStatsRequested extends AnalyticsEvent {
  final String userId;

  const LoadUserStatsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load monthly reports
class LoadMonthlyReportsRequested extends AnalyticsEvent {
  final String userId;
  final int months;

  const LoadMonthlyReportsRequested({
    required this.userId,
    this.months = 6,
  });

  @override
  List<Object?> get props => [userId, months];
}

/// Load deed performance
class LoadDeedPerformanceRequested extends AnalyticsEvent {
  final String userId;

  const LoadDeedPerformanceRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load report calendar
class LoadReportCalendarRequested extends AnalyticsEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadReportCalendarRequested({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Load all analytics data
class LoadAllAnalyticsRequested extends AnalyticsEvent {
  final String userId;

  const LoadAllAnalyticsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
