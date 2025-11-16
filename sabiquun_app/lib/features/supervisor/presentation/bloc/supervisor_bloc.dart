import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/supervisor_repository.dart';
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
}
