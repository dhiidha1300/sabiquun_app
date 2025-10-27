import 'package:equatable/equatable.dart';

abstract class DeedEvent extends Equatable {
  const DeedEvent();

  @override
  List<Object?> get props => [];
}

/// Load deed templates
class LoadDeedTemplatesRequested extends DeedEvent {
  const LoadDeedTemplatesRequested();
}

/// Load today's report
class LoadTodayReportRequested extends DeedEvent {
  const LoadTodayReportRequested();
}

/// Load user's reports
class LoadMyReportsRequested extends DeedEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMyReportsRequested({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load all reports (supervisor/admin)
class LoadAllReportsRequested extends DeedEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;

  const LoadAllReportsRequested({
    this.startDate,
    this.endDate,
    this.userId,
  });

  @override
  List<Object?> get props => [startDate, endDate, userId];
}

/// Load a specific report by ID
class LoadReportByIdRequested extends DeedEvent {
  final String reportId;

  const LoadReportByIdRequested(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

/// Create a new deed report
class CreateDeedReportRequested extends DeedEvent {
  final DateTime reportDate;
  final Map<String, double> deedValues; // 0.0-1.0 for each deed

  const CreateDeedReportRequested({
    required this.reportDate,
    required this.deedValues,
  });

  @override
  List<Object?> get props => [reportDate, deedValues];
}

/// Update an existing deed report
class UpdateDeedReportRequested extends DeedEvent {
  final String reportId;
  final Map<String, double> deedValues; // 0.0-1.0 for each deed

  const UpdateDeedReportRequested({
    required this.reportId,
    required this.deedValues,
  });

  @override
  List<Object?> get props => [reportId, deedValues];
}

/// Submit a deed report
class SubmitDeedReportRequested extends DeedEvent {
  final String reportId;

  const SubmitDeedReportRequested(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

/// Delete a deed report
class DeleteDeedReportRequested extends DeedEvent {
  final String reportId;

  const DeleteDeedReportRequested(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

/// Reset state to initial
class ResetDeedStateRequested extends DeedEvent {
  const ResetDeedStateRequested();
}
