import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_onboarding_provider.dart';
import 'package:provider/provider.dart';

class AddPaymentDetailsScreen extends StatefulWidget {
  const AddPaymentDetailsScreen({super.key});

  @override
  State<AddPaymentDetailsScreen> createState() =>
      _AddPaymentDetailsScreenState();
}

class _AddPaymentDetailsScreenState extends State<AddPaymentDetailsScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _zipController.dispose();
    super.dispose();
  }

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
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Payment Details',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your card information for league registration.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Cardholder Name',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'John Doe',
                    onChanged: provider.setCardholderName,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Card Number',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _cardNumberController,
                    hintText: '0000 0000 0000 0000',
                    keyboardType: TextInputType.number,
                    onChanged: provider.setCardNumber,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expiry Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _expiryController,
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.datetime,
                              onChanged: provider.setExpiryDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CVV',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _cvvController,
                              hintText: '000',
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              onChanged: provider.setCvv,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'ZIP/Postal Code',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _zipController,
                    hintText: '12345',
                    keyboardType: TextInputType.number,
                    onChanged: provider.setZipCode,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Checkbox(
                        value: provider.agreedToTerms,
                        onChanged: (value) =>
                            provider.setAgreedToTerms(value ?? false),
                        activeColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the PFFL Terms & Privacy Policy',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            final success = await provider.processPayment();
                            if (success) {
                              if (mounted) {
                                _showSuccessDialog(context);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Pay Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 64),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'You have successfully joined the league. Your spot is now confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/free-agent/dashboard',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
