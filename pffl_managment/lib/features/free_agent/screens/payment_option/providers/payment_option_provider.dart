import 'package:flutter/material.dart';

class PaymentOptionProvider extends ChangeNotifier {
  String _selectedPaymentMethod = 'stripe';
  bool _isLoading = false;
  String? _errorMessage;

  String get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setPaymentMethod(String method) {
    if (_selectedPaymentMethod == method) return;
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> processPayment() async {
    setLoading(true);
    setErrorMessage(null);
    try {
      // Logic for submitting payment to backend will go here
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
