import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';

abstract class DeedState extends Equatable {
  const DeedState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DeedInitial extends DeedState {
  const DeedInitial();
}

/// Loading state
class DeedLoading extends DeedState {
  const DeedLoading();
}

/// Templates loaded
class DeedTemplatesLoaded extends DeedState {
  final List<DeedTemplateEntity> templates;

  const DeedTemplatesLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

/// Today's report loaded (or null if doesn't exist)
class TodayReportLoaded extends DeedState {
  final DeedReportEntity? report;
  final List<DeedTemplateEntity> templates;

  const TodayReportLoaded({
    this.report,
    required this.templates,
  });

  @override
  List<Object?> get props => [report, templates];
}

/// My reports loaded
class MyReportsLoaded extends DeedState {
  final List<DeedReportEntity> reports;

  const MyReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

/// All reports loaded (supervisor/admin)
class AllReportsLoaded extends DeedState {
  final List<DeedReportEntity> reports;

  const AllReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

/// Single report loaded
class ReportDetailLoaded extends DeedState {
  final DeedReportEntity report;
  final List<DeedTemplateEntity> templates;

  const ReportDetailLoaded({
    required this.report,
    required this.templates,
  });

  @override
  List<Object?> get props => [report, templates];
}

/// Report created successfully
class DeedReportCreated extends DeedState {
  final DeedReportEntity report;

  const DeedReportCreated(this.report);

  @override
  List<Object?> get props => [report];
}

/// Report updated successfully
class DeedReportUpdated extends DeedState {
  final DeedReportEntity report;

  const DeedReportUpdated(this.report);

  @override
  List<Object?> get props => [report];
}

/// Report submitted successfully
class DeedReportSubmitted extends DeedState {
  final DeedReportEntity report;

  const DeedReportSubmitted(this.report);

  @override
  List<Object?> get props => [report];
}

/// Report deleted successfully
class DeedReportDeleted extends DeedState {
  const DeedReportDeleted();
}

/// Error state
class DeedError extends DeedState {
  final String message;

  const DeedError(this.message);

  @override
  List<Object?> get props => [message];
}
