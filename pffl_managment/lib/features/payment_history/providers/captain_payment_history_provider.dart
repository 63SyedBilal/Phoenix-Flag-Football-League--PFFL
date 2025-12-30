import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/features/payment_history/models/payment_history_item.dart';

/// Provider for managing captain payment history
/// Captains can view payments made by their team members
class CaptainPaymentHistoryProvider extends ChangeNotifier {
  List<PaymentHistoryItem> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;
  final String? userRole;

  CaptainPaymentHistoryProvider({this.userRole});

  // Getters
  List<PaymentHistoryItem> get payments => List.unmodifiable(_payments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load payment history for the captain's team
  Future<void> loadPaymentHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint(
        '📊 [CAPTAIN PAYMENT HISTORY] Loading team payment history...',
      );
      debugPrint('📊 [CAPTAIN PAYMENT HISTORY] User role: $userRole');

      // Check if user is actually a captain
      if (userRole?.toLowerCase() != 'captain') {
        debugPrint(
          '⚠️ [CAPTAIN PAYMENT HISTORY] User is not a captain, loading personal payments instead',
        );

        // Load personal payments instead
        final paymentsResponse = await PaymentService.fetchUserPayments();

        if (paymentsResponse['success'] == true) {
          final paymentsData = paymentsResponse['data'] as List<dynamic>? ?? [];

          _payments = paymentsData
              .map(
                (payment) => PaymentHistoryItem.fromJson(
                  payment as Map<String, dynamic>,
                ),
              )
              .toList();

          // Sort by creation date (newest first)
          _payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          debugPrint(
            '✅ [CAPTAIN PAYMENT HISTORY] Loaded ${_payments.length} personal payments',
          );
        } else {
          _errorMessage =
              paymentsResponse['message'] ??
              paymentsResponse['error'] ??
              'Failed to load payment history';
          debugPrint(
            '❌ [CAPTAIN PAYMENT HISTORY] Failed to load payments: $_errorMessage',
          );
        }
      } else {
        // Captain - try to get team payments first
        debugPrint(
          '📊 [CAPTAIN PAYMENT HISTORY] Attempting to load team payments...',
        );
        final teamPaymentsResponse = await PaymentService.fetchTeamPayments();

        if (teamPaymentsResponse['success'] == true) {
          final paymentsData =
              teamPaymentsResponse['data'] as List<dynamic>? ?? [];

          _payments = paymentsData
              .map(
                (payment) => PaymentHistoryItem.fromJson(
                  payment as Map<String, dynamic>,
                ),
              )
              .toList();

          // Sort by creation date (newest first)
          _payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          debugPrint(
            '✅ [CAPTAIN PAYMENT HISTORY] Loaded ${_payments.length} team payments',
          );
        } else {
          // Team payments failed - check if it's because captain has no team
          final errorMsg =
              teamPaymentsResponse['message'] ??
              teamPaymentsResponse['error'] ??
              '';
          debugPrint(
            '⚠️ [CAPTAIN PAYMENT HISTORY] Team payments failed: $errorMsg',
          );

          // If error is about not having a team, fall back to personal payments
          if (errorMsg.toLowerCase().contains('not a captain') ||
              errorMsg.toLowerCase().contains('no team')) {
            debugPrint(
              '📊 [CAPTAIN PAYMENT HISTORY] Captain has no team, loading personal payments instead...',
            );

            // Fall back to personal payments
            final paymentsResponse = await PaymentService.fetchUserPayments();

            if (paymentsResponse['success'] == true) {
              final paymentsData =
                  paymentsResponse['data'] as List<dynamic>? ?? [];

              _payments = paymentsData
                  .map(
                    (payment) => PaymentHistoryItem.fromJson(
                      payment as Map<String, dynamic>,
                    ),
                  )
                  .toList();

              // Sort by creation date (newest first)
              _payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              debugPrint(
                '✅ [CAPTAIN PAYMENT HISTORY] Loaded ${_payments.length} personal payments',
              );
            } else {
              _errorMessage =
                  paymentsResponse['message'] ??
                  paymentsResponse['error'] ??
                  'Failed to load payment history';
              debugPrint(
                '❌ [CAPTAIN PAYMENT HISTORY] Failed to load personal payments: $_errorMessage',
              );
            }
          } else {
            // Other error - show it
            _errorMessage = errorMsg.isNotEmpty
                ? errorMsg
                : 'Failed to load team payment history';
            debugPrint(
              '❌ [CAPTAIN PAYMENT HISTORY] Failed to load payments: $_errorMessage',
            );
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load payment history: ${e.toString()}';
      debugPrint('❌ [CAPTAIN PAYMENT HISTORY] Error: $e');
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

  /// Get total revenue from team payments
  double get totalTeamRevenue {
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

  /// Get unique payers (team members who have paid)
  Set<String> get uniquePayers {
    return _payments.map((payment) => payment.userId).toSet();
  }

  /// Get payments grouped by league
  Map<String, List<PaymentHistoryItem>> get paymentsByLeague {
    final Map<String, List<PaymentHistoryItem>> grouped = {};
    for (final payment in _payments) {
      if (!grouped.containsKey(payment.leagueName)) {
        grouped[payment.leagueName] = [];
      }
      grouped[payment.leagueName]!.add(payment);
    }
    return grouped;
  }

  /// Get league with most payments
  String? get mostPopularLeague {
    if (paymentsByLeague.isEmpty) return null;

    String? topLeague;
    int maxPayments = 0;

    paymentsByLeague.forEach((leagueName, payments) {
      if (payments.length > maxPayments) {
        maxPayments = payments.length;
        topLeague = leagueName;
      }
    });

    return topLeague;
  }

  /// Get most recent payment
  PaymentHistoryItem? get mostRecentPayment {
    if (_payments.isEmpty) return null;
    return _payments.first; // Already sorted by date
  }

  /// Get pending payments count
  int get pendingPaymentsCount => pendingPayments.length;

  /// Get paid payments count
  int get paidPaymentsCount => paidPayments.length;
}
