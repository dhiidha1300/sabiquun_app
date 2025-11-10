import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabiquun_app/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:sabiquun_app/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:sabiquun_app/features/analytics/presentation/bloc/analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository repository;

  AnalyticsBloc({required this.repository}) : super(const AnalyticsInitial()) {
    on<LoadUserStatsRequested>(_onLoadUserStatsRequested);
    on<LoadMonthlyReportsRequested>(_onLoadMonthlyReportsRequested);
    on<LoadDeedPerformanceRequested>(_onLoadDeedPerformanceRequested);
    on<LoadReportCalendarRequested>(_onLoadReportCalendarRequested);
    on<LoadAllAnalyticsRequested>(_onLoadAllAnalyticsRequested);
  }

  Future<void> _onLoadUserStatsRequested(
    LoadUserStatsRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final stats = await repository.getUserStats(event.userId);
      emit(UserStatsLoaded(stats));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadMonthlyReportsRequested(
    LoadMonthlyReportsRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final reports = await repository.getMonthlyReports(
        userId: event.userId,
        months: event.months,
      );
      emit(MonthlyReportsLoaded(reports));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadDeedPerformanceRequested(
    LoadDeedPerformanceRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final performance = await repository.getDeedPerformance(event.userId);
      emit(DeedPerformanceLoaded(performance));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadReportCalendarRequested(
    LoadReportCalendarRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final calendar = await repository.getReportCalendar(
        userId: event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(ReportCalendarLoaded(calendar));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadAllAnalyticsRequested(
    LoadAllAnalyticsRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      // Load all data in parallel for better performance
      final results = await Future.wait([
        repository.getUserStats(event.userId),
        repository.getMonthlyReports(userId: event.userId, months: 6),
        repository.getDeedPerformance(event.userId),
      ]);

      emit(AllAnalyticsLoaded(
        stats: results[0] as dynamic,
        monthlyReports: results[1] as dynamic,
        deedPerformance: results[2] as dynamic,
      ));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
