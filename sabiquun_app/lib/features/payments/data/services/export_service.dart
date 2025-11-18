import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';

/// Service for exporting payment data to Excel and PDF
class ExportService {
  /// Export payments to Excel file and return bytes for sharing
  Future<List<int>> exportPaymentsToExcel({
    required List<PaymentEntity> payments,
    required String filename,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Payment Report'];

      // Add header row with styling
      final headerRow = [
        'Date',
        'User',
        'Email',
        'Amount',
        'Method',
        'Reference',
        'Status',
        'Reviewed By',
        'Reviewed At',
        'Rejection Reason',
      ];

      // Add headers
      for (var i = 0; i < headerRow.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headerRow[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      // Add data rows
      for (var i = 0; i < payments.length; i++) {
        final payment = payments[i];
        final rowIndex = i + 1;

        final rowData = [
          DateFormat('MMM dd, yyyy - hh:mm a').format(payment.createdAt),
          payment.userName ?? 'N/A',
          payment.userEmail ?? 'N/A',
          payment.amount.toStringAsFixed(0),
          payment.paymentMethodName ?? 'N/A',
          payment.referenceNumber ?? 'N/A',
          payment.status.displayName,
          payment.reviewerName ?? 'N/A',
          payment.reviewedAt != null
              ? DateFormat('MMM dd, yyyy - hh:mm a').format(payment.reviewedAt!)
              : 'N/A',
          payment.rejectionReason ?? 'N/A',
        ];

        for (var j = 0; j < rowData.length; j++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
          );
          cell.value = TextCellValue(rowData[j]);

          // Color code status cells
          if (j == 6) {
            // Status column
            if (payment.status.isApproved) {
              cell.cellStyle = CellStyle(
                backgroundColorHex: ExcelColor.fromHexString('#D4EDDA'),
              );
            } else if (payment.status.isRejected) {
              cell.cellStyle = CellStyle(
                backgroundColorHex: ExcelColor.fromHexString('#F8D7DA'),
              );
            } else {
              cell.cellStyle = CellStyle(
                backgroundColorHex: ExcelColor.fromHexString('#FFF3CD'),
              );
            }
          }
        }
      }

      // Auto-fit columns
      for (var i = 0; i < headerRow.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Return the Excel bytes directly
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      return fileBytes;
    } catch (e) {
      throw Exception('Failed to export to Excel: $e');
    }
  }

  /// Export payments to PDF report
  Future<pw.Document> exportPaymentsToPdf({
    required List<PaymentEntity> payments,
    required String title,
    String? subtitle,
  }) async {
    final pdf = pw.Document();

    // Calculate summary statistics
    final totalAmount = payments.fold<double>(
      0,
      (sum, payment) => sum + (payment.status.isApproved ? payment.amount : 0),
    );
    final approvedCount = payments.where((p) => p.status.isApproved).length;
    final rejectedCount = payments.where((p) => p.status.isRejected).length;
    final pendingCount = payments.where((p) => p.status.isPending).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Header
            _buildPdfHeader(title, subtitle),
            pw.SizedBox(height: 20),

            // Summary Statistics
            _buildSummarySection(
              totalAmount,
              approvedCount,
              rejectedCount,
              pendingCount,
            ),
            pw.SizedBox(height: 30),

            // Payments Table
            _buildPaymentsTable(payments),

            // Footer
            pw.SizedBox(height: 20),
            _buildPdfFooter(),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfHeader(String title, String? subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SABIQUUN',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Payment Management System',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated:',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now()),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Divider(thickness: 2, color: PdfColors.blue700),
        pw.SizedBox(height: 20),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildSummarySection(
    double totalAmount,
    int approvedCount,
    int rejectedCount,
    int pendingCount,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard(
            'Total Approved',
            '${totalAmount.toStringAsFixed(0)} Shillings',
            PdfColors.green,
          ),
          _buildSummaryCard(
            'Approved',
            '$approvedCount',
            PdfColors.green700,
          ),
          _buildSummaryCard(
            'Rejected',
            '$rejectedCount',
            PdfColors.red700,
          ),
          _buildSummaryCard(
            'Pending',
            '$pendingCount',
            PdfColors.orange700,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryCard(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentsTable(List<PaymentEntity> payments) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('User'),
            _buildTableHeader('Amount'),
            _buildTableHeader('Method'),
            _buildTableHeader('Reference'),
            _buildTableHeader('Status'),
            _buildTableHeader('Reviewer'),
          ],
        ),
        // Data rows
        ...payments.map((payment) {
          return pw.TableRow(
            children: [
              _buildTableCell(
                DateFormat('MMM dd, yyyy').format(payment.createdAt),
              ),
              _buildTableCell(payment.userName ?? 'N/A'),
              _buildTableCell(payment.amount.toStringAsFixed(0)),
              _buildTableCell(payment.paymentMethodName ?? 'N/A'),
              _buildTableCell(payment.referenceNumber ?? 'N/A'),
              _buildTableCell(
                payment.status.displayName,
                color: payment.status.isApproved
                    ? PdfColors.green
                    : payment.status.isRejected
                        ? PdfColors.red
                        : PdfColors.orange,
              ),
              _buildTableCell(payment.reviewerName ?? 'N/A'),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          color: color,
        ),
      ),
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            '© ${DateTime.now().year} Sabiquun App. All rights reserved.',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey400,
            ),
          ),
        ),
      ],
    );
  }

  /// Share/download Excel file
  Future<void> shareExcel(List<int> bytes, String filename) async {
    try {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: '$filename.xlsx',
      );
    } catch (e) {
      throw Exception('Failed to share Excel file: $e');
    }
  }

  /// Share/download PDF file
  Future<void> sharePdf(pw.Document pdf, String filename) async {
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '$filename.pdf',
      );
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }
}
