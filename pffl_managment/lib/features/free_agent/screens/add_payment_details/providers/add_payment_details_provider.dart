import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/core/services/notification_service.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/providers/league_selection_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/models/payment_state.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/utils/payment_validators.dart';

class AddPaymentDetailsProvider extends ChangeNotifier {
  PaymentState _state = const PaymentState();

  PaymentState get state => _state;

  void setCardholderName(String value) {
    _state = _state.copyWith(
      cardholderName: value,
      clearCardholderNameError: true,
    );
    notifyListeners();
  }

  void setCardNumber(String value) {
    _state = _state.copyWith(cardNumber: value, clearCardNumberError: true);
    notifyListeners();
  }

  void setExpiryDate(String value) {
    _state = _state.copyWith(expiryDate: value, clearExpiryDateError: true);
    notifyListeners();
  }

  void setCvv(String value) {
    _state = _state.copyWith(cvv: value, clearCvvError: true);
    notifyListeners();
  }

  void setZipCode(String value) {
    _state = _state.copyWith(zipCode: value, clearZipCodeError: true);
    notifyListeners();
  }

  void setAgreedToTerms(bool value) {
    _state = _state.copyWith(agreedToTerms: value, clearAgreementError: true);
    notifyListeners();
  }

  bool validateForm() {
    final nameErr = PaymentValidators.validateCardholderName(
      _state.cardholderName,
    );
    final cardErr = PaymentValidators.validateCardNumber(_state.cardNumber);
    final expiryErr = PaymentValidators.validateExpiryDate(_state.expiryDate);
    final cvvErr = PaymentValidators.validateCvv(_state.cvv);
    final zipErr = PaymentValidators.validateZipCode(_state.zipCode);
    final agreementErr = PaymentValidators.validateAgreement(
      _state.agreedToTerms,
    );

    _state = _state.copyWith(
      cardholderNameError: nameErr,
      cardNumberError: cardErr,
      expiryDateError: expiryErr,
      cvvError: cvvErr,
      zipCodeError: zipErr,
      agreementError: agreementErr,
    );
    notifyListeners();

    return _state.isFormValid;
  }

  Future<bool> processMultiLeaguePayment(
    LeagueSelectionProvider leagueProvider,
  ) async {
    // Debug output for form state before validation
    debugPrint('📋 Form validation starting...');
    debugPrint('   - Cardholder: "${_state.cardholderName}"');
    debugPrint('   - Card Number: "${_state.cardNumber}" (length: ${_state.cardNumber.length})');
    debugPrint('   - Expiry Date: "${_state.expiryDate}"');
    debugPrint('   - CVV: "${_state.cvv}" (length: ${_state.cvv.length})');
    debugPrint('   - ZIP Code: "${_state.zipCode}"');
    debugPrint('   - Agreed to Terms: ${_state.agreedToTerms}');

    if (!validateForm()) {
      debugPrint('❌ Form validation failed');
      return false;
    }
    debugPrint('✅ Form validation passed');

    _state = _state.copyWith(isLoading: true, clearGeneralError: true);
    notifyListeners();

    if (leagueProvider.selectedLeagues.isEmpty) {
      _state = _state.copyWith(
        isLoading: false,
        generalError: 'No leagues selected for payment.',
      );
      notifyListeners();
      return false;
    }

    try {
      bool allSuccessful = true;
      for (var league in leagueProvider.selectedLeagues) {
        final paymentData = await PaymentService.getOrCreatePayment(league.id);
        debugPrint('🔍 Raw Payment Initialization Data: $paymentData');
        if (paymentData == null) {
          allSuccessful = false;
          continue;
        }

        final String paymentId = (paymentData['_id'] ?? paymentData['id'])
            .toString();

        final expiryParts = _state.expiryDate.split('/');
        final expMonth = expiryParts.isNotEmpty
            ? int.tryParse(expiryParts[0])
            : null;
        final expYear = expiryParts.length > 1
            ? int.tryParse('20${expiryParts[1]}')
            : null;

        // Card details in Stripe format - include both formats
        final cardDetails = {
          'number': _state.cardNumber.replaceAll(' ', ''),
          'exp_month': expMonth,
          'exp_year': expYear,
          'exp_date': _state.expiryDate, // Send expiry date as string "MM/YY"
          'cvc': _state.cvv,
          'name': _state.cardholderName.trim(),
          'address_zip': _state.zipCode,
        };

        // Debug output for card details
        debugPrint('💳 Processing payment for ${league.leagueName}');
        debugPrint('   - Payment ID: $paymentId');
        debugPrint('   - Raw Expiry Date from state: "${_state.expiryDate}"');
        debugPrint('   - Parsed Month: $expMonth, Year: $expYear');
        debugPrint('   - Card Number: ${_state.cardNumber.replaceAll(' ', '').replaceRange(0, 12, '*' * 12)}');
        debugPrint('   - CVV: ***');
        debugPrint('   - Cardholder: "${_state.cardholderName}"');
        debugPrint('   - ZIP Code: "${_state.zipCode}"');
        debugPrint('   - Card Details Object: $cardDetails');

        final response = await PaymentService.processPayment(
          paymentId: paymentId,
          paymentMethod: 'stripe',
          cardDetails: cardDetails,
        );

        if (response['success'] != true) {
          debugPrint('❌ Payment failed for ${league.leagueName}');
          debugPrint('   - Response: $response');
          debugPrint('   - Error: ${response['error']}');
          debugPrint('   - Message: ${response['message']}');

          allSuccessful = false;
          _state = _state.copyWith(
            isLoading: false,
            generalError:
                response['error'] ??
                response['message'] ??
                'Payment failed for ${league.leagueName}',
          );
          notifyListeners();
          return false;
        }

        try {
          await NotificationService.sendAdminNotification(
            message:
                'Free Agent has completed league payment for ${league.leagueName}',
          );
        } catch (e) {
          debugPrint('Error sending admin notification: $e');
        }
      }

      if (allSuccessful) {
        debugPrint('🎉 All payments processed successfully!');
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        _clearSensitiveData();
        return true;
      }

      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return false;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        generalError: 'An unexpected error occurred: ${e.toString()}',
      );
      notifyListeners();
      return false;
    }
  }

  void _clearSensitiveData() {
    _state =
        const PaymentState(); // Reset everything on success or just sensitive? User said clean up.
    notifyListeners();
  }
}
