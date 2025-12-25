import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/auth_link.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/features/auth/screens/widgets/error_container.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class CreateAccountButton extends StatelessWidget {
  final SignupProvider provider;
  final VoidCallback onPressed;

  const CreateAccountButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (provider.generalError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ErrorContainer(message: provider.generalError!),
          ),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Create Account',
            backgroundColor: AppColors.primaryColor,
            textColor: Colors.white,
            isLoading: provider.isLoading,
            onPressed: provider.isLoading ? () {} : onPressed,
          ),
        ),
        const SizedBox(height: 16),
        const AuthLink(
          text: 'Already have an account? ',
          linkText: 'Login',
          routeName: AppRoutes.login,
        ),
      ],
    );
  }
}
