import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/core/services/notification_service.dart';

class FreeAgentOnboardingProvider extends ChangeNotifier {
  // --- State Variables ---
  List<LeagueModel> _availableLeagues = [];
  LeagueModel? _selectedLeague;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // --- Payment Details ---
  String _cardholderName = '';
  String _cardNumber = '';
  String _expiryDate = ''; // MM/YY
  String _cvv = '';
  bool _agreedToTerms = false;
  String _selectedPaymentMethod = 'stripe'; // Default
  String _zipCode = '';

  // --- Getters ---
  List<LeagueModel> get availableLeagues => _availableLeagues;
  LeagueModel? get selectedLeague => _selectedLeague;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  String get cardholderName => _cardholderName;
  String get cardNumber => _cardNumber;
  String get expiryDate => _expiryDate;
  String get cvv => _cvv;
  bool get agreedToTerms => _agreedToTerms;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  String get zipCode => _zipCode;

  // --- Setters and Actions ---

  /// Fetches active leagues from the backend
  Future<void> fetchActiveLeagues() async {
    _setLoading(true);
    _clearMessages();
    try {
      final allLeagues = await LeagueService.getAllLeagues();
      _availableLeagues = allLeagues
          .where((league) => league.status.toLowerCase() == 'active')
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load leagues: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Selects a league for registration
  void selectLeague(LeagueModel league) {
    _selectedLeague = league;
    notifyListeners();
  }

  /// Clears selected league
  void clearSelectedLeague() {
    _selectedLeague = null;
    notifyListeners();
  }

  // --- Payment Details Setters ---
  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setCardholderName(String name) {
    _cardholderName = name;
    notifyListeners();
  }

  void setCardNumber(String number) {
    _cardNumber = number;
    notifyListeners();
  }

  void setExpiryDate(String date) {
    _expiryDate = date;
    notifyListeners();
  }

  void setCvv(String value) {
    _cvv = value;
    notifyListeners();
  }

  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  void setZipCode(String code) {
    _zipCode = code;
    notifyListeners();
  }

  // --- Payment Validation ---
  bool validatePaymentDetails() {
    _clearMessages();
    if (_cardholderName.isEmpty) {
      _errorMessage = 'Cardholder name is required.';
      return false;
    }
    if (_cardNumber.isEmpty || _cardNumber.length < 16) {
      _errorMessage = 'Invalid card number.';
      return false;
    }
    if (_expiryDate.isEmpty || !_expiryDate.contains('/')) {
      _errorMessage = 'Expiry date must be in MM/YY format.';
      return false;
    }
    if (_cvv.isEmpty || _cvv.length < 3) {
      _errorMessage = 'Invalid CVV.';
      return false;
    }
    if (_zipCode.isEmpty || _zipCode.length < 5) {
      _errorMessage = 'Invalid ZIP/Postal Code.';
      return false;
    }
    if (!_agreedToTerms) {
      _errorMessage = 'You must agree to the Terms & Privacy.';
      return false;
    }
    return true;
  }

  /// Processes the payment with backend
  Future<bool> processPayment() async {
    _setLoading(true);
    _clearMessages();

    if (!validatePaymentDetails()) {
      _setLoading(false);
      return false;
    }

    if (_selectedLeague == null) {
      _errorMessage = 'No league selected for payment.';
      _setLoading(false);
      return false;
    }

    try {
      // 1. Get or create payment record for the specific league
      debugPrint(
        '💳 Step 1: Getting or creating payment record for league: ${_selectedLeague!.id}',
      );
      final paymentData = await PaymentService.getOrCreatePayment(
        _selectedLeague!.id,
      );

      if (paymentData == null ||
          (paymentData['_id'] == null && paymentData['id'] == null)) {
        _errorMessage =
            'Failed to initialize payment record. Please try again.';
        _setLoading(false);
        return false;
      }

      final String paymentId = (paymentData['_id'] ?? paymentData['id'])
          .toString();

      // 2. Process final payment using the server-side Stripe endpoint

      // Parse expiry date for consistent format
      final expiryParts = _expiryDate.split('/');
      final expMonth = expiryParts.isNotEmpty ? int.tryParse(expiryParts[0]) : null;
      final expYear = expiryParts.length > 1 ? int.tryParse('20${expiryParts[1]}') : null;

      final response = await PaymentService.processPayment(
        paymentId: paymentId,
        paymentMethod: _selectedPaymentMethod, // Pass selected payment method
        cardDetails: {
          'number': _cardNumber.replaceAll(' ', ''),
          'exp_month': expMonth,
          'exp_year': expYear,
          'exp_date': _expiryDate, // Send expiry date as string "MM/YY"
          'cvc': _cvv,
          'name': _cardholderName.trim(),
          'address_zip': _zipCode,
        },
      );

      if (response['success'] == true) {
        _successMessage = 'Payment successful!';

        // Notify Admin
        try {
          await NotificationService.sendAdminNotification(
            message:
                'Free Agent has completed league payment for ${_selectedLeague!.leagueName}',
          );
        } catch (e) {
        }

        // Note: User data refresh happens automatically through AuthProvider
        // which is a global provider and refreshes user data on login

        // Note: Notification refresh will happen automatically through the NotificationProvider
        // which is initialized globally and refreshes on app start

        _setLoading(false);
        return true;
      } else {
        _errorMessage =
            response['error'] ??
            response['message'] ??
            'Payment failed. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  // --- Internal Helpers ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

