import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/features/payment_history/models/payment_history_item.dart';


/// Provider for managing player payment history
class PlayerPaymentHistoryProvider extends ChangeNotifier {
  List<PaymentHistoryItem> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PaymentHistoryItem> get payments => List.unmodifiable(_payments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load payment history for the current user
  Future<void> loadPaymentHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {

      // Get all payments for the current user
      final paymentsResponse = await PaymentService.fetchUserPayments();

      if (paymentsResponse['success'] == true) {
        final paymentsData = paymentsResponse['data'] as List<dynamic>? ?? [];

        // Parse all payments first
        final allPayments = paymentsData
            .map(
              (payment) =>
                  PaymentHistoryItem.fromJson(payment as Map<String, dynamic>),
            )
            .toList();

        // Filter to show only PAID payments (jo player ne actually pay ki hain)
        _payments = allPayments
            .where((payment) => payment.status.toLowerCase() == 'paid')
            .toList();

        // Sort by creation date (newest first)
        _payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        debugPrint(
          '✅ [PAYMENT HISTORY] Total payments found: ${allPayments.length}',
        );
        debugPrint(
          '✅ [PAYMENT HISTORY] Paid payments loaded: ${_payments.length}',
        );

        // Log payment statuses for debugging
        for (var payment in allPayments) {
          debugPrint(
            '   - Payment ${payment.id.substring(payment.id.length - 6)}: ${payment.status} - ${payment.leagueName}',
          );
        }
      } else {
        _errorMessage =
            paymentsResponse['message'] ??
            paymentsResponse['error'] ??
            'Failed to load payment history';
        debugPrint(
          '❌ [PAYMENT HISTORY] Failed to load payments: $_errorMessage',
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load payment history: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh payment history
  Future<void> refresh() async {
    await loadPaymentHistory();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get payments by status
  List<PaymentHistoryItem> getPaymentsByStatus(String status) {
    return _payments
        .where(
          (payment) => payment.status.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  /// Get paid payments
  List<PaymentHistoryItem> get paidPayments => getPaymentsByStatus('paid');

  /// Get pending payments
  List<PaymentHistoryItem> get pendingPayments =>
      getPaymentsByStatus('pending');

  /// Get failed payments
  List<PaymentHistoryItem> get failedPayments => getPaymentsByStatus('failed');

  /// Get total amount paid
  double get totalAmountPaid {
    return paidPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get payment count by status
  int getPaymentCount(String status) {
    return _payments
        .where(
          (payment) => payment.status.toLowerCase() == status.toLowerCase(),
        )
        .length;
  }

  /// Check if user has any paid leagues
  bool get hasPaidLeagues => paidPayments.isNotEmpty;

  /// Get unique leagues paid for
  Set<String> get uniquePaidLeagues {
    return paidPayments.map((payment) => payment.leagueName).toSet();
  }

  /// Get most recent payment
  PaymentHistoryItem? get mostRecentPayment {
    if (_payments.isEmpty) return null;
    return _payments.first; // Already sorted by date
  }
}

