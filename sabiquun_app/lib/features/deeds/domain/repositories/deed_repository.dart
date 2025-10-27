import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';

abstract class DeedRepository {
  /// Get all active deed templates
  Future<List<DeedTemplateEntity>> getDeedTemplates();

  /// Create a new deed report for the current user
  Future<DeedReportEntity> createDeedReport({
    required DateTime reportDate,
    required Map<String, int> deedValues,
    String? notes,
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

  /// Update a deed report (only if status is pending)
  Future<DeedReportEntity> updateDeedReport({
    required String reportId,
    required Map<String, int> deedValues,
    String? notes,
  });

  /// Submit a deed report for approval
  Future<DeedReportEntity> submitDeedReport(String reportId);

  /// Delete a deed report (only if status is pending)
  Future<void> deleteDeedReport(String reportId);

  /// Approve a deed report (supervisor/admin only)
  Future<DeedReportEntity> approveDeedReport(String reportId);

  /// Reject a deed report (supervisor/admin only)
  Future<DeedReportEntity> rejectDeedReport(
    String reportId,
    String rejectionReason,
  );

  /// Get today's report for the current user (if exists)
  Future<DeedReportEntity?> getTodayReport();

  /// Check if user can submit a report for a specific date
  Future<bool> canSubmitReportForDate(DateTime date);
}
