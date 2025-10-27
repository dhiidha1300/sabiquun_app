import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/features/deeds/data/models/deed_template_model.dart';
import 'package:sabiquun_app/features/deeds/data/models/deed_report_model.dart';

class DeedRemoteDataSource {
  final SupabaseClient _supabase;

  DeedRemoteDataSource(this._supabase);

  /// Get all active deed templates ordered by sort_order
  Future<List<DeedTemplateModel>> getDeedTemplates() async {
    try {
      final response = await _supabase
          .from('deed_templates')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      return (response as List)
          .map((json) => DeedTemplateModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch deed templates: $e');
    }
  }

  /// Create a new deed report with entries
  Future<DeedReportModel> createDeedReport({
    required String userId,
    required DateTime reportDate,
    required Map<String, double> deedValues,
  }) async {
    try {
      final templates = await getDeedTemplates();

      // Calculate totals
      double totalDeeds = 0.0;
      double sunnahCount = 0.0;
      double faraidCount = 0.0;

      for (var template in templates) {
        final value = deedValues[template.id] ?? 0.0;
        totalDeeds += value;

        if (template.category == 'sunnah') {
          sunnahCount += value;
        } else if (template.category == 'faraid') {
          faraidCount += value;
        }
      }

      // Create the report as 'draft' initially
      final reportData = {
        'user_id': userId,
        'report_date': reportDate.toIso8601String().split('T')[0],
        'total_deeds': totalDeeds,
        'sunnah_count': sunnahCount,
        'faraid_count': faraidCount,
        'status': 'draft',
      };

      final reportResponse = await _supabase
          .from('deeds_reports')
          .insert(reportData)
          .select()
          .single();

      final reportId = reportResponse['id'] as String;

      // Create deed entries with correct column names
      final entries = <Map<String, dynamic>>[];
      for (var template in templates) {
        entries.add({
          'report_id': reportId,
          'deed_template_id': template.id,
          'deed_value': deedValues[template.id] ?? 0.0,
        });
      }

      await _supabase.from('deed_entries').insert(entries);

      // Fetch the complete report with entries
      return await getReportById(reportId);
    } catch (e) {
      throw Exception('Failed to create deed report: $e');
    }
  }

  /// Get reports for a specific user
  Future<List<DeedReportModel>> getMyReports({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('deeds_reports')
          .select('*, deed_entries(*)')
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('report_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('report_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('report_date', ascending: false);

      return (response as List)
          .map((json) => DeedReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user reports: $e');
    }
  }

  /// Get all reports (for supervisors/admins)
  Future<List<DeedReportModel>> getAllReports({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) async {
    try {
      var query = _supabase
          .from('deeds_reports')
          .select('*, deed_entries(*)');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (startDate != null) {
        query = query.gte('report_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('report_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('report_date', ascending: false);

      return (response as List)
          .map((json) => DeedReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all reports: $e');
    }
  }

  /// Get a specific report by ID
  Future<DeedReportModel> getReportById(String reportId) async {
    try {
      final response = await _supabase
          .from('deeds_reports')
          .select('*, deed_entries(*)')
          .eq('id', reportId)
          .single();

      return DeedReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  /// Update a deed report
  Future<DeedReportModel> updateDeedReport({
    required String reportId,
    required Map<String, double> deedValues,
  }) async {
    try {
      final templates = await getDeedTemplates();

      // Calculate new totals
      double totalDeeds = 0.0;
      double sunnahCount = 0.0;
      double faraidCount = 0.0;

      for (var template in templates) {
        final value = deedValues[template.id] ?? 0.0;
        totalDeeds += value;

        if (template.category == 'sunnah') {
          sunnahCount += value;
        } else if (template.category == 'faraid') {
          faraidCount += value;
        }
      }

      // Update the report with recalculated totals
      await _supabase.from('deeds_reports').update({
        'total_deeds': totalDeeds,
        'sunnah_count': sunnahCount,
        'faraid_count': faraidCount,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reportId);

      // Update deed entries with correct column names
      for (var entry in deedValues.entries) {
        await _supabase.from('deed_entries').update({
          'deed_value': entry.value,
        }).eq('report_id', reportId).eq('deed_template_id', entry.key);
      }

      // Fetch the updated report
      return await getReportById(reportId);
    } catch (e) {
      throw Exception('Failed to update deed report: $e');
    }
  }

  /// Submit a deed report (change from draft to submitted)
  Future<DeedReportModel> submitDeedReport(String reportId) async {
    try {
      await _supabase.from('deeds_reports').update({
        'status': 'submitted',
        'submitted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reportId);

      return await getReportById(reportId);
    } catch (e) {
      throw Exception('Failed to submit deed report: $e');
    }
  }

  /// Delete a deed report
  Future<void> deleteDeedReport(String reportId) async {
    try {
      // Delete the report (cascade will handle deed_entries automatically)
      // Note: ON DELETE CASCADE is set in the database schema
      await _supabase
          .from('deeds_reports')
          .delete()
          .eq('id', reportId);

      // No need to validate response - if no error is thrown, delete succeeded
    } catch (e) {
      throw Exception('Failed to delete deed report: $e');
    }
  }

  // NOTE: The database schema only supports 'draft' and 'submitted' statuses.
  // Approval/rejection functionality would need to be implemented via a separate
  // system (e.g., penalties table, excuses table) or by extending the schema.

  /// Get today's report for a user
  Future<DeedReportModel?> getTodayReport(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('deeds_reports')
          .select('*, deed_entries(*)')
          .eq('user_id', userId)
          .eq('report_date', today)
          .maybeSingle();

      if (response == null) return null;

      return DeedReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch today\'s report: $e');
    }
  }

  /// Check if user can submit a report for a specific date
  Future<bool> canSubmitReportForDate(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('deeds_reports')
          .select('id')
          .eq('user_id', userId)
          .eq('report_date', dateStr)
          .maybeSingle();

      return response == null;
    } catch (e) {
      throw Exception('Failed to check report availability: $e');
    }
  }
}
