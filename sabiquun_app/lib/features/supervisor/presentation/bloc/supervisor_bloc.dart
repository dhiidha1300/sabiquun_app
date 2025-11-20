import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../../data/services/pdf_export_service.dart';
import '../../data/services/excel_export_service.dart';
import '../../data/models/detailed_report_model.dart';
import 'supervisor_event.dart';
import 'supervisor_state.dart';

/// Supervisor BLoC
class SupervisorBloc extends Bloc<SupervisorEvent, SupervisorState> {
  final SupervisorRepository repository;

  SupervisorBloc({required this.repository}) : super(const SupervisorInitial()) {
    on<LoadUserReportsRequested>(_onLoadUserReports);
    on<LoadLeaderboardRequested>(_onLoadLeaderboard);
    on<LoadUsersAtRiskRequested>(_onLoadUsersAtRisk);
    on<LoadUserDetailRequested>(_onLoadUserDetail);
    on<LoadAchievementTagsRequested>(_onLoadAchievementTags);
    on<AssignAchievementTagRequested>(_onAssignAchievementTag);
    on<RemoveAchievementTagRequested>(_onRemoveAchievementTag);
    on<CreateAchievementTagRequested>(_onCreateAchievementTag);
    on<UpdateAchievementTagRequested>(_onUpdateAchievementTag);
    on<DeleteAchievementTagRequested>(_onDeleteAchievementTag);
    on<LoadDetailedUserReportRequested>(_onLoadDetailedUserReportRequested);
    on<ExportUserReportRequested>(_onExportUserReportRequested);
  }

  Future<void> _onLoadUserReports(
    LoadUserReportsRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading());

    final result = await repository.getAllUserReports(
      searchQuery: event.searchQuery,
      membershipStatus: event.membershipStatus,
      complianceFilter: event.complianceFilter,
      reportStatus: event.reportStatus,
      sortBy: event.sortBy,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (userReports) => emit(UserReportsLoaded(userReports: userReports)),
    );
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboardRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading());

    final result = await repository.getLeaderboard(
      period: event.period,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (leaderboard) => emit(LeaderboardLoaded(
        leaderboard: leaderboard,
        period: event.period,
      )),
    );
  }

  Future<void> _onLoadUsersAtRisk(
    LoadUsersAtRiskRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading());

    final result = await repository.getUsersAtRisk(
      balanceThreshold: event.balanceThreshold,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (usersAtRisk) => emit(UsersAtRiskLoaded(usersAtRisk: usersAtRisk)),
    );
  }

  Future<void> _onLoadUserDetail(
    LoadUserDetailRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading());

    final result = await repository.getUserDetail(event.userId);

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (userDetail) => emit(UserDetailLoaded(userDetail: userDetail)),
    );
  }

  Future<void> _onLoadAchievementTags(
    LoadAchievementTagsRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading());

    final result = await repository.getAchievementTags();

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (tags) => emit(AchievementTagsLoaded(tags: tags)),
    );
  }

  Future<void> _onAssignAchievementTag(
    AssignAchievementTagRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    final result = await repository.assignAchievementTag(
      tagId: event.tagId,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (_) => emit(const AchievementTagAssigned(message: 'Achievement tag assigned successfully')),
    );
  }

  Future<void> _onRemoveAchievementTag(
    RemoveAchievementTagRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    final result = await repository.removeAchievementTag(
      tagId: event.tagId,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (_) => emit(const AchievementTagRemoved(message: 'Achievement tag removed successfully')),
    );
  }

  Future<void> _onCreateAchievementTag(
    CreateAchievementTagRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    final result = await repository.createAchievementTag(
      name: event.name,
      description: event.description,
      icon: event.icon,
      criteria: event.criteria,
      autoAssign: event.autoAssign,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (tag) => emit(AchievementTagCreated(tag: tag)),
    );
  }

  Future<void> _onUpdateAchievementTag(
    UpdateAchievementTagRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    final result = await repository.updateAchievementTag(
      tagId: event.tagId,
      name: event.name,
      description: event.description,
      icon: event.icon,
      criteria: event.criteria,
      autoAssign: event.autoAssign,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (tag) => emit(AchievementTagUpdated(tag: tag)),
    );
  }

  Future<void> _onDeleteAchievementTag(
    DeleteAchievementTagRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    final result = await repository.deleteAchievementTag(event.tagId);

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (_) => emit(const AchievementTagDeleted(message: 'Achievement tag deleted successfully')),
    );
  }

  Future<void> _onLoadDetailedUserReportRequested(
    LoadDetailedUserReportRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const SupervisorLoading());

    final result = await repository.getDetailedUserReport(
      userId: event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (detailedReport) => emit(DetailedUserReportLoaded(detailedReport: detailedReport)),
    );
  }

  Future<void> _onExportUserReportRequested(
    ExportUserReportRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(const ReportExporting(message: 'Preparing report...'));

    // First get the detailed report
    final reportResult = await repository.getDetailedUserReport(
      userId: event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    await reportResult.fold(
      (failure) async => emit(SupervisorError(message: failure.message)),
      (detailedReport) async {
        try {
          // Convert entity to model
          final model = _entityToModel(detailedReport);

          // Generate export file
          File file;
          if (event.format == 'pdf') {
            emit(const ReportExporting(message: 'Generating PDF...'));
            file = await PdfExportService().exportUserReportToPdf(model);
          } else {
            emit(const ReportExporting(message: 'Generating Excel...'));
            file = await ExcelExportService().exportUserReportToExcel(model);
          }

          // Share the file
          emit(const ReportExporting(message: 'Opening share dialog...'));
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'User Report - ${detailedReport.fullName}',
          );

          emit(ReportExported(filePath: file.path, format: event.format));
        } catch (e) {
          emit(SupervisorError(message: 'Export failed: ${e.toString()}'));
        }
      },
    );
  }

  DetailedUserReportModel _entityToModel(dynamic entity) {
    // Convert entity to model for export services
    return DetailedUserReportModel(
      userId: entity.userId as String,
      fullName: entity.fullName as String,
      email: entity.email as String,
      phoneNumber: entity.phoneNumber as String?,
      profilePhotoUrl: entity.profilePhotoUrl as String?,
      membershipStatus: entity.membershipStatus as String,
      memberSince: entity.memberSince as DateTime?,
      startDate: entity.startDate as DateTime,
      endDate: entity.endDate as DateTime,
      totalReportsInRange: entity.totalReportsInRange as int,
      averageDeeds: entity.averageDeeds as double,
      complianceRate: entity.complianceRate as double,
      faraidCompliance: entity.faraidCompliance as double,
      sunnahCompliance: entity.sunnahCompliance as double,
      currentBalance: entity.currentBalance as double,
      dailyReports: (entity.dailyReports as List).map<DailyReportDetailModel>((daily) {
        return DailyReportDetailModel(
          reportDate: daily.reportDate as DateTime,
          status: daily.status as String,
          totalDeeds: daily.totalDeeds as double,
          faraidCount: daily.faraidCount as double,
          sunnahCount: daily.sunnahCount as double,
          deedEntries: (daily.deedEntries as List).map<DeedDetailModel>((deed) {
            return DeedDetailModel(
              deedName: deed.deedName as String,
              deedKey: deed.deedKey as String,
              category: deed.category as String,
              valueType: deed.valueType as String,
              deedValue: deed.deedValue as double,
              sortOrder: deed.sortOrder as int,
            );
          }).toList(),
          submittedAt: daily.submittedAt as DateTime?,
        );
      }).toList(),
      achievementTags: (entity.achievementTags as List).cast<String>(),
    );
  }
}
