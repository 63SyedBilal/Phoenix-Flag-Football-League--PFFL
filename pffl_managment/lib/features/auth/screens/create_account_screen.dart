import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/password_strength_indicator.dart';
import 'package:pffl_managment/core/widgets/auth_link.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class CreateAccountScreen extends StatelessWidget {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ArrowBackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<SignupProvider>(
              builder: (context, signupProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Join PFFL Today",
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create your account to get started",
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 26),

                    // First Name and Last Name Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'First Name',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: _firstNameController,
                                hintText: 'e.g John',
                                onChanged: (value) {
                                  signupProvider.updateFirstName(value);
                                },
                              ),
                              if (signupProvider.firstNameError != null)
                                _buildErrorContainer(
                                  signupProvider.firstNameError!,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last Name',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: _lastNameController,
                                hintText: 'e.g Doe',
                                onChanged: (value) {
                                  signupProvider.updateLastName(value);
                                },
                              ),
                              if (signupProvider.lastNameError != null)
                                _buildErrorContainer(
                                  signupProvider.lastNameError!,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    Text('Email Address', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'e.g john@example.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        signupProvider.updateEmail(value);
                      },
                    ),
                    if (signupProvider.emailError != null)
                      _buildErrorContainer(signupProvider.emailError!),

                    const SizedBox(height: 16),

                    // Phone Number Field
                    Text('Phone Number', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    ImprovedPhoneField(
                      onInputChanged: (PhoneNumber number) {
                        signupProvider.updatePhoneNumber(number);
                      },
                      onInputValidated: (bool value) {
                        // Validation handled in provider
                      },
                      initialCountryCode: 'US',
                      hintText: 'Enter phone number',
                      errorText: signupProvider.phoneError,
                    ),

                    const SizedBox(height: 16),

                    // Create Password Field
                    Text('Create Password', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return CustomTextField(
                          controller: _passwordController,
                          hintText: 'Create your password',
                          obscureText: !authProvider.isSignupPasswordVisible,
                          onChanged: (value) {
                            signupProvider.updatePassword(value);
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.isSignupPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              authProvider.toggleSignupPasswordVisibility();
                            },
                          ),
                        );
                      },
                    ),
                    // Password Strength Indicator
                    PasswordStrengthIndicator(
                      strength: signupProvider.passwordStrength,
                      password: signupProvider.password,
                    ),
                    if (signupProvider.passwordError != null)
                      _buildErrorContainer(signupProvider.passwordError!),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    Text('Confirm Password', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Re-enter your password',
                          obscureText: !authProvider.isConfirmPasswordVisible,
                          onChanged: (value) {
                            signupProvider.updateConfirmPassword(value);
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              authProvider.toggleConfirmPasswordVisibility();
                            },
                          ),
                        );
                      },
                    ),
                    if (signupProvider.confirmPasswordError != null)
                      _buildErrorContainer(
                        signupProvider.confirmPasswordError!,
                      ),

                    const SizedBox(height: 16),

                    // Agreement Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: signupProvider.agreedToTerms,
                          onChanged: (value) {
                            signupProvider.updateAgreedToTerms(value ?? false);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              signupProvider.updateAgreedToTerms(
                                !signupProvider.agreedToTerms,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'I Agree to Terms & Privacy',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white70
                                      : AppColors.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (signupProvider.agreementError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: _buildErrorContainer(
                          signupProvider.agreementError!,
                        ),
                      ),

                    // General Error Message
                    if (signupProvider.generalError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _buildErrorContainer(
                          signupProvider.generalError!,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Create Account',
                        backgroundColor:
                            signupProvider.isFormValid &&
                                !signupProvider.isLoading
                            ? AppColors.primaryColor
                            : AppColors.primaryColor.withOpacity(0.5),
                        textColor: Colors.white,
                        isLoading: signupProvider.isLoading,
                        onPressed:
                            signupProvider.isFormValid &&
                                !signupProvider.isLoading
                            ? () =>
                                  _handleCreateAccount(context, signupProvider)
                            : () {},
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Login Link
                    AuthLink(
                      text: 'Already have an account? ',
                      linkText: 'Login',
                      routeName: AppRoutes.login,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContainer(String errorMessage) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.red, width: 1.0),
      ),
      child: Row(
        children: [
          SvgIcons.infoFill(size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateAccount(
    BuildContext context,
    SignupProvider signupProvider,
  ) async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Attempt signup
    final success = await signupProvider.signup(context);

    if (success && context.mounted) {
      // Show success message and redirect to Free Agent active leagues screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: const Color(0xFF10B981), // Success green color
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to Free Agent active leagues screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.freeAgentActiveLeagues,
        (route) => false,
      );
    }
  }
}
