import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/detailed_report_model.dart';

/// Service for exporting user reports to PDF
class PdfExportService {
  static final PdfExportService _instance = PdfExportService._internal();
  factory PdfExportService() => _instance;
  PdfExportService._internal();

  /// Export detailed user report to PDF
  Future<File> exportUserReportToPdf(DetailedUserReportModel report) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat('#,##0');

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(report, dateFormat),
          pw.SizedBox(height: 24),

          // User Information Section
          _buildUserInfoSection(report, dateFormat),
          pw.SizedBox(height: 20),

          // Statistics Section
          _buildStatisticsSection(report, currencyFormat),
          pw.SizedBox(height: 20),

          // Deed Details Table
          _buildDeedDetailsTable(report, dateFormat),
          pw.SizedBox(height: 20),

          // Footer
          _buildFooter(),
        ],
      ),
    );

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final fileName = 'user_report_${report.userId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Export multiple users report to PDF
  Future<File> exportAllUsersReportToPdf({
    required List<DetailedUserReportModel> users,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat('#,##0');

    // Summary Page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Title
          pw.Text(
            'All Users Report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.Divider(height: 24, thickness: 2),

          // Summary Statistics
          _buildAllUsersSummary(users, currencyFormat),
          pw.SizedBox(height: 20),

          // Users Overview Table
          _buildUsersOverviewTable(users, currencyFormat),
        ],
      ),
    );

    // Individual User Pages
    for (final user in users) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Text(
              user.fullName,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              user.email,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Divider(height: 16, thickness: 1),
            pw.SizedBox(height: 12),

            _buildUserInfoSection(user, dateFormat),
            pw.SizedBox(height: 16),

            _buildStatisticsSection(user, currencyFormat),
            pw.SizedBox(height: 16),

            _buildDeedDetailsTable(user, dateFormat),
          ],
        ),
      );
    }

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final fileName = 'all_users_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Helper Methods

  pw.Widget _buildHeader(DetailedUserReportModel report, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'User Report',
          style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated on ${dateFormat.format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(height: 24, thickness: 2),
      ],
    );
  }

  pw.Widget _buildUserInfoSection(DetailedUserReportModel report, DateFormat dateFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'User Information',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name:', report.fullName),
                    _buildInfoRow('Email:', report.email),
                    if (report.phoneNumber != null)
                      _buildInfoRow('Phone:', report.phoneNumber!),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Membership:', _formatMembership(report.membershipStatus)),
                    if (report.memberSince != null)
                      _buildInfoRow('Member Since:', dateFormat.format(report.memberSince!)),
                    _buildInfoRow('Report Period:',
                        '${dateFormat.format(report.startDate)} - ${dateFormat.format(report.endDate)}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatisticsSection(DetailedUserReportModel report, NumberFormat currencyFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary Statistics',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Total Reports', '${report.totalReportsInRange}'),
              _buildStatCard('Average Deeds', report.averageDeeds.toStringAsFixed(1)),
              _buildStatCard('Compliance', '${report.complianceRate.toStringAsFixed(1)}%'),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Fara\'id', '${report.faraidCompliance.toStringAsFixed(1)}%'),
              _buildStatCard('Sunnah', '${report.sunnahCompliance.toStringAsFixed(1)}%'),
              _buildStatCard('Balance', '${currencyFormat.format(report.currentBalance)} SH'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDeedDetailsTable(DetailedUserReportModel report, DateFormat dateFormat) {
    // Get all unique deed names from the first report
    final deedNames = report.dailyReports.isNotEmpty
        ? report.dailyReports.first.deedEntries.map((e) => e.deedName).toList()
        : <String>[];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Daily Deed Details',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),

        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FixedColumnWidth(80),
            ...Map.fromIterable(
              List.generate(deedNames.length, (i) => i + 1),
              key: (i) => i,
              value: (_) => const pw.FlexColumnWidth(1),
            ),
            deedNames.length + 1: const pw.FixedColumnWidth(50),
          },
          children: [
            // Header Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Date', isHeader: true),
                ...deedNames.map((name) => _buildTableCell(_abbreviateDeedName(name), isHeader: true)),
                _buildTableCell('Total', isHeader: true),
              ],
            ),

            // Data Rows
            ...report.dailyReports.map((dailyReport) {
              return pw.TableRow(
                children: [
                  _buildTableCell(DateFormat('MMM dd').format(dailyReport.reportDate)),
                  ...dailyReport.deedEntries.map((entry) {
                    final value = entry.valueType == 'binary'
                        ? (entry.deedValue == 1 ? '✓' : '✗')
                        : entry.deedValue.toStringAsFixed(1);
                    return _buildTableCell(value,
                        color: entry.deedValue >= 1.0 ? PdfColors.green100 : null);
                  }),
                  _buildTableCell(dailyReport.totalDeeds.toStringAsFixed(1),
                      color: dailyReport.totalDeeds >= 10.0 ? PdfColors.green100 : PdfColors.orange100),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildAllUsersSummary(List<DetailedUserReportModel> users, NumberFormat currencyFormat) {
    final totalReports = users.fold<int>(0, (sum, user) => sum + user.totalReportsInRange);
    final avgCompliance = users.fold<double>(0, (sum, user) => sum + user.complianceRate) / users.length;
    final totalBalance = users.fold<double>(0, (sum, user) => sum + user.currentBalance);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total Users', '${users.length}'),
          _buildStatCard('Total Reports', '$totalReports'),
          _buildStatCard('Avg Compliance', '${avgCompliance.toStringAsFixed(1)}%'),
          _buildStatCard('Total Balance', '${currencyFormat.format(totalBalance)} SH'),
        ],
      ),
    );
  }

  pw.Widget _buildUsersOverviewTable(List<DetailedUserReportModel> users, NumberFormat currencyFormat) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Name', isHeader: true),
            _buildTableCell('Reports', isHeader: true),
            _buildTableCell('Avg Deeds', isHeader: true),
            _buildTableCell('Compliance', isHeader: true),
            _buildTableCell('Balance', isHeader: true),
          ],
        ),

        // Data Rows
        ...users.map((user) => pw.TableRow(
          children: [
            _buildTableCell(user.fullName),
            _buildTableCell('${user.totalReportsInRange}'),
            _buildTableCell(user.averageDeeds.toStringAsFixed(1)),
            _buildTableCell('${user.complianceRate.toStringAsFixed(1)}%'),
            _buildTableCell('${currencyFormat.format(user.currentBalance)}'),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatCard(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      color: color,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      child: pw.Column(
        children: [
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated by Sabiquun App - Islamic Deed Tracker',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatMembership(String status) {
    switch (status) {
      case 'new':
        return 'New Member';
      case 'exclusive':
        return 'Exclusive Member';
      case 'legacy':
        return 'Legacy Member';
      default:
        return status;
    }
  }

  String _abbreviateDeedName(String name) {
    // Abbreviate long deed names for table headers
    final abbreviations = {
      'Fajr Prayer': 'Fajr',
      'Duha Prayer': 'Duha',
      'Dhuhr Prayer': 'Dhuhr',
      'Juz of Quran': 'Juz',
      'Asr Prayer': 'Asr',
      'Sunnah Prayers': 'Sunnah',
      'Maghrib Prayer': 'Maghrib',
      'Isha Prayer': 'Isha',
      'Athkar': 'Athkar',
      'Witr': 'Witr',
    };
    return abbreviations[name] ?? name;
  }
}
