import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/left_alaign_button.dart';
import 'package:pffl_managment/features/auth/providers/login_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: Builder(
        builder: (context) {
          final provider = Provider.of<LoginProvider>(context);
          final theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(
              leading: ArrowBackButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: theme.appBarTheme.backgroundColor,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Welcome Back\nto PFFL",
                      style: theme.textTheme.headlineLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Log in to access your teams and games",
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 26),

                    Text("Email Address", style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: provider.emailController,
                      hintText: "e.g admin@gmail.com",
                      keyboardType: TextInputType.emailAddress,
                      errorText: provider.emailError,
                      onChanged: (value) => provider.onEmailChanged(value),
                    ),

                    const SizedBox(height: 16),

                    Text("Password", style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: provider.passwordController,
                      hintText: "Enter your password",
                      obscureText: !provider.isPasswordVisible,
                      errorText: provider.passwordError,
                      onChanged: (value) => provider.onPasswordChanged(value),
                      suffixIcon: IconButton(
                        icon: Icon(
                          provider.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey,
                        ),
                        onPressed: provider.togglePasswordVisibility,
                      ),
                    ),

                    const SizedBox(height: 30),

                    RightAlignedButton(
                      text: "Next",
                      backgroundColor: provider.isInputComplete
                          ? const Color(0xFF0F173E)
                          : null,
                      textColor: provider.isInputComplete ? Colors.white : null,
                      onTap: () => provider.handleLogin(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
