import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/utils/helpers.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_phone_field.dart';
import 'package:pffl_managment/core/widgets/text_with_text_field.dart';
import 'package:pffl_managment/core/widgets/auth_link.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';

class CreateAccountScreen extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Join PFFL Today", style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              "Create your player account",
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First Name', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      TextWithTextField(
                        hintText: 'e.g bilal',
                        controller: firstNameController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last Name', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      TextWithTextField(
                        hintText: 'e.g ahmed',
                        controller: lastNameController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Text('Email', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextWithTextField(
              hintText: 'e.g bilal@phoenixleague.com',
              controller: emailController,
            ),
            const SizedBox(height: 18),

            // Phone Number
            Text('Phone Number', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            CustomPhoneField(
              onInputChanged: (PhoneNumber number) {
                // Handle phone number input
              },
              onInputValidated: (bool value) {
                // Handle phone number validation
              },
              initialValue: PhoneNumber(isoCode: 'US'),
              hintText: 'e.g +1 123 456 7890',
            ),
            const SizedBox(height: 18),
            Text('Create Password', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextWithTextField(
              hintText: 'Create your password',
              obscureText: !authProvider.isSignupPasswordVisible,
              controller: passwordController,
              suffixIcon: IconButton(
                icon: Icon(
                  authProvider.isSignupPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey,
                ),
                onPressed: authProvider.toggleSignupPasswordVisibility,
              ),
            ),
            const Text("Password strength:"),
            SizedBox(height: 18),
            Text('Confirm Password', style: theme.textTheme.bodyMedium),
            SizedBox(height: 4),
            TextWithTextField(
              hintText: 'Re-enter your password',
              obscureText: !authProvider.isConfirmPasswordVisible,
              controller: confirmPasswordController,
              suffixIcon: IconButton(
                icon: Icon(
                  authProvider.isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey,
                ),
                onPressed: authProvider.toggleConfirmPasswordVisibility,
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'I agree to Terms & Privacy',
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              backgroundColor: AppColors.primaryColor,
              textColor: Colors.white,
              text: 'Create Account',
              onPressed: () {
                final parentContext = context;
                showCustomBottomSheet(
                  icon: Icons.check_circle_outline,
                  context: context,
                  title: 'Account Created',
                  subtitle: "Let's set up your player profile to get started.",
                  buttonText: 'Continue',
                  onButtonPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      parentContext,
                      AppRoutes.completeProfile,
                    );
                  },
                  content: Container(),
                );
              },
            ),
            const SizedBox(height: 12),
            AuthLink(
              text: 'Already have an account? ',
              linkText: 'Login',
              routeName: AppRoutes.login,
            ),
          ],
        ),
      ),
    );
  }
}
