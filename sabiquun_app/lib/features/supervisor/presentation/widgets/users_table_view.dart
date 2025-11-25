import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_report_summary_entity.dart';

/// Table view widget showing all users with daily deeds
class UsersTableView extends StatefulWidget {
  final List<UserReportSummaryEntity> users;
  final VoidCallback onExport;
  final Map<String, Map<String, Map<String, int>>>? dailyDeeds;
  final DateTime? dateRangeStart;
  final DateTime? dateRangeEnd;

  const UsersTableView({
    super.key,
    required this.users,
    required this.onExport,
    this.dailyDeeds,
    this.dateRangeStart,
    this.dateRangeEnd,
  });

  @override
  State<UsersTableView> createState() => _UsersTableViewState();
}

class _UsersTableViewState extends State<UsersTableView> {
  bool _isExporting = false;

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);

    try {
      final excel = excel_pkg.Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Users Report'];

      // Get last 7 days for columns
      final dates = List.generate(7, (index) {
        return DateTime.now().subtract(Duration(days: 6 - index));
      });

      // Header row
      final headers = ['User', 'Membership'];
      for (var date in dates) {
        headers.add(DateFormat('MMM dd').format(date));
      }
      headers.addAll(['Average', 'Compliance']);

      // Add headers
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = excel_pkg.TextCellValue(headers[i]);
        cell.cellStyle = excel_pkg.CellStyle(
          bold: true,
          fontSize: 12,
          fontFamily: excel_pkg.getFontFamily(excel_pkg.FontFamily.Calibri),
          horizontalAlign: excel_pkg.HorizontalAlign.Center,
        );
      }

      // Add data rows
      for (int userIndex = 0; userIndex < widget.users.length; userIndex++) {
        final user = widget.users[userIndex];
        int colIndex = 0;

        // User name
        var cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: userIndex + 1));
        cell.value = excel_pkg.TextCellValue(user.fullName);

        // Membership
        cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: userIndex + 1));
        cell.value = excel_pkg.TextCellValue(_getMembershipBadge(user.membershipStatus));

        // Daily deeds (placeholder)
        for (var date in dates) {
          final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
          cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: userIndex + 1));
          if (isToday) {
            cell.value = excel_pkg.TextCellValue('${user.todayDeeds}/${user.todayTarget}');
          } else {
            cell.value = excel_pkg.TextCellValue('-');
          }
        }

        // Average
        cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: userIndex + 1));
        cell.value = excel_pkg.TextCellValue(user.complianceRate.toStringAsFixed(1));

        // Compliance
        cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: userIndex + 1));
        cell.value = excel_pkg.TextCellValue('${user.complianceRate.toStringAsFixed(0)}%');
      }

      // Save file
      final output = await getTemporaryDirectory();
      final fileName = 'users_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${output.path}/$fileName');
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
      }

      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Users Report - Last 7 Days',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel file exported successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  List<DateTime> _generateDateRange() {
    if (widget.dateRangeStart != null && widget.dateRangeEnd != null) {
      final dates = <DateTime>[];
      var current = DateTime(widget.dateRangeStart!.year, widget.dateRangeStart!.month, widget.dateRangeStart!.day);
      final end = DateTime(widget.dateRangeEnd!.year, widget.dateRangeEnd!.month, widget.dateRangeEnd!.day);

      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        dates.add(current);
        current = current.add(const Duration(days: 1));
      }
      return dates;
    }

    // Default to last 7 days
    return List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateDateRange();

    return Column(
      children: [
        // Header with export button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dateRangeStart != null && widget.dateRangeEnd != null
                          ? 'Date Range Overview'
                          : 'Last 7 Days Overview',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dateRangeStart != null && widget.dateRangeEnd != null
                          ? '${DateFormat('MMM dd').format(widget.dateRangeStart!)} - ${DateFormat('MMM dd, yyyy').format(widget.dateRangeEnd!)} • ${widget.users.length} users'
                          : '${widget.users.length} users',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportToExcel,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.file_download, size: 20),
                label: Text(_isExporting ? 'Exporting...' : 'Export Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowHeight: 56,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 64,
                    headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.08)),
                    border: TableBorder(
                      horizontalInside: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
                    ),
                    columnSpacing: 28,
                    horizontalMargin: 20,
                    columns: [
                      // User column
                      const DataColumn(
                        label: SizedBox(
                          width: 180,
                          child: Text(
                            'User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      // Date columns
                      ...dates.map((date) {
                        final isToday = DateFormat('yyyy-MM-dd').format(date) ==
                            DateFormat('yyyy-MM-dd').format(DateTime.now());
                        return DataColumn(
                          label: Container(
                            width: 90,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: isToday
                                ? BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('MMM dd').format(date),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isToday ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isToday
                                        ? AppColors.primary.withValues(alpha: 0.7)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // Total column
                      const DataColumn(
                        label: SizedBox(
                          width: 80,
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      // Compliance column
                      const DataColumn(
                        label: SizedBox(
                          width: 110,
                          child: Text(
                            'Compliance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: widget.users.map((user) {
                      return DataRow(
                        cells: [
                          // User cell
                          DataCell(
                            SizedBox(
                              width: 180,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                    child: Text(
                                      user.fullName[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.fullName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getMembershipColor(user.membershipStatus)
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getMembershipBadge(user.membershipStatus),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: _getMembershipColor(user.membershipStatus),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Date cells
                          ...dates.map((date) {
                            final dateStr = DateFormat('yyyy-MM-dd').format(date);
                            final isToday = dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());

                            // Try to get data from dailyDeeds first, fall back to todayDeeds for today
                            int deeds = 0;
                            int target = 10;
                            bool hasData = false;

                            if (widget.dailyDeeds != null && widget.dailyDeeds!.containsKey(user.userId)) {
                              final userDeeds = widget.dailyDeeds![user.userId]!;
                              if (userDeeds.containsKey(dateStr)) {
                                deeds = userDeeds[dateStr]!['deeds'] ?? 0;
                                target = userDeeds[dateStr]!['target'] ?? 10;
                                hasData = true;
                              }
                            } else if (isToday) {
                              // Fallback to todayDeeds if no dailyDeeds data
                              deeds = user.todayDeeds;
                              target = user.todayTarget;
                              hasData = true;
                            }

                            return DataCell(
                              Container(
                                width: 90,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: hasData
                                          ? (deeds >= target
                                              ? AppColors.success.withValues(alpha: 0.15)
                                              : deeds > 0
                                                  ? AppColors.warning.withValues(alpha: 0.15)
                                                  : AppColors.error.withValues(alpha: 0.1))
                                          : AppColors.background,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      hasData ? '$deeds/$target' : '-',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: hasData
                                            ? (deeds >= target
                                                ? AppColors.success
                                                : deeds > 0
                                                    ? AppColors.warning
                                                    : AppColors.error)
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Total cell
                          DataCell(
                            Container(
                              width: 80,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Builder(
                                  builder: (context) {
                                    // Calculate total deeds from dailyDeeds data
                                    int totalDeeds = 0;
                                    if (widget.dailyDeeds != null &&
                                        widget.dailyDeeds!.containsKey(user.userId)) {
                                      final userDeeds = widget.dailyDeeds![user.userId]!;
                                      for (final dayData in userDeeds.values) {
                                        totalDeeds += dayData['deeds'] ?? 0;
                                      }
                                    }

                                    return Text(
                                      totalDeeds.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Compliance cell
                          DataCell(
                            Container(
                              width: 110,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        _getComplianceColor(user.complianceRate).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${user.complianceRate.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _getComplianceColor(user.complianceRate),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMembershipBadge(String status) {
    switch (status) {
      case 'new':
        return 'New';
      case 'exclusive':
        return 'Exclusive';
      case 'legacy':
        return 'Legacy';
      default:
        return status;
    }
  }

  Color _getMembershipColor(String status) {
    switch (status) {
      case 'new':
        return AppColors.info;
      case 'exclusive':
        return AppColors.primary;
      case 'legacy':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getComplianceColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 50) return AppColors.warning;
    return AppColors.error;
  }
}
