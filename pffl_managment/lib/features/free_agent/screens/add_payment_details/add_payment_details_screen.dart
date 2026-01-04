import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/providers/league_selection_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/providers/add_payment_details_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/widgets/payment_header.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/widgets/payment_text_field.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/widgets/terms_checkbox.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/widgets/pay_now_button.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/shared/widgets/custom_flushbar_widget.dart';

class AddPaymentDetailsScreen extends StatelessWidget {
  final TextEditingController _cardholderNameController =
      TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  AddPaymentDetailsScreen({super.key});

  @override
  Widget build(
    BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: ArrowBackButton()),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PaymentHeader(),
                      const SizedBox(height: 30),
                      Consumer<AddPaymentDetailsProvider>(
                        builder: (context, provider, _) {
                          final state = provider.state;
                          return Column(
                            children: [
                              PaymentTextField(
                                controller: _cardholderNameController,
                                label: 'Cardholder Name',
                                hint: 'Enter the name printed on your card',
                                onChanged: provider.setCardholderName,
                                error: state.cardholderNameError,
                              ),
                              const SizedBox(height: 16),
                              PaymentTextField(
                                controller: _cardNumberController,
                                label: 'Card Number',
                                hint: '16-digit card number',
                                onChanged: provider.setCardNumber,
                                error: state.cardNumberError,
                                keyboardType: TextInputType.number,
                                suffixIcon: SvgPicture.asset(
                                  'assets/icons/home_icons/card.svg',
                                  width: 24,
                                  height: 24,
                                  placeholderBuilder: (context) => const Icon(
                                    Icons.credit_card,
                                    size: 24,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                 Expanded(
  child: PaymentTextField(
    controller: _expiryDateController,
    label: 'Expiry Date',
    hint: 'MM/YY',
    onChanged: provider.setExpiryDate,
    error: state.expiryDateError,
    keyboardType: TextInputType.datetime,
    suffixIcon: SvgPicture.asset(
      'assets/icons/home_icons/dateVectorIcon.svg',
      width: 18,
      height: 18,
      placeholderBuilder: (context) => const Icon(
        Icons.calendar_today_outlined,
        size: 18,
        color: Color(0xFF9CA3AF),
      ),
    ),
  ),
),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: PaymentTextField(
                                      controller: _cvvController,
                                      label: 'CVV',
                                      
                                      hint: '3-digit code',
                                      onChanged: provider.setCvv,
                                      error: state.cvvError,
                                      keyboardType: TextInputType.number,
                                      isObscureText: true,
                                      suffixIcon: const Icon(
                                        Icons.visibility_off_outlined,
                                        size: 18,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              PaymentTextField(
                                controller: _zipCodeController,
                                label: 'ZIP/Postal Code',
                                hint: 'e.g. 10001',
                                onChanged: provider.setZipCode,
                                error: state.zipCodeError,
                                keyboardType: TextInputType.number,
                                suffixIcon: const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TermsCheckbox(
                                value: state.agreedToTerms,
                                onChanged: (val) =>
                                    provider.setAgreedToTerms(val ?? false),
                                error: state.agreementError,
                              ),
                              const SizedBox(height: 24),

                              Consumer<LeagueSelectionProvider>(
                                builder: (context, leagueProvider, _) {
                                  return PayNowButton(
                                    isLoading: state.isLoading,
                                    onPressed: () => _handlePayment(
                                      context,
                                      provider,
                                      leagueProvider,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment(
    BuildContext context,
    AddPaymentDetailsProvider provider,
    LeagueSelectionProvider leagueProvider,
  ) async {
    FocusScope.of(context).unfocus();

    // Debug output for payment initiation
    debugPrint(
      '   - Selected leagues: ${leagueProvider.selectedLeagues.length}',
    );
    debugPrint(
      '   - Leagues: ${leagueProvider.selectedLeagues.map((l) => l.leagueName).join(', ')}',
    );

    final success = await provider.processMultiLeaguePayment(
      leagueProvider,
      context,
    );

    if (success && context.mounted) {
      CustomFlushbarWidget.show(
        context: context,
        message: 'Payment processed successfully!',
        type: FlushbarType.success,
      );

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.freeAgentDashboard, (route) => false);
    } else if (provider.state.generalError != null && context.mounted) {
      CustomFlushbarWidget.show(
        context: context,
        message: provider.state.generalError!,
        type: FlushbarType.error,
      );
    }
  }
}