import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class AddPaymentDetailsScreen extends StatefulWidget {
  const AddPaymentDetailsScreen({super.key});

  @override
  State<AddPaymentDetailsScreen> createState() =>
      _AddPaymentDetailsScreenState();
}

class _AddPaymentDetailsScreenState extends State<AddPaymentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardholderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FreeAgentOnboardingProvider>(
      context,
      listen: false,
    );
    _cardholderNameController.text = provider.cardholderName;
    _cardNumberController.text = provider.cardNumber;
    _expiryDateController.text = provider.expiryDate;
    _cvvController.text = provider.cvv;
    _zipCodeController.text = provider.zipCode;
  }

  @override
  void dispose() {
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _zipCodeController.dispose();
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
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
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
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your card information below to complete the payment securely.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: _cardholderNameController,
                      label: 'Cardholder Name',
                      hint: 'Enter the name printed on your card',
                      onChanged: provider.setCardholderName,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Cardholder name is required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _cardNumberController,
                      label: 'Card Number',
                      hint: '16-digit card number',
                      keyboardType: TextInputType.number,
                      suffixIcon: SvgPicture.asset(
                        'assets/icons/mastercard.svg', // Assuming this asset exists
                        width: 24, 
                        height: 24, 
                      ),
                      onChanged: provider.setCardNumber,
                      validator: (value) => value == null || value.length < 16
                          ? 'Invalid card number'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _expiryDateController,
                            label: 'Expiry Date',
                            hint: 'MM/YY',
                            keyboardType: TextInputType.datetime,
                            onChanged: provider.setExpiryDate,
                            validator: (value) => value == null ||
                                    !value.contains('/') ||
                                    value.length < 5
                                ? 'Invalid expiry date (MM/YY)'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField(
                            controller: _cvvController,
                            label: 'CVV',
                            hint: '3-digit code',
                            keyboardType: TextInputType.number,
                            suffixIcon: const Icon(Icons.visibility_off),
                            isObscureText: true,
                            onChanged: provider.setCvv,
                            validator: (value) => value == null || value.length < 3
                                ? 'Invalid CVV'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _zipCodeController,
                      label: 'ZIP/Postal Code',
                      hint: 'e.g. 10001',
                      keyboardType: TextInputType.number,
                      onChanged: provider.setZipCode,
                      validator: (value) => value == null || value.length < 5
                          ? 'Invalid ZIP/Postal Code'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: provider.agreedToTerms,
                          onChanged: (bool? value) {
                            provider.setAgreedToTerms(value ?? false);
                          },
                          activeColor: const Color(0xFF0F172A),
                        ),
                        const Text(
                          'I agree to Terms & Privacy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
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
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() &&
                                  provider.agreedToTerms) {
                                final success = await provider.processPayment();
                                if (success) {
                                  Flushbar(
                                    message: provider.successMessage ?? 'Payment successful!',
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 28.0,
                                      color: Colors.white,
                                    ),
                                    duration: const Duration(seconds: 3),
                                    leftBarIndicatorColor: Colors.green,
                                  ).show(context).then((value) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.freeAgentDashboard, // Navigate to Free Agent Dashboard
                                      (route) => false,
                                    );
                                  });
                                } else if (provider.errorMessage != null) {
                                  Flushbar(
                                    message: provider.errorMessage!,
                                    icon: const Icon(
                                      Icons.info_outline,
                                      size: 28.0,
                                      color: Colors.white,
                                    ),
                                    duration: const Duration(seconds: 5),
                                    leftBarIndicatorColor: Colors.red,
                                  ).show(context);
                                }
                              } else if (!provider.agreedToTerms) {
                                Flushbar(
                                  message: 'You must agree to Terms & Privacy',
                                  icon: const Icon(
                                    Icons.info_outline,
                                    size: 28.0,
                                    color: Colors.white,
                                  ),
                                  duration: const Duration(seconds: 3),
                                  leftBarIndicatorColor: Colors.red,
                                ).show(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(0xFF94A3B8),
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Pay Now',
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool isObscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isObscureText,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: suffixIcon,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
