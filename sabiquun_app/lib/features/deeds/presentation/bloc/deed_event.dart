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
  final Map<String, int> deedValues;
  final String? notes;

  const CreateDeedReportRequested({
    required this.reportDate,
    required this.deedValues,
    this.notes,
  });

  @override
  List<Object?> get props => [reportDate, deedValues, notes];
}

/// Update an existing deed report
class UpdateDeedReportRequested extends DeedEvent {
  final String reportId;
  final Map<String, int> deedValues;
  final String? notes;

  const UpdateDeedReportRequested({
    required this.reportId,
    required this.deedValues,
    this.notes,
  });

  @override
  List<Object?> get props => [reportId, deedValues, notes];
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

/// Approve a deed report (supervisor/admin)
class ApproveDeedReportRequested extends DeedEvent {
  final String reportId;

  const ApproveDeedReportRequested(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

/// Reject a deed report (supervisor/admin)
class RejectDeedReportRequested extends DeedEvent {
  final String reportId;
  final String rejectionReason;

  const RejectDeedReportRequested({
    required this.reportId,
    required this.rejectionReason,
  });

  @override
  List<Object?> get props => [reportId, rejectionReason];
}

/// Reset state to initial
class ResetDeedStateRequested extends DeedEvent {
  const ResetDeedStateRequested();
}
