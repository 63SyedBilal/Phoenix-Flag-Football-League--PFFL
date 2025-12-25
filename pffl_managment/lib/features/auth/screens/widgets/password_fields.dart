import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/password_strength_indicator.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/features/auth/screens/widgets/error_container.dart';

class PasswordFields extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final SignupProvider signupProvider;

  const PasswordFields({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.signupProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create Password', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return CustomTextField(
              controller: passwordController,
              hintText: 'Create your password',
              obscureText: !authProvider.isSignupPasswordVisible,
              onChanged: (value) => signupProvider.updatePassword(value),
              suffixIcon: IconButton(
                icon: Icon(
                  authProvider.isSignupPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey,
                ),
                onPressed: () => authProvider.toggleSignupPasswordVisibility(),
              ),
            );
          },
        ),
        PasswordStrengthIndicator(
          strength: signupProvider.passwordStrength,
          password: signupProvider.password,
        ),
        if (signupProvider.passwordError != null)
          ErrorContainer(message: signupProvider.passwordError!),
        const SizedBox(height: 16),
        Text('Confirm Password', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return CustomTextField(
              controller: confirmPasswordController,
              hintText: 'Re-enter your password',
              obscureText: !authProvider.isConfirmPasswordVisible,
              onChanged: (value) => signupProvider.updateConfirmPassword(value),
              suffixIcon: IconButton(
                icon: Icon(
                  authProvider.isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey,
                ),
                onPressed: () => authProvider.toggleConfirmPasswordVisibility(),
              ),
            );
          },
        ),
        if (signupProvider.confirmPasswordError != null)
          ErrorContainer(message: signupProvider.confirmPasswordError!),
      ],
    );
  }
}
