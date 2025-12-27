import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:intl/intl.dart';

/// Model class for payment history items
class PaymentHistoryItem {
  final String id;
  final String userId;
  final String leagueId;
  final String leagueName;
  final String? leagueLogo;
  final String leagueFormat;
  final String leagueStartDate;
  final String leagueEndDate;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentHistoryItem({
    required this.id,
    required this.userId,
    required this.leagueId,
    required this.leagueName,
    this.leagueLogo,
    required this.leagueFormat,
    required this.leagueStartDate,
    required this.leagueEndDate,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory method to create PaymentHistoryItem from API response
  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    // Handle populated userId object
    final userData = json['userId'];
    String userId = '';
    if (userData is Map<String, dynamic>) {
      userId = userData['_id'] ?? userData['id'] ?? '';
    } else if (userData is String) {
      userId = userData;
    }

    // Handle populated leagueId object
    final leagueData = json['leagueId'];
    String leagueId = '';
    String leagueName = 'Unknown League';
    String? leagueLogo;
    String leagueFormat = 'Unknown Format';
    String leagueStartDate = 'N/A';
    String leagueEndDate = 'N/A';

    if (leagueData is Map<String, dynamic>) {
      // League is populated as an object
      leagueId = leagueData['_id'] ?? leagueData['id'] ?? '';
      leagueName = leagueData['leagueName'] ?? 'Unknown League';
      leagueLogo = leagueData['logo'];
      leagueFormat = leagueData['format'] ?? 'Unknown Format';
      leagueStartDate = _formatDate(leagueData['startDate']);
      leagueEndDate = _formatDate(leagueData['endDate']);
    } else if (leagueData is String) {
      // League is just an ID string (fallback)
      leagueId = leagueData;
      leagueName = json['leagueName'] ?? 'Unknown League';
      leagueLogo = json['leagueLogo'];
      leagueFormat = json['leagueFormat'] ?? 'Unknown Format';
      leagueStartDate = _formatDate(json['leagueStartDate']);
      leagueEndDate = _formatDate(json['leagueEndDate']);
    }

    return PaymentHistoryItem(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userId,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      leagueFormat: leagueFormat,
      leagueStartDate: leagueStartDate,
      leagueEndDate: leagueEndDate,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Unknown',
      status: json['status'] ?? 'unknown',
      transactionId: json['transactionId'] ?? json['stripePaymentIntentId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Helper method to format dates
  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    if (date is String) {
      try {
        final parsed = DateTime.parse(date);
        return DateFormat('dd MMM yyyy').format(parsed);
      } catch (_) {
        return date;
      }
    }

    return date.toString();
  }

  /// Get formatted date for display
  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }

  /// Get formatted time for display
  String get formattedTime {
    return DateFormat('HH:mm').format(createdAt);
  }
}

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
      debugPrint('📊 [PAYMENT HISTORY] Loading player payment history...');

      // Get all payments for the current user
      final paymentsResponse = await PaymentService.fetchUserPayments();

      if (paymentsResponse['success'] == true) {
        final paymentsData = paymentsResponse['data'] as List<dynamic>? ?? [];

        _payments = paymentsData
            .map((payment) => PaymentHistoryItem.fromJson(payment as Map<String, dynamic>))
            .toList();

        // Sort by creation date (newest first)
        _payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        debugPrint('✅ [PAYMENT HISTORY] Loaded ${_payments.length} payments');
      } else {
        _errorMessage = paymentsResponse['message'] ?? paymentsResponse['error'] ?? 'Failed to load payment history';
        debugPrint('❌ [PAYMENT HISTORY] Failed to load payments: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Failed to load payment history: ${e.toString()}';
      debugPrint('❌ [PAYMENT HISTORY] Error: $e');
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
    return _payments.where((payment) => payment.status.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Get paid payments
  List<PaymentHistoryItem> get paidPayments => getPaymentsByStatus('paid');

  /// Get pending payments
  List<PaymentHistoryItem> get pendingPayments => getPaymentsByStatus('pending');

  /// Get failed payments
  List<PaymentHistoryItem> get failedPayments => getPaymentsByStatus('failed');

  /// Get total amount paid
  double get totalAmountPaid {
    return paidPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get payment count by status
  int getPaymentCount(String status) {
    return _payments.where((payment) => payment.status.toLowerCase() == status.toLowerCase()).length;
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
