import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_report_summary_entity.dart';
import '../entities/leaderboard_entry_entity.dart';
import '../entities/achievement_tag_entity.dart';
import '../entities/user_detail_entity.dart';

/// Supervisor repository interface
abstract class SupervisorRepository {
  /// Get all user reports summaries
  Future<Either<Failure, List<UserReportSummaryEntity>>> getAllUserReports({
    String? searchQuery,
    String? membershipStatus,
    String? complianceFilter,
    String? reportStatus,
    String? sortBy,
  });

  /// Get leaderboard entries
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getLeaderboard({
    required String period, // 'daily', 'weekly', 'monthly', 'all-time'
    int limit = 50,
  });

  /// Get users at risk (high balance)
  Future<Either<Failure, List<UserReportSummaryEntity>>> getUsersAtRisk({
    double balanceThreshold = 100000,
  });

  /// Get user detail by ID
  Future<Either<Failure, UserDetailEntity>> getUserDetail(String userId);

  /// Get all achievement tags
  Future<Either<Failure, List<AchievementTagEntity>>> getAchievementTags();

  /// Assign achievement tag to user
  Future<Either<Failure, void>> assignAchievementTag({
    required String tagId,
    required String userId,
  });

  /// Remove achievement tag from user
  Future<Either<Failure, void>> removeAchievementTag({
    required String tagId,
    required String userId,
  });

  /// Create new achievement tag
  Future<Either<Failure, AchievementTagEntity>> createAchievementTag({
    required String name,
    String? description,
    required String icon,
    Map<String, dynamic>? criteria,
    required bool autoAssign,
  });

  /// Update achievement tag
  Future<Either<Failure, AchievementTagEntity>> updateAchievementTag({
    required String tagId,
    String? name,
    String? description,
    String? icon,
    Map<String, dynamic>? criteria,
    bool? autoAssign,
  });

  /// Delete achievement tag
  Future<Either<Failure, void>> deleteAchievementTag(String tagId);
}
