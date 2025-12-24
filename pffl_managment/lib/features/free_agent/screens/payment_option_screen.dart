import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class PaymentOptionScreen extends StatelessWidget {
  const PaymentOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ArrowBackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<FreeAgentOnboardingProvider>(
          builder: (context, provider, child) {
            final selectedLeague = provider.selectedLeague;
            if (selectedLeague == null) {
              // Should not happen if navigated from LeagueSelectionScreen correctly
              return const Center(child: Text('No league selected.'));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complete Your Payment',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your preferred method to pay your league fee.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 30),
                  // Selected League Details (optional, can be expanded if needed)
                  Text(
                    'Selected League: ${selectedLeague.leagueName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '\$${selectedLeague.perPlayerLeagueFee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment Method Options
                  _PaymentMethodOption(
                    label: 'PayPal',
                    iconPath: 'assets/icons/paypal.svg', // Assuming SVG icon exists
                    value: 'paypal',
                    groupValue: provider.selectedPaymentMethod,
                    onChanged: provider.setPaymentMethod,
                  ),
                  const SizedBox(height: 16),
                  _PaymentMethodOption(
                    label: 'Stripe',
                    iconPath: 'assets/icons/stripe.svg', // Assuming SVG icon exists
                    value: 'stripe',
                    groupValue: provider.selectedPaymentMethod,
                    onChanged: provider.setPaymentMethod,
                  ),
                  // Error message display
                  if (provider.errorMessage != null &&
                      provider.errorMessage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.freeAgentAddPaymentDetails,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String label;
  final String iconPath;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _PaymentMethodOption({
    required this.label,
    required this.iconPath,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Assuming you have flutter_svg for SVG images
    // import 'package:flutter_svg/flutter_svg.dart';
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: groupValue == value
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE2E8F0),
            width: groupValue == value ? 2 : 1,
          ),
          boxShadow: [
            if (groupValue == value)
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // SvgPicture.asset(iconPath, width: 24, height: 24), // Uncomment if using SVG
            // Fallback for placeholder if SVG is not used or asset missing
            Text(label[0],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                )),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              activeColor: const Color(0xFF3B82F6),
            ),
          ],
        ),
      ),
    );
  }
}
