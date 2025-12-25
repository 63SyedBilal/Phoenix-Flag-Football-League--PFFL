import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/providers/league_selection_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/payment_option/providers/payment_option_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/payment_option/widgets/payment_header.dart';
import 'package:pffl_managment/features/free_agent/screens/payment_option/widgets/total_amount_display.dart';
import 'package:pffl_managment/features/free_agent/screens/payment_option/widgets/payment_method_option.dart';
import 'package:pffl_managment/features/free_agent/screens/payment_option/widgets/proceed_to_payment_button.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class PaymentOptionScreen extends StatelessWidget {
  const PaymentOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Consumer2<LeagueSelectionProvider, PaymentOptionProvider>(
          builder: (context, leagueProvider, paymentProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PaymentHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      TotalAmountDisplay(amount: leagueProvider.totalPrice),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF000000),
                            fontFamily: "Lato",
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PaymentMethodOption(
                        type: 'stripe',
                        isSelected:
                            paymentProvider.selectedPaymentMethod == 'stripe',
                        onTap: () => paymentProvider.setPaymentMethod('stripe'),
                      ),
                    ],
                  ),
                ),
                ProceedToPaymentButton(
                  isLoading: paymentProvider.isLoading,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.freeAgentAddPaymentDetails,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
