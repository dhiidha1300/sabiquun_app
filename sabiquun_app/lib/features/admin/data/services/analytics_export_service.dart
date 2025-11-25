import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xl;
import 'package:intl/intl.dart';
import '../../domain/entities/analytics_entity.dart';

class AnalyticsExportService {
  /// Export analytics to PDF
  static Future<void> exportToPdf({
    required AnalyticsEntity analytics,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    // Add page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Analytics Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  _getDateRangeText(startDate, endDate),
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // User Metrics Section
          _buildPdfSection('User Metrics', [
            _buildPdfMetric('Total Users', analytics.userMetrics.totalUsers.toString()),
            _buildPdfMetric('Active Users', analytics.userMetrics.activeUsers.toString()),
            _buildPdfMetric('Pending Users', analytics.userMetrics.pendingUsers.toString()),
            _buildPdfMetric('Suspended Users', analytics.userMetrics.suspendedUsers.toString()),
            _buildPdfMetric('Deactivated Users', analytics.userMetrics.deactivatedUsers.toString()),
            _buildPdfMetric('New Registrations (Week)', analytics.userMetrics.newRegistrationsThisWeek.toString()),
            _buildPdfMetric('Users at Risk', analytics.userMetrics.usersAtRisk.toString()),
          ]),

          pw.SizedBox(height: 16),

          // Deed Metrics Section
          _buildPdfSection('Deed Performance', [
            _buildPdfMetric('Total Deeds Today', analytics.deedMetrics.totalDeedsToday.toString()),
            _buildPdfMetric('Total Deeds Week', analytics.deedMetrics.totalDeedsWeek.toString()),
            _buildPdfMetric('Total Deeds Month', analytics.deedMetrics.totalDeedsMonth.toString()),
            _buildPdfMetric('Average Per User (Week)', analytics.deedMetrics.averagePerUserWeek.toStringAsFixed(1)),
            _buildPdfMetric('Compliance Today', '${(analytics.deedMetrics.complianceRateToday * 100).toStringAsFixed(1)}%'),
            _buildPdfMetric('Users Completed Today', '${analytics.deedMetrics.usersCompletedToday}/${analytics.deedMetrics.totalActiveUsers}'),
          ]),

          pw.SizedBox(height: 16),

          // Excuse Metrics Section
          _buildPdfSection('Excuse Metrics', [
            _buildPdfMetric('Pending Excuses', analytics.excuseMetrics.pendingExcuses.toString()),
            _buildPdfMetric('Approval Rate', '${(analytics.excuseMetrics.approvalRate * 100).toStringAsFixed(1)}%'),
            if (analytics.excuseMetrics.mostCommonReason != null)
              _buildPdfMetric('Most Common Reason', '${analytics.excuseMetrics.mostCommonReason} (${analytics.excuseMetrics.mostCommonReasonCount})'),
          ]),

          pw.SizedBox(height: 16),

          // Financial Metrics Section
          _buildPdfSection('Financial Metrics', [
            _buildPdfMetric('Penalties (Month)', 'Tsh ${_formatCurrency(analytics.financialMetrics.penaltiesIncurredThisMonth)}'),
            _buildPdfMetric('Penalties (All Time)', 'Tsh ${_formatCurrency(analytics.financialMetrics.penaltiesIncurredAllTime)}'),
            _buildPdfMetric('Payments (Month)', 'Tsh ${_formatCurrency(analytics.financialMetrics.paymentsReceivedThisMonth)}'),
            _buildPdfMetric('Payments (All Time)', 'Tsh ${_formatCurrency(analytics.financialMetrics.paymentsReceivedAllTime)}'),
            _buildPdfMetric('Outstanding Balance', 'Tsh ${_formatCurrency(analytics.financialMetrics.outstandingBalance)}'),
            _buildPdfMetric('Pending Payments', '${analytics.financialMetrics.pendingPaymentsCount} (Tsh ${_formatCurrency(analytics.financialMetrics.pendingPaymentsAmount)})'),
          ]),

          pw.SizedBox(height: 16),

          // Engagement Metrics Section
          _buildPdfSection('Engagement Metrics', [
            _buildPdfMetric('Daily Active Users', analytics.engagementMetrics.dailyActiveUsers.toString()),
            _buildPdfMetric('Total Active Users', analytics.engagementMetrics.totalActiveUsers.toString()),
            _buildPdfMetric('Report Submission Rate', analytics.engagementMetrics.formattedReportSubmissionRate),
            _buildPdfMetric('Average Submission Time', analytics.engagementMetrics.averageSubmissionTime),
            _buildPdfMetric('Notification Open Rate', '${(analytics.engagementMetrics.notificationOpenRate * 100).toStringAsFixed(1)}%'),
            _buildPdfMetric('Avg Response Time', '${analytics.engagementMetrics.averageResponseTimeMinutes} mins'),
          ]),

          pw.SizedBox(height: 24),

          // Footer
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'This is an automated report generated by Sabiquun App',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    // Save and share
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/analytics_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Analytics Report - ${_getDateRangeText(startDate, endDate)}',
    );
  }

