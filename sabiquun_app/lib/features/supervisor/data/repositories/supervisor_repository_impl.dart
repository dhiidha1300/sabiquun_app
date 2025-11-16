import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_report_summary_entity.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/entities/achievement_tag_entity.dart';
import '../../domain/entities/user_detail_entity.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../datasources/supervisor_remote_datasource.dart';

/// Supervisor repository implementation
class SupervisorRepositoryImpl implements SupervisorRepository {
  final SupervisorRemoteDataSource remoteDataSource;

  SupervisorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserReportSummaryEntity>>> getAllUserReports({
    String? searchQuery,
    String? membershipStatus,
    String? complianceFilter,
    String? reportStatus,
    String? sortBy,
  }) async {
    try {
      final models = await remoteDataSource.getAllUserReports(
        searchQuery: searchQuery,
        membershipStatus: membershipStatus,
        complianceFilter: complianceFilter,
        reportStatus: reportStatus,
        sortBy: sortBy,
      );

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getLeaderboard({
    required String period,
    int limit = 50,
  }) async {
    try {
      final models = await remoteDataSource.getLeaderboard(
        period: period,
        limit: limit,
      );

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserReportSummaryEntity>>> getUsersAtRisk({
    double balanceThreshold = 100000,
  }) async {
    try {
      final models = await remoteDataSource.getUsersAtRisk(
        balanceThreshold: balanceThreshold,
      );

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserDetailEntity>> getUserDetail(String userId) async {
    try {
      final model = await remoteDataSource.getUserDetail(userId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AchievementTagEntity>>> getAchievementTags() async {
    try {
      final models = await remoteDataSource.getAchievementTags();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignAchievementTag({
    required String tagId,
    required String userId,
  }) async {
    try {
      // TODO: Get current supervisor ID from auth
      await remoteDataSource.assignAchievementTag(
        tagId: tagId,
        userId: userId,
        assignedBy: 'current-user-id', // Should be passed from BLoC
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeAchievementTag({
    required String tagId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.removeAchievementTag(
        tagId: tagId,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AchievementTagEntity>> createAchievementTag({
    required String name,
    String? description,
    required String icon,
    Map<String, dynamic>? criteria,
    required bool autoAssign,
  }) async {
    try {
      final model = await remoteDataSource.createAchievementTag(
        name: name,
        description: description,
        icon: icon,
        criteria: criteria,
        autoAssign: autoAssign,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AchievementTagEntity>> updateAchievementTag({
    required String tagId,
    String? name,
    String? description,
    String? icon,
    Map<String, dynamic>? criteria,
    bool? autoAssign,
  }) async {
    try {
      final model = await remoteDataSource.updateAchievementTag(
        tagId: tagId,
        name: name,
        description: description,
        icon: icon,
        criteria: criteria,
        autoAssign: autoAssign,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAchievementTag(String tagId) async {
    try {
      await remoteDataSource.deleteAchievementTag(tagId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
