import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_report_summary_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/achievement_tag_model.dart';
import '../models/user_detail_model.dart';
import '../models/detailed_report_model.dart';

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

      return (response as List).map((json) {
        final data = Map<String, dynamic>.from(json);

        // Parse member_since
        DateTime? memberSince;
        if (data['member_since'] != null) {
          final dateValue = data['member_since'];
          if (dateValue is String) {
            memberSince = DateTime.parse(dateValue);
          } else if (dateValue is DateTime) {
            memberSince = dateValue;
          }
        }

        // Parse last_report_time
        DateTime? lastReportTime;
        if (data['last_report_time'] != null) {
          final dateValue = data['last_report_time'];
          if (dateValue is String) {
            lastReportTime = DateTime.parse(dateValue);
          } else if (dateValue is DateTime) {
            lastReportTime = dateValue;
          }
        }

        // Map SQL function output to model fields
        return UserReportSummaryModel.fromJson({
          'userId': data['user_id'] ?? '',
          'fullName': data['full_name'] ?? 'Unknown',
          'email': data['email'] ?? 'no-email@example.com',
          'phoneNumber': data['phone_number'],
          'profilePhotoUrl': data['profile_photo_url'],
          'membershipStatus': data['membership_status'] ?? 'new',
          'memberSince': memberSince?.toIso8601String(),
          'todayDeeds': data['today_deeds'] ?? 0,
          'todayTarget': data['today_target'] ?? 10,
          'hasSubmittedToday': data['has_submitted_today'] ?? false,
          'lastReportTime': lastReportTime?.toIso8601String(),
          'complianceRate': (data['compliance_rate'] as num?)?.toDouble() ?? 0.0,
          'currentStreak': data['current_streak'] ?? 0,
          'totalReports': data['total_reports'] ?? 0,
          'currentBalance': (data['current_balance'] as num?)?.toDouble() ?? 0.0,
          'isAtRisk': data['is_at_risk'] ?? false,
          'daysWithoutReport': data['days_without_report'] ?? 999,
        });
      }).toList();
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

      return (response as List).map((json) {
        final data = Map<String, dynamic>.from(json);

        // Map SQL function output to model fields
        return LeaderboardEntryModel.fromJson({
          'rank': (data['rank'] as num).toInt(),
          'userId': data['user_id'],
          'fullName': data['user_name'],
          'profilePhotoUrl': data['photo_url'],
          'membershipStatus': data['membership_status'] ?? 'new',
          'averageDeeds': (data['average_deeds'] as num?)?.toDouble() ?? 0.0,
          'complianceRate': 0.0, // Not returned by function, calculate separately if needed
          'achievementTags': (data['special_tags'] as List?)?.map((tag) => tag['name'] as String).toList() ?? [],
          'hasFajrChampion': (data['special_tags'] as List?)?.any((tag) => tag['tag_key'] == 'fajr_champion') ?? false,
          'currentStreak': 0, // Not returned by function, calculate separately if needed
        });
      }).toList();
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

      return (response as List).map((json) {
        final data = Map<String, dynamic>.from(json);

        // Parse last_report_date
        DateTime? lastReportDate;
        if (data['last_report_date'] != null) {
          final dateValue = data['last_report_date'];
          if (dateValue is String) {
            lastReportDate = DateTime.parse(dateValue);
          } else if (dateValue is DateTime) {
            lastReportDate = dateValue;
          }
        }

        // Map SQL function output to model fields
        return UserReportSummaryModel.fromJson({
          'userId': data['user_id'],
          'fullName': data['user_name'],
          'email': data['email'],
          'phoneNumber': data['phone'],
          'profilePhotoUrl': data['photo_url'],
          'membershipStatus': data['membership_status'] ?? 'new',
          'memberSince': null, // Not returned by function
          'todayDeeds': ((data['total_deeds_today'] as num?)?.toDouble() ?? 0.0).toInt(),
          'todayTarget': 10, // Default target
          'hasSubmittedToday': data['submitted_today'] ?? false,
          'lastReportTime': lastReportDate?.toIso8601String(),
          'complianceRate': (data['compliance_rate'] as num?)?.toDouble() ?? 0.0,
          'currentStreak': 0, // Not returned by function
          'totalReports': 0, // Not returned by function
          'currentBalance': (data['current_balance'] as num?)?.toDouble() ?? 0.0,
          'isAtRisk': true, // All users in this list are at risk
          'daysWithoutReport': lastReportDate != null
              ? DateTime.now().difference(lastReportDate).inDays
              : 999,
        });
      }).toList();
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

  /// Get all achievement tags (special_tags)
  Future<List<AchievementTagModel>> getAchievementTags() async {
    try {
      final response = await supabaseClient
          .from('special_tags')
          .select('*, user_tags(count)')
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final data = Map<String, dynamic>.from(json);
        data['activeUserCount'] = (json['user_tags'] as List?)?.length ?? 0;
        data.remove('user_tags');
        // Map special_tags fields to achievement tag fields
        data['name'] = data['display_name'];
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
      await supabaseClient.from('user_tags').insert({
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
          .from('user_tags')
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
      // Generate tag_key from name (lowercase, replace spaces with underscores)
      final tagKey = name.toLowerCase().replaceAll(' ', '_');

      final response = await supabaseClient.from('special_tags').insert({
        'tag_key': tagKey,
        'display_name': name,
        'description': description,
        'criteria': criteria,
        'auto_assign': autoAssign,
        'is_active': true,
      }).select().single();

      final data = Map<String, dynamic>.from(response);
      data['activeUserCount'] = 0;
      data['name'] = data['display_name'];
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
      if (name != null) {
        updates['display_name'] = name;
        updates['tag_key'] = name.toLowerCase().replaceAll(' ', '_');
      }
      if (description != null) updates['description'] = description;
      if (criteria != null) updates['criteria'] = criteria;
      if (autoAssign != null) updates['auto_assign'] = autoAssign;

      final response = await supabaseClient
          .from('special_tags')
          .update(updates)
          .eq('id', tagId)
          .select()
          .single();

      final data = Map<String, dynamic>.from(response);
      data['activeUserCount'] = 0; // Will be populated separately if needed
      data['name'] = data['display_name'];
      return AchievementTagModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update achievement tag: $e');
    }
  }

  /// Delete achievement tag
  Future<void> deleteAchievementTag(String tagId) async {
    try {
      await supabaseClient.from('special_tags').delete().eq('id', tagId);
    } catch (e) {
      throw Exception('Failed to delete achievement tag: $e');
    }
  }

  /// Get detailed user report with date range
  Future<DetailedUserReportModel> getDetailedUserReport({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await supabaseClient.rpc(
        'get_detailed_user_report',
        params: {
          'p_user_id': userId,
          'p_start_date': startDate.toIso8601String().split('T')[0],
          'p_end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response == null) {
        throw Exception('No data returned from Supabase');
      }

      // The response is already a JSON object, not wrapped
      final data = response as Map<String, dynamic>;

      // Parse daily reports
      final dailyReportsJson = data['daily_reports'] as List?;
      final dailyReports = dailyReportsJson?.map((reportJson) {
        final reportData = reportJson as Map<String, dynamic>;
        final deedEntriesJson = reportData['deed_entries'] as List?;
        final deedEntries = deedEntriesJson?.map((entryJson) {
          final entryData = entryJson as Map<String, dynamic>;
          return DeedDetailModel(
            deedName: entryData['deed_name']?.toString() ?? '',
            deedKey: entryData['deed_key']?.toString() ?? '',
            category: entryData['category']?.toString() ?? 'faraid',
            valueType: entryData['value_type']?.toString() ?? 'binary',
            deedValue: (entryData['deed_value'] as num?)?.toDouble() ?? 0.0,
            sortOrder: (entryData['sort_order'] as num?)?.toInt() ?? 0,
          );
        }).toList() ?? [];

        return DailyReportDetailModel(
          reportDate: DateTime.parse(reportData['report_date']?.toString() ?? DateTime.now().toIso8601String()),
          status: reportData['status']?.toString() ?? 'submitted',
          totalDeeds: (reportData['total_deeds'] as num?)?.toDouble() ?? 0.0,
          faraidCount: (reportData['faraid_count'] as num?)?.toDouble() ?? 0.0,
          sunnahCount: (reportData['sunnah_count'] as num?)?.toDouble() ?? 0.0,
          deedEntries: deedEntries,
          submittedAt: reportData['submitted_at'] != null
              ? DateTime.parse(reportData['submitted_at'].toString())
              : null,
        );
      }).toList() ?? [];

      // Build the complete model
      return DetailedUserReportModel(
        userId: data['user_id']?.toString() ?? userId,
        fullName: data['full_name']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        phoneNumber: data['phone_number']?.toString(),
        profilePhotoUrl: data['profile_photo_url']?.toString(),
        membershipStatus: data['membership_status']?.toString() ?? 'new',
        memberSince: data['member_since'] != null
            ? DateTime.parse(data['member_since'].toString())
            : null,
        startDate: startDate,
        endDate: endDate,
        totalReportsInRange: (data['total_reports_in_range'] as num?)?.toInt() ?? 0,
        averageDeeds: (data['average_deeds'] as num?)?.toDouble() ?? 0.0,
        complianceRate: (data['compliance_rate'] as num?)?.toDouble() ?? 0.0,
        faraidCompliance: (data['faraid_compliance'] as num?)?.toDouble() ?? 0.0,
        sunnahCompliance: (data['sunnah_compliance'] as num?)?.toDouble() ?? 0.0,
        currentBalance: (data['current_balance'] as num?)?.toDouble() ?? 0.0,
        dailyReports: dailyReports,
        achievementTags: data['achievement_tags'] != null
            ? List<String>.from(data['achievement_tags'] as List)
            : [],
      );
    } catch (e) {
      throw Exception('Failed to fetch detailed user report: $e');
    }
  }
}
