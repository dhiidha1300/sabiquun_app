import 'package:sabiquun_app/features/deeds/data/datasources/deed_remote_datasource.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';
import 'package:sabiquun_app/features/deeds/domain/repositories/deed_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeedRepositoryImpl implements DeedRepository {
  final DeedRemoteDataSource _remoteDataSource;
  final SupabaseClient _supabase;

  DeedRepositoryImpl(this._remoteDataSource, this._supabase);

  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<List<DeedTemplateEntity>> getDeedTemplates() async {
    try {
      final models = await _remoteDataSource.getDeedTemplates();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get deed templates: $e');
    }
  }

  @override
  Future<DeedReportEntity> createDeedReport({
    required DateTime reportDate,
    required Map<String, double> deedValues,
  }) async {
    try {
      final model = await _remoteDataSource.createDeedReport(
        userId: _currentUserId,
        reportDate: reportDate,
        deedValues: deedValues,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to create deed report: $e');
    }
  }

  @override
  Future<List<DeedReportEntity>> getMyReports({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await _remoteDataSource.getMyReports(
        userId: _currentUserId,
        startDate: startDate,
        endDate: endDate,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get my reports: $e');
    }
  }

  @override
  Future<List<DeedReportEntity>> getAllReports({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) async {
    try {
      final models = await _remoteDataSource.getAllReports(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all reports: $e');
    }
  }

  @override
  Future<DeedReportEntity> getReportById(String reportId) async {
    try {
      final model = await _remoteDataSource.getReportById(reportId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  @override
  Future<DeedReportEntity> updateDeedReport({
    required String reportId,
    required Map<String, double> deedValues,
  }) async {
    try {
      final model = await _remoteDataSource.updateDeedReport(
        reportId: reportId,
        deedValues: deedValues,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to update deed report: $e');
    }
  }

  @override
  Future<DeedReportEntity> submitDeedReport(String reportId) async {
    try {
      final model = await _remoteDataSource.submitDeedReport(reportId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to submit deed report: $e');
    }
  }

  @override
  Future<void> deleteDeedReport(String reportId) async {
    try {
      await _remoteDataSource.deleteDeedReport(reportId);
    } catch (e) {
      throw Exception('Failed to delete deed report: $e');
    }
  }

  @override
  Future<DeedReportEntity?> getTodayReport() async {
    try {
      final model = await _remoteDataSource.getTodayReport(_currentUserId);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get today\'s report: $e');
    }
  }

  @override
  Future<bool> canSubmitReportForDate(DateTime date) async {
    try {
      return await _remoteDataSource.canSubmitReportForDate(
        _currentUserId,
        date,
      );
    } catch (e) {
      throw Exception('Failed to check report availability: $e');
    }
  }
}
