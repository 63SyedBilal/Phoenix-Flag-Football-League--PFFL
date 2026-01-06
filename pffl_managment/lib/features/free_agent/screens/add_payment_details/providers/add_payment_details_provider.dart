import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/player_freeagent_trigger_service.dart';
import 'package:pffl_managment/core/services/admin_trigger_service.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/providers/league_selection_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/models/payment_state.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/utils/payment_validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/providers/league_payment_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/providers/pending_payment_provider.dart';

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
    BuildContext context,
  ) async {
    // Debug output for form state before validation

    if (!validateForm()) {
      return false;
    }

    _state = _state.copyWith(isLoading: true, clearGeneralError: true);
    notifyListeners();

    if (leagueProvider.selectedLeagues.isEmpty) {
      try {
        // Check PendingPaymentProvider first
        final pendingProvider = Provider.of<PendingPaymentProvider>(
          context,
          listen: false,
        );
        String? pendingLeagueId = pendingProvider.pendingLeagueId;

        // Fallback to SharedPreferences if not in provider
        if (pendingLeagueId == null) {
          final prefs = await SharedPreferences.getInstance();
          pendingLeagueId = prefs.getString('pendingLeagueId');
        }

        if (pendingLeagueId != null && pendingLeagueId.trim().isNotEmpty) {
          final leagueDetail = await LeagueService.getLeagueById(
            pendingLeagueId.trim(),
          );

          if (leagueDetail != null) {
            final allLeagues = await LeagueService.getAllLeagues();
            final leagueModel = allLeagues
                .where((l) => l.id == pendingLeagueId!.trim())
                .cast<LeagueModel?>()
                .firstWhere((l) => l != null, orElse: () => null);

            final effectiveLeague =
                leagueModel ??
                LeagueModel(
                  id: pendingLeagueId.trim(),
                  leagueName: leagueDetail.leagueName,
                  format: leagueDetail.format,
                  startDate: leagueDetail.startDate,
                  endDate: leagueDetail.endDate,
                  minimumPlayers: 0,
                  perPlayerLeagueFee: 0,
                  logo: null,
                  status: 'pending',
                  createdAt: null,
                );

            leagueProvider.clearAllSelections();
            leagueProvider.toggleLeagueSelection(effectiveLeague);
          }
        }
      } catch (_) {
        // Ignore and fall through to error state.
      }
    }

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

        final response = await PaymentService.processPayment(
          paymentId: paymentId,
          paymentMethod: 'stripe',
          cardDetails: cardDetails,
        );

        if (response['success'] != true) {
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

        // Trigger Notifications
        try {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final userName = authProvider.userName;
          final userId = authProvider.userId;
          final teamName =
              'Free Agent Team'; // Would be better to get real team name if available
          final amount = league.perPlayerLeagueFee.toDouble();
          final timestamp = DateTime.now().toString();

          // Notify Player
          await PlayerFreeAgentTriggerService.triggerPlayerLeaguePayment(
            userId: userId,
            leagueName: league.leagueName,
            amount: amount,
            teamName: teamName,
          );

          // Notify Admin
          await AdminTriggerService.triggerPlayerLeaguePayment(
            playerName: userName,
            amount: amount,
            leagueName: league.leagueName,
            teamName: teamName,
            timestamp: timestamp,
            paymentId: paymentId,
            playerId: userId,
          );
        } catch (e) {
          // Don't fail payment if notification fails
        }
      }

      if (allSuccessful) {
        // REFRESH LEAGUE PAYMENT STATUS IN REAL-TIME
        try {
          final leaguePaymentProvider = Provider.of<LeaguePaymentProvider>(
            context,
            listen: false,
          );
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final captainId = authProvider.userId;

          if (captainId.isNotEmpty) {
            for (var league in leagueProvider.selectedLeagues) {
              await leaguePaymentProvider.refreshPaymentStatus(
                league.id,
                captainId,
              );
            }
          }
        } catch (e) {}

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
