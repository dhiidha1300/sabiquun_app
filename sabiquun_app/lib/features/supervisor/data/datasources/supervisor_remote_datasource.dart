import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_report_summary_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/achievement_tag_model.dart';
import '../models/user_detail_model.dart';

/// Supervisor remote data source
class SupervisorRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupervisorRemoteDataSource({required this.supabaseClient});

  /// Get all user reports summaries
  Future<List<UserReportSummaryModel>> getAllUserReports({
    String? searchQuery,
    String? membershipStatus,
    String? complianceFilter,
    String? reportStatus,
    String? sortBy,
  }) async {
    try {
      final response = await supabaseClient.rpc('get_all_user_reports', params: {
        'search_query': searchQuery,
        'membership_status_filter': membershipStatus,
        'compliance_filter': complianceFilter,
        'report_status_filter': reportStatus,
        'sort_by': sortBy ?? 'name',
      });

      if (response == null) return [];

      return (response as List)
          .map((json) => UserReportSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user reports: $e');
    }
  }

  /// Get leaderboard entries
  Future<List<LeaderboardEntryModel>> getLeaderboard({
    required String period,
    int limit = 50,
  }) async {
    try {
      final response = await supabaseClient.rpc('get_leaderboard_rankings', params: {
        'period': period,
        'limit_count': limit,
      });

      if (response == null) return [];

      return (response as List)
          .map((json) => LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  /// Get users at risk
  Future<List<UserReportSummaryModel>> getUsersAtRisk({
    double balanceThreshold = 100000,
  }) async {
    try {
      final response = await supabaseClient.rpc('get_users_at_risk', params: {
        'balance_threshold': balanceThreshold,
      });

      if (response == null) return [];

      return (response as List)
          .map((json) => UserReportSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users at risk: $e');
    }
  }

  /// Get user detail
  Future<UserDetailModel> getUserDetail(String userId) async {
    try {
      final response = await supabaseClient.rpc('get_user_detail_for_supervisor', params: {
        'target_user_id': userId,
      });

      if (response == null) {
        throw Exception('User not found');
      }

      return UserDetailModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch user detail: $e');
    }
  }

  /// Get all achievement tags
  Future<List<AchievementTagModel>> getAchievementTags() async {
    try {
      final response = await supabaseClient
          .from('achievement_tags')
          .select('*, user_achievement_tags(count)')
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final data = Map<String, dynamic>.from(json);
        data['activeUserCount'] = (json['user_achievement_tags'] as List?)?.length ?? 0;
        data.remove('user_achievement_tags');
        return AchievementTagModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch achievement tags: $e');
    }
  }

  /// Assign achievement tag to user
  Future<void> assignAchievementTag({
    required String tagId,
    required String userId,
    required String assignedBy,
  }) async {
    try {
      await supabaseClient.from('user_achievement_tags').insert({
        'user_id': userId,
        'tag_id': tagId,
        'awarded_by': assignedBy,
        'awarded_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to assign achievement tag: $e');
    }
  }

  /// Remove achievement tag from user
  Future<void> removeAchievementTag({
    required String tagId,
    required String userId,
  }) async {
    try {
      await supabaseClient
          .from('user_achievement_tags')
          .delete()
          .eq('user_id', userId)
          .eq('tag_id', tagId);
    } catch (e) {
      throw Exception('Failed to remove achievement tag: $e');
    }
  }

  /// Create achievement tag
  Future<AchievementTagModel> createAchievementTag({
    required String name,
    String? description,
    required String icon,
    Map<String, dynamic>? criteria,
    required bool autoAssign,
  }) async {
    try {
      final response = await supabaseClient.from('achievement_tags').insert({
        'name': name,
        'description': description,
        'icon': icon,
        'criteria': criteria,
        'auto_assign': autoAssign,
      }).select().single();

      final data = Map<String, dynamic>.from(response);
      data['activeUserCount'] = 0;
      return AchievementTagModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create achievement tag: $e');
    }
  }

  /// Update achievement tag
  Future<AchievementTagModel> updateAchievementTag({
    required String tagId,
    String? name,
    String? description,
    String? icon,
    Map<String, dynamic>? criteria,
    bool? autoAssign,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (icon != null) updates['icon'] = icon;
      if (criteria != null) updates['criteria'] = criteria;
      if (autoAssign != null) updates['auto_assign'] = autoAssign;

      final response = await supabaseClient
          .from('achievement_tags')
          .update(updates)
          .eq('id', tagId)
          .select()
          .single();

      final data = Map<String, dynamic>.from(response);
      data['activeUserCount'] = 0; // Will be populated separately if needed
      return AchievementTagModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update achievement tag: $e');
    }
  }

  /// Delete achievement tag
  Future<void> deleteAchievementTag(String tagId) async {
    try {
      await supabaseClient.from('achievement_tags').delete().eq('id', tagId);
    } catch (e) {
      throw Exception('Failed to delete achievement tag: $e');
    }
  }
}
