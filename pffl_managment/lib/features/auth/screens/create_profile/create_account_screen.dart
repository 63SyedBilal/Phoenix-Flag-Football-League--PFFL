import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/features/auth/screens/create_profile/widgets/name_fields.dart';
import 'package:pffl_managment/features/auth/screens/create_profile/widgets/email_field.dart';
import 'package:pffl_managment/features/auth/screens/widgets/phone_number_field.dart';
import 'package:pffl_managment/features/auth/screens/widgets/password_fields.dart';
import 'package:pffl_managment/features/auth/screens/widgets/terms_checkbox.dart';
import 'package:pffl_managment/features/auth/screens/create_profile/widgets/create_account_button.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/shared/widgets/custom_flushbar_widget.dart';

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
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: ArrowBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.white,
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
                    NameFields(
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      provider: signupProvider,
                    ),
                    const SizedBox(height: 16),
                    EmailField(
                      controller: _emailController,
                      provider: signupProvider,
                    ),
                    const SizedBox(height: 16),
                    PhoneNumberField(provider: signupProvider),
                    const SizedBox(height: 16),
                    PasswordFields(
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      signupProvider: signupProvider,
                    ),

                    TermsCheckbox(provider: signupProvider),
                    const SizedBox(height: 16),
                    CreateAccountButton(
                      provider: signupProvider,
                      onPressed: () =>
                          _handleCreateAccount(context, signupProvider),
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

  Future<void> _handleCreateAccount(
    BuildContext context,
    SignupProvider signupProvider,
  ) async {
    FocusScope.of(context).unfocus();

    if (!signupProvider.validateAllFields()) {
      return;
    }

    final success = await signupProvider.signup(context);

    if (success && context.mounted) {
      CustomFlushbarWidget.show(
        context: context,
        message: 'Account created successfully!',
        type: FlushbarType.success,
        duration: const Duration(seconds: 2),
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.freeAgentActiveLeagues,
        (route) => false,
      );
    }
  }
}
