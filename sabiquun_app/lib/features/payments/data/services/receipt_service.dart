import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/fifo_payment_distribution.dart';

/// Service for generating payment receipts in PDF format
class ReceiptService {
  /// Generate a PDF receipt for an approved payment
  Future<pw.Document> generatePaymentReceipt({
    required PaymentEntity payment,
    required FifoPaymentDistribution distribution,
    required String cashierName,
    required String receiptNumber,
  }) async {
    final pdf = pw.Document();

    // Load custom font (optional)
    // final font = await PdfGoogleFonts.robotoRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(receiptNumber),
              pw.SizedBox(height: 30),

              // Receipt Title
              pw.Center(
                child: pw.Text(
                  'PAYMENT RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  DateFormat('MMMM dd, yyyy - hh:mm a').format(DateTime.now()),
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Divider
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // User Information Section
              _buildSection(
                'USER INFORMATION',
                [
                  _buildInfoRow('Name:', payment.userName ?? 'N/A'),
                  _buildInfoRow('Email:', payment.userEmail ?? 'N/A'),
                  _buildInfoRow('User ID:', payment.userId),
                ],
              ),
              pw.SizedBox(height: 20),

              // Payment Information Section
              _buildSection(
                'PAYMENT INFORMATION',
                [
                  _buildInfoRow(
                    'Amount Paid:',
                    payment.formattedAmount,
                    isBold: true,
                  ),
                  _buildInfoRow(
                    'Payment Method:',
                    payment.paymentMethodName ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Reference Number:',
                    payment.referenceNumber ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Payment Type:',
                    payment.amount >= distribution.currentBalance
                        ? 'Full Payment'
                        : 'Partial Payment',
                  ),
                  _buildInfoRow(
                    'Submission Date:',
                    DateFormat('MMM dd, yyyy - hh:mm a')
                        .format(payment.createdAt),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Balance Information
              _buildSection(
                'BALANCE SUMMARY',
                [
                  _buildInfoRow(
                    'Previous Balance:',
                    distribution.formattedCurrentBalance,
                  ),
                  _buildInfoRow(
                    'Payment Applied:',
                    '-${distribution.formattedTotalApplied}',
                  ),
                  _buildInfoRow(
                    'New Balance:',
                    distribution.formattedNewBalance,
                    isBold: true,
                    color: distribution.newBalance > 0
                        ? PdfColors.orange
                        : PdfColors.green,
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // FIFO Payment Distribution
              if (distribution.applications.isNotEmpty) ...[
                _buildPaymentDistribution(distribution),
                pw.SizedBox(height: 20),
              ],

              // Footer
              pw.Spacer(),
              _buildFooter(cashierName, receiptNumber),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(String receiptNumber) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SABIQUUN',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Islamic Accountability System',
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Receipt #',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              receiptNumber,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentDistribution(FifoPaymentDistribution distribution) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.blue50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT DISTRIBUTION (FIFO ORDER)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Your payment was applied to the following penalties in First-In-First-Out order:',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 10),
          // Table header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue100,
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    '#',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Amount Applied',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Status',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Table rows
          ...distribution.applications.asMap().entries.map((entry) {
            final index = entry.key;
            final app = entry.value;
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                ),
                color: index % 2 == 0 ? PdfColors.white : PdfColors.grey50,
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      '${index + 1}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      DateFormat('MMM dd, yyyy').format(app.penalty.dateIncurred),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      app.formattedAmountApplied,
                      style: const pw.TextStyle(fontSize: 9),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      app.isFullyPaid ? 'PAID ✓' : 'PARTIAL',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: app.isFullyPaid ? PdfColors.green : PdfColors.orange,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
          // Total row
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue100,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL APPLIED:',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  distribution.formattedTotalApplied,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(String cashierName, String receiptNumber) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Processed by:',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  cashierName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
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
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Center(
          child: pw.Text(
            'This is an automatically generated receipt. No signature required.',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey500,
            ),
          ),
        ),
        pw.SizedBox(height: 5),
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

  /// Save PDF to device and return file path
  Future<String> savePdfToDevice(pw.Document pdf, String receiptNumber) async {
    try {
      final output = await getApplicationDocumentsDirectory();
      final fileName = 'receipt_$receiptNumber.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      throw Exception('Failed to save receipt: $e');
    }
  }

  /// Share or print PDF
  Future<void> sharePdf(pw.Document pdf, String receiptNumber) async {
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'receipt_$receiptNumber.pdf',
      );
    } catch (e) {
      throw Exception('Failed to share receipt: $e');
    }
  }

  /// Print PDF directly
  Future<void> printPdf(pw.Document pdf) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      throw Exception('Failed to print receipt: $e');
    }
  }

  /// Generate unique receipt number
  String generateReceiptNumber() {
    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    final random = (now.millisecond * 1000 + now.microsecond) % 10000;
    return 'RCP-$timestamp-${random.toString().padLeft(4, '0')}';
  }
}
