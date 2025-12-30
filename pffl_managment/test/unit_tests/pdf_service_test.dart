import 'package:flutter_test/flutter_test.dart';
import 'package:pffl_managment/core/services/pdf_service.dart';

// Mock classes would go here if needed for API calls
// For now, we'll test the basic PDF generation logic

void main() {
  group('PdfService', () {
    test('generateReceiptPdf should return Uint8List with valid payment data', () async {
      // Sample payment data
      final paymentData = {
        '_id': 'test_payment_123',
        'amount': 250.0,
        'transactionId': 'txn_123456789',
        'paymentMethod': 'stripe',
        'createdAt': '2024-12-30T10:00:00.000Z',
        'userId': {
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john.doe@example.com',
        },
        'leagueId': {
          'leagueName': 'Phoenix Flag League 2024',
          'format': '5v5',
        },
      };

      // Test that PDF generation completes without error
      final pdfBytes = await PdfService.generateReceiptPdf(paymentData);

      expect(pdfBytes, isA<List<int>>());
      expect(pdfBytes.isNotEmpty, true);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('generateReceiptPdf should handle missing optional fields', () async {
      // Minimal payment data with missing fields
      final paymentData = {
        '_id': 'test_payment_456',
        'amount': 150.0,
        'transactionId': 'txn_987654321',
        'paymentMethod': 'stripe',
      };

      // Should not throw error even with missing fields
      final pdfBytes = await PdfService.generateReceiptPdf(paymentData);

      expect(pdfBytes, isA<List<int>>());
      expect(pdfBytes.isNotEmpty, true);
    });

    test('generateReceiptPdf should handle null values gracefully', () async {
      // Payment data with null values
      final paymentData = {
        '_id': null,
        'amount': null,
        'transactionId': null,
        'paymentMethod': null,
        'createdAt': null,
        'userId': null,
        'leagueId': null,
      };

      // Should handle nulls and use default values
      final pdfBytes = await PdfService.generateReceiptPdf(paymentData);

      expect(pdfBytes, isA<List<int>>());
      expect(pdfBytes.isNotEmpty, true);
    });
  });
}