  /// Export analytics to Excel
  static Future<void> exportToExcel({
    required AnalyticsEntity analytics,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Create a new Excel document
    final xl.Workbook workbook = xl.Workbook();
    final xl.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Analytics Report';

    int currentRow = 1;

    // Title
    sheet.getRangeByIndex(currentRow, 1, currentRow, 2).merge();
    sheet.getRangeByIndex(currentRow, 1).setText('Analytics Report');
    sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 18;
    currentRow += 2;

    // Date Range
    sheet.getRangeByIndex(currentRow, 1).setText('Date Range:');
    sheet.getRangeByIndex(currentRow, 2).setText(_getDateRangeText(startDate, endDate));
    currentRow++;

    sheet.getRangeByIndex(currentRow, 1).setText('Generated:');
    sheet.getRangeByIndex(currentRow, 2).setText(DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()));
    currentRow += 2;

    // User Metrics
    currentRow = _addExcelSection(sheet, currentRow, 'User Metrics', [
      ['Total Users', analytics.userMetrics.totalUsers.toString()],
      ['Active Users', analytics.userMetrics.activeUsers.toString()],
      ['Pending Users', analytics.userMetrics.pendingUsers.toString()],
      ['Suspended Users', analytics.userMetrics.suspendedUsers.toString()],
      ['Deactivated Users', analytics.userMetrics.deactivatedUsers.toString()],
      ['New Registrations (Week)', analytics.userMetrics.newRegistrationsThisWeek.toString()],
      ['Users at Risk', analytics.userMetrics.usersAtRisk.toString()],
    ]);

    currentRow++;

    // Deed Metrics
    currentRow = _addExcelSection(sheet, currentRow, 'Deed Performance', [
      ['Total Deeds Today', analytics.deedMetrics.totalDeedsToday.toString()],
      ['Total Deeds Week', analytics.deedMetrics.totalDeedsWeek.toString()],
      ['Total Deeds Month', analytics.deedMetrics.totalDeedsMonth.toString()],
      ['Average Per User (Week)', analytics.deedMetrics.averagePerUserWeek.toStringAsFixed(1)],
      ['Compliance Today', '${(analytics.deedMetrics.complianceRateToday * 100).toStringAsFixed(1)}%'],
      ['Users Completed Today', '${analytics.deedMetrics.usersCompletedToday}/${analytics.deedMetrics.totalActiveUsers}'],
    ]);

    currentRow++;

    // Financial Metrics
    currentRow = _addExcelSection(sheet, currentRow, 'Financial Metrics', [
      ['Penalties (Month)', 'Tsh ${_formatCurrency(analytics.financialMetrics.penaltiesIncurredThisMonth)}'],
      ['Penalties (All Time)', 'Tsh ${_formatCurrency(analytics.financialMetrics.penaltiesIncurredAllTime)}'],
      ['Payments (Month)', 'Tsh ${_formatCurrency(analytics.financialMetrics.paymentsReceivedThisMonth)}'],
      ['Payments (All Time)', 'Tsh ${_formatCurrency(analytics.financialMetrics.paymentsReceivedAllTime)}'],
      ['Outstanding Balance', 'Tsh ${_formatCurrency(analytics.financialMetrics.outstandingBalance)}'],
      ['Pending Payments', '${analytics.financialMetrics.pendingPaymentsCount} (Tsh ${_formatCurrency(analytics.financialMetrics.pendingPaymentsAmount)})'],
    ]);

    currentRow++;

    // Engagement Metrics
    currentRow = _addExcelSection(sheet, currentRow, 'Engagement Metrics', [
      ['Daily Active Users', analytics.engagementMetrics.dailyActiveUsers.toString()],
      ['Total Active Users', analytics.engagementMetrics.totalActiveUsers.toString()],
      ['Report Submission Rate', analytics.engagementMetrics.formattedReportSubmissionRate],
      ['Average Submission Time', analytics.engagementMetrics.averageSubmissionTime],
      ['Notification Open Rate', '${(analytics.engagementMetrics.notificationOpenRate * 100).toStringAsFixed(1)}%'],
      ['Avg Response Time', '${analytics.engagementMetrics.averageResponseTimeMinutes} mins'],
    ]);

    currentRow++;

    // Excuse Metrics
    currentRow = _addExcelSection(sheet, currentRow, 'Excuse Metrics', [
      ['Pending Excuses', analytics.excuseMetrics.pendingExcuses.toString()],
      ['Approval Rate', '${(analytics.excuseMetrics.approvalRate * 100).toStringAsFixed(1)}%'],
      if (analytics.excuseMetrics.mostCommonReason != null)
        ['Most Common Reason', '${analytics.excuseMetrics.mostCommonReason} (${analytics.excuseMetrics.mostCommonReasonCount})'],
    ]);

    // Auto-fit columns
    sheet.autoFitColumn(1);
    sheet.autoFitColumn(2);

    // Save the file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/analytics_report.xlsx');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Analytics Report - ${_getDateRangeText(startDate, endDate)}',
    );
  }

  // Helper Methods

  static pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfMetric(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static int _addExcelSection(
    xl.Worksheet sheet,
    int startRow,
    String title,
    List<List<String>> data,
  ) {
    int currentRow = startRow;

    // Section title
    sheet.getRangeByIndex(currentRow, 1, currentRow, 2).merge();
    sheet.getRangeByIndex(currentRow, 1).setText(title);
    sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 14;
    sheet.getRangeByIndex(currentRow, 1).cellStyle.backColor = '#E0E0E0';
    currentRow++;

    // Data rows
    for (final row in data) {
      sheet.getRangeByIndex(currentRow, 1).setText(row[0]);
      sheet.getRangeByIndex(currentRow, 2).setText(row[1]);
      sheet.getRangeByIndex(currentRow, 2).cellStyle.bold = true;
      currentRow++;
    }

    return currentRow;
  }

  static String _getDateRangeText(DateTime? startDate, DateTime? endDate) {
    final dateFormat = DateFormat('dd MMM yyyy');
    if (startDate != null && endDate != null) {
      return '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
    } else if (startDate != null) {
      return 'From ${dateFormat.format(startDate)}';
    } else if (endDate != null) {
      return 'Until ${dateFormat.format(endDate)}';
    }
    return 'All Time';
  }

  static String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
