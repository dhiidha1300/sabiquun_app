import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';

abstract class DeedRepository {
  /// Get all active deed templates
  Future<List<DeedTemplateEntity>> getDeedTemplates();

  /// Create a new deed report for the current user
  /// deedValues: Map of templateId to deedValue (0.0-1.0)
  Future<DeedReportEntity> createDeedReport({
    required DateTime reportDate,
    required Map<String, double> deedValues,
  });

  /// Get all reports for the current user
  Future<List<DeedReportEntity>> getMyReports({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get all reports (for supervisors/admins)
  Future<List<DeedReportEntity>> getAllReports({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  });

  /// Get a specific report by ID
  Future<DeedReportEntity> getReportById(String reportId);

  /// Update a deed report (only if status is draft)
  /// deedValues: Map of templateId to deedValue (0.0-1.0)
  Future<DeedReportEntity> updateDeedReport({
    required String reportId,
    required Map<String, double> deedValues,
  });

  /// Submit a deed report (changes status from draft to submitted)
  Future<DeedReportEntity> submitDeedReport(String reportId);

  /// Delete a deed report (only if status is draft)
  Future<void> deleteDeedReport(String reportId);

  /// Get today's report for the current user (if exists)
  Future<DeedReportEntity?> getTodayReport();

  /// Check if user can submit a report for a specific date
  Future<bool> canSubmitReportForDate(DateTime date);
}
