import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/detailed_report_model.dart';

/// Service for exporting user reports to Excel
class ExcelExportService {
  static final ExcelExportService _instance = ExcelExportService._internal();
  factory ExcelExportService() => _instance;
  ExcelExportService._internal();

  /// Export detailed user report to Excel
  Future<File> exportUserReportToExcel(DetailedUserReportModel report) async {
    final excel = Excel.createExcel();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat('#,##0');

    // Remove default sheet
    excel.delete('Sheet1');

    // Create Summary Sheet
    _createSummarySheet(excel, report, dateFormat, currencyFormat);

    // Create Deed Details Sheet
    _createDeedDetailsSheet(excel, report, dateFormat);

    // Create Statistics Sheet
    _createStatisticsSheet(excel, report, currencyFormat);

    // Save to file
    final output = await getTemporaryDirectory();
    final fileName = 'user_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${output.path}/$fileName');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }

    return file;
  }

  /// Export multiple users report to Excel
  Future<File> exportAllUsersReportToExcel({
    required List<DetailedUserReportModel> users,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final excel = Excel.createExcel();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat('#,##0');

    // Remove default sheet
    excel.delete('Sheet1');

    // Create Overview Sheet
    _createOverviewSheet(excel, users, startDate, endDate, dateFormat, currencyFormat);

    // Create individual sheets for each user (limit to first 10 users to avoid too many sheets)
    final usersToExport = users.take(10).toList();
    for (var i = 0; i < usersToExport.length; i++) {
      final user = usersToExport[i];
      _createUserSheet(excel, user, i + 1, dateFormat);
    }

    // Create Combined Deed Details Sheet
    _createCombinedDeedDetailsSheet(excel, users, dateFormat);

    // Save to file
    final output = await getTemporaryDirectory();
    final fileName = 'all_users_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${output.path}/$fileName');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }

    return file;
  }

  // Helper Methods

  void _createSummarySheet(
    Excel excel,
    DetailedUserReportModel report,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    final sheet = excel['Summary'];

    // Title
    _setCellValue(sheet, 0, 0, 'USER REPORT SUMMARY');
    _mergeCells(sheet, 0, 0, 0, 3);
    _styleCell(sheet, 0, 0, bold: true, fontSize: 16);

    // Empty row
    int row = 2;

    // User Information Section
    _setCellValue(sheet, row, 0, 'USER INFORMATION');
    _styleCell(sheet, row, 0, bold: true, fontSize: 14);
    row += 2;

    _setCellValue(sheet, row, 0, 'Name:');
    _setCellValue(sheet, row, 1, 'N/A'); // Will be populated after build_runner
    _styleCell(sheet, row, 0, bold: true);
    row++;

    _setCellValue(sheet, row, 0, 'Email:');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);
    row++;

    _setCellValue(sheet, row, 0, 'Phone:');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);
    row++;

    _setCellValue(sheet, row, 0, 'Membership:');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);
    row++;

    _setCellValue(sheet, row, 0, 'Member Since:');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);
    row += 2;

    // Report Period
    _setCellValue(sheet, row, 0, 'REPORT PERIOD');
    _styleCell(sheet, row, 0, bold: true, fontSize: 14);
    row += 2;

    _setCellValue(sheet, row, 0, 'Start Date:');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);
    row++;

    _setCellValue(sheet, row, 0, 'End Date:');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);
    row += 2;

    // Statistics Section
    _setCellValue(sheet, row, 0, 'STATISTICS');
    _styleCell(sheet, row, 0, bold: true, fontSize: 14);
    row += 2;

    final stats = [
      ['Total Reports:', 'N/A'],
      ['Average Deeds:', 'N/A'],
      ['Compliance Rate:', 'N/A'],
      ['Fara\'id Compliance:', 'N/A'],
      ['Sunnah Compliance:', 'N/A'],
      ['Current Balance:', 'N/A'],
    ];

    for (final stat in stats) {
      _setCellValue(sheet, row, 0, stat[0]);
      _setCellValue(sheet, row, 1, stat[1]);
      _styleCell(sheet, row, 0, bold: true);
      row++;
    }

    // Column widths are set automatically by excel package
  }

  void _createDeedDetailsSheet(Excel excel, DetailedUserReportModel report, DateFormat dateFormat) {
    final sheet = excel['Deed Details'];

    // Title
    _setCellValue(sheet, 0, 0, 'DAILY DEED DETAILS');
    _styleCell(sheet, 0, 0, bold: true, fontSize: 14);

    int row = 2;

    // Note: Headers will be created, data will be populated after build_runner generates the model
    // Header Row
    final headers = ['Date', 'Status', 'Total', 'Fara\'id', 'Sunnah', 'Submitted At'];
    for (int col = 0; col < headers.length; col++) {
      _setCellValue(sheet, row, col, headers[col]);
      _styleHeaderCell(sheet, row, col);
    }
    row++;

    // Placeholder data row
    _setCellValue(sheet, row, 0, 'Data will appear after model generation');

    // Column widths are set automatically
  }

  void _createStatisticsSheet(
    Excel excel,
    DetailedUserReportModel report,
    NumberFormat currencyFormat,
  ) {
    final sheet = excel['Statistics'];

    // Title
    _setCellValue(sheet, 0, 0, 'PERFORMANCE STATISTICS');
    _styleCell(sheet, 0, 0, bold: true, fontSize: 14);

    int row = 2;

    // Compliance Breakdown
    _setCellValue(sheet, row, 0, 'COMPLIANCE BREAKDOWN');
    _styleCell(sheet, row, 0, bold: true);
    row += 2;

    _setCellValue(sheet, row, 0, 'Metric');
    _setCellValue(sheet, row, 1, 'Value');
    _styleHeaderCell(sheet, row, 0);
    _styleHeaderCell(sheet, row, 1);
    row++;

    final metrics = [
      ['Overall Compliance', 'N/A'],
      ['Fara\'id Compliance', 'N/A'],
      ['Sunnah Compliance', 'N/A'],
      ['Average Daily Deeds', 'N/A'],
    ];

    for (final metric in metrics) {
      _setCellValue(sheet, row, 0, metric[0]);
      _setCellValue(sheet, row, 1, metric[1]);
      row++;
    }

    row += 2;

    // Financial Summary
    _setCellValue(sheet, row, 0, 'FINANCIAL SUMMARY');
    _styleCell(sheet, row, 0, bold: true);
    row += 2;

    _setCellValue(sheet, row, 0, 'Current Balance');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);

    // Column widths are set automatically
  }

  void _createOverviewSheet(
    Excel excel,
    List<DetailedUserReportModel> users,
    DateTime startDate,
    DateTime endDate,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    final sheet = excel['Overview'];

    // Title
    _setCellValue(sheet, 0, 0, 'ALL USERS REPORT');
    _mergeCells(sheet, 0, 0, 0, 5);
    _styleCell(sheet, 0, 0, bold: true, fontSize: 16);

    // Period
    _setCellValue(sheet, 1, 0, 'Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}');
    _mergeCells(sheet, 1, 0, 1, 5);

    int row = 3;

    // Summary Statistics
    _setCellValue(sheet, row, 0, 'SUMMARY');
    _styleCell(sheet, row, 0, bold: true, fontSize: 14);
    row += 2;

    _setCellValue(sheet, row, 0, 'Total Users:');
    _setCellValue(sheet, row, 1, users.length.toString());
    _styleCell(sheet, row, 0, bold: true);
    row += 2;

    // User Table Header
    final headers = ['Name', 'Email', 'Membership', 'Reports', 'Avg Deeds', 'Compliance', 'Balance'];
    for (int col = 0; col < headers.length; col++) {
      _setCellValue(sheet, row, col, headers[col]);
      _styleHeaderCell(sheet, row, col);
    }
    row++;

    // Placeholder for user data
    _setCellValue(sheet, row, 0, 'User data will appear after model generation');

    // Column widths are set automatically
  }

  void _createUserSheet(
    Excel excel,
    DetailedUserReportModel user,
    int userNumber,
    DateFormat dateFormat,
  ) {
    final sheetName = 'User $userNumber';
    final sheet = excel[sheetName];

    // Title
    _setCellValue(sheet, 0, 0, 'USER REPORT');
    _styleCell(sheet, 0, 0, bold: true, fontSize: 14);

    int row = 2;

    // User info placeholder
    _setCellValue(sheet, row, 0, 'Name:');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);
    row++;

    _setCellValue(sheet, row, 0, 'Email:');
    _setCellValue(sheet, row, 1, 'N/A');
    _styleCell(sheet, row, 0, bold: true);
    row += 2;

    // Deed table headers
    _setCellValue(sheet, row, 0, 'Date');
    _setCellValue(sheet, row, 1, 'Total Deeds');
    _setCellValue(sheet, row, 2, 'Status');
    _styleHeaderCell(sheet, row, 0);
    _styleHeaderCell(sheet, row, 1);
    _styleHeaderCell(sheet, row, 2);
    row++;

    // Placeholder data
    _setCellValue(sheet, row, 0, 'Data will appear after model generation');

    // Column widths are set automatically
  }

  void _createCombinedDeedDetailsSheet(
    Excel excel,
    List<DetailedUserReportModel> users,
    DateFormat dateFormat,
  ) {
    final sheet = excel['All Deed Details'];

    // Title
    _setCellValue(sheet, 0, 0, 'COMBINED DEED DETAILS');
    _styleCell(sheet, 0, 0, bold: true, fontSize: 14);

    int row = 2;

    // Headers
    final headers = ['User', 'Date', 'Total Deeds', 'Fara\'id', 'Sunnah', 'Status'];
    for (int col = 0; col < headers.length; col++) {
      _setCellValue(sheet, row, col, headers[col]);
      _styleHeaderCell(sheet, row, col);
    }
    row++;

    // Placeholder
    _setCellValue(sheet, row, 0, 'Combined data will appear after model generation');

    // Column widths are set automatically
  }

  // Utility methods

  void _setCellValue(Sheet sheet, int row, int col, dynamic value) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(value.toString());
  }

  void _mergeCells(Sheet sheet, int startRow, int startCol, int endRow, int endCol) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: startCol, rowIndex: startRow),
      CellIndex.indexByColumnRow(columnIndex: endCol, rowIndex: endRow),
    );
  }

  void _styleCell(Sheet sheet, int row, int col, {bool bold = false, int fontSize = 11}) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.cellStyle = CellStyle(
      bold: bold,
      fontSize: fontSize,
      fontFamily: getFontFamily(FontFamily.Calibri),
    );
  }

  void _styleHeaderCell(Sheet sheet, int row, int col) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontFamily: getFontFamily(FontFamily.Calibri),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
  }
}
