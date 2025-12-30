import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pffl_managment/core/services/payment_service.dart';

/// Service for generating PDF receipts
class PdfService {
  static const String _receiptsFolder = 'receipts';

  /// Generate PDF receipt for a payment
  static Future<Uint8List> generateReceiptPdf(Map<String, dynamic> paymentData) async {
    final pdf = pw.Document();

    // Extract payment details
    final paymentId = paymentData['_id'] ?? paymentData['id'] ?? 'N/A';
    final amount = (paymentData['amount'] ?? 0).toDouble();
    final transactionId = paymentData['transactionId'] ?? paymentData['stripePaymentIntentId'] ?? 'N/A';
    final paymentMethod = paymentData['paymentMethod'] ?? 'Unknown';
    final createdAt = paymentData['createdAt'];

    // Extract user details
    final userData = paymentData['userId'];
    String userName = 'Unknown User';
    String userEmail = 'N/A';

    if (userData is Map<String, dynamic>) {
      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';
      userName = '$firstName $lastName'.trim();
      userEmail = userData['email'] ?? 'N/A';
    }

    // Extract league details
    final leagueData = paymentData['leagueId'];
    String leagueName = 'Unknown League';
    String leagueFormat = 'Unknown Format';

    if (leagueData is Map<String, dynamic>) {
      leagueName = leagueData['leagueName'] ?? 'Unknown League';
      leagueFormat = leagueData['format'] ?? 'Unknown Format';
    }

    // Format date
    String paymentDate = 'N/A';
    if (createdAt != null) {
      try {
        final dateTime = DateTime.parse(createdAt.toString());
        paymentDate = '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        paymentDate = createdAt.toString();
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with PFFL branding
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Phoenix Flag Football League',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Payment Receipt',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Receipt details
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Receipt number and date
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Receipt #: $paymentId',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Date: $paymentDate',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    pw.Divider(),
                    pw.SizedBox(height: 20),

                    // User Information
                    pw.Text(
                      'Customer Information',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Name: $userName'),
                    pw.Text('Email: $userEmail'),

                    pw.SizedBox(height: 20),

                    // League Information
                    pw.Text(
                      'League Information',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('League: $leagueName'),
                    pw.Text('Format: $leagueFormat'),

                    pw.SizedBox(height: 20),

                    // Payment Details
                    pw.Text(
                      'Payment Details',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),

                    // Payment table
                    pw.TableHelper.fromTextArray(
                      headers: ['Description', 'Amount'],
                      data: [
                        ['League Registration', '\$${amount.toStringAsFixed(2)}'],
                        ['Processing Fee', '\$0.00'],
                        ['Total', '\$${amount.toStringAsFixed(2)}'],
                      ],
                      headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.blue900,
                      ),
                      cellAlignment: pw.Alignment.centerLeft,
                      cellPadding: const pw.EdgeInsets.all(8),
                    ),

                    pw.SizedBox(height: 20),

                    // Transaction details
                    pw.Text(
                      'Transaction Information',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Transaction ID: $transactionId'),
                    pw.Text('Payment Method: $paymentMethod'),
                    pw.Text('Status: Paid'),

                    pw.SizedBox(height: 30),

                    // Footer
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Thank you for choosing Phoenix Flag Football League!',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontStyle: pw.FontStyle.italic,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'For questions about this payment, please contact support@pffl.com',
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),

                    pw.SizedBox(height: 20),

                    // Terms and conditions
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Terms & Conditions',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            '• This receipt serves as proof of payment for league registration.\n'
                            '• Refunds are processed according to league policies.\n'
                            '• All payments are final unless otherwise stated.\n'
                            '• For dispute resolution, contact league administration.',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Save PDF receipt to local storage
  static Future<String> saveReceiptPdf(Uint8List pdfBytes, String paymentId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${directory.path}/$_receiptsFolder');

      // Create receipts directory if it doesn't exist
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final fileName = 'receipt_$paymentId.pdf';
      final file = File('${receiptsDir.path}/$fileName');

      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      rethrow;
    }
  }

  /// Share PDF receipt
  static Future<void> shareReceiptPdf(String filePath, String paymentId) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'PFFL Payment Receipt - Transaction $paymentId',
        subject: 'Phoenix Flag Football League Receipt',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generate and save receipt for a payment
  static Future<String> generateAndSaveReceipt(String paymentId) async {
    try {
      // Fetch payment data from backend
      final paymentData = await PaymentService.getPaymentById(paymentId);

      if (paymentData == null) {
        throw Exception('Payment data not found');
      }

      // Generate PDF
      final pdfBytes = await generateReceiptPdf(paymentData);

      // Save PDF
      final filePath = await saveReceiptPdf(pdfBytes, paymentId);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  /// Generate and share receipt for a payment
  static Future<void> generateAndShareReceipt(String paymentId) async {
    try {
      final filePath = await generateAndSaveReceipt(paymentId);
      await shareReceiptPdf(filePath, paymentId);
    } catch (e) {
      rethrow;
    }
  }
}

