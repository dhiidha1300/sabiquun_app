import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabiquun_app/features/deeds/domain/repositories/deed_repository.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';

class DeedBloc extends Bloc<DeedEvent, DeedState> {
  final DeedRepository _repository;

  DeedBloc(this._repository) : super(const DeedInitial()) {
    on<LoadDeedTemplatesRequested>(_onLoadDeedTemplatesRequested);
    on<LoadTodayReportRequested>(_onLoadTodayReportRequested);
    on<LoadMyReportsRequested>(_onLoadMyReportsRequested);
    on<LoadAllReportsRequested>(_onLoadAllReportsRequested);
    on<LoadReportByIdRequested>(_onLoadReportByIdRequested);
    on<CreateDeedReportRequested>(_onCreateDeedReportRequested);
    on<UpdateDeedReportRequested>(_onUpdateDeedReportRequested);
    on<SubmitDeedReportRequested>(_onSubmitDeedReportRequested);
    on<DeleteDeedReportRequested>(_onDeleteDeedReportRequested);
    on<ApproveDeedReportRequested>(_onApproveDeedReportRequested);
    on<RejectDeedReportRequested>(_onRejectDeedReportRequested);
    on<ResetDeedStateRequested>(_onResetDeedStateRequested);
  }

  Future<void> _onLoadDeedTemplatesRequested(
    LoadDeedTemplatesRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final templates = await _repository.getDeedTemplates();
      emit(DeedTemplatesLoaded(templates));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onLoadTodayReportRequested(
    LoadTodayReportRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final templates = await _repository.getDeedTemplates();
      final report = await _repository.getTodayReport();
      emit(TodayReportLoaded(report: report, templates: templates));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onLoadMyReportsRequested(
    LoadMyReportsRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final reports = await _repository.getMyReports(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(MyReportsLoaded(reports));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onLoadAllReportsRequested(
    LoadAllReportsRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final reports = await _repository.getAllReports(
        startDate: event.startDate,
        endDate: event.endDate,
        userId: event.userId,
      );
      emit(AllReportsLoaded(reports));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onLoadReportByIdRequested(
    LoadReportByIdRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final templates = await _repository.getDeedTemplates();
      final report = await _repository.getReportById(event.reportId);
      emit(ReportDetailLoaded(report: report, templates: templates));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onCreateDeedReportRequested(
    CreateDeedReportRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final report = await _repository.createDeedReport(
        reportDate: event.reportDate,
        deedValues: event.deedValues,
        notes: event.notes,
      );
      emit(DeedReportCreated(report));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onUpdateDeedReportRequested(
    UpdateDeedReportRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final report = await _repository.updateDeedReport(
        reportId: event.reportId,
        deedValues: event.deedValues,
        notes: event.notes,
      );
      emit(DeedReportUpdated(report));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onSubmitDeedReportRequested(
    SubmitDeedReportRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final report = await _repository.submitDeedReport(event.reportId);
      emit(DeedReportSubmitted(report));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onDeleteDeedReportRequested(
    DeleteDeedReportRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      await _repository.deleteDeedReport(event.reportId);
      emit(const DeedReportDeleted());
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onApproveDeedReportRequested(
    ApproveDeedReportRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final report = await _repository.approveDeedReport(event.reportId);
      emit(DeedReportApproved(report));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onRejectDeedReportRequested(
    RejectDeedReportRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedLoading());
    try {
      final report = await _repository.rejectDeedReport(
        event.reportId,
        event.rejectionReason,
      );
      emit(DeedReportRejected(report));
    } catch (e) {
      emit(DeedError(e.toString()));
    }
  }

  Future<void> _onResetDeedStateRequested(
    ResetDeedStateRequested event,
    Emitter<DeedState> emit,
  ) async {
    emit(const DeedInitial());
  }
}
