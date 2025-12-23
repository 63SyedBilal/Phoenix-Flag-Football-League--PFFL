import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/left_alaign_button.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
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
                controller: _emailController,
                hintText: "e.g admin@gmail.com",
                keyboardType: TextInputType.emailAddress,
                errorText: authProvider.loginEmailError,
                onChanged: (value) {
                  // Clear email error when user types
                  if (authProvider.loginEmailError != null) {
                    authProvider.clearLoginEmailError();
                  }
                },
              ),

              const SizedBox(height: 16),

              Text("Password", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _passwordController,
                hintText: "Enter your password",
                obscureText: !authProvider.isLoginPasswordVisible,
                errorText: authProvider.loginPasswordError,
                onChanged: (value) {
                  // Clear password error when user types
                  if (authProvider.loginPasswordError != null) {
                    authProvider.clearLoginPasswordError();
                  }
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    authProvider.isLoginPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey,
                  ),
                  onPressed: authProvider.toggleLoginPasswordVisibility,
                ),
              ),

              const SizedBox(height: 30),

              RightAlignedButton(
                text: "Next",
                onTap: () async {
                  final success = await authProvider.login(
                    _emailController.text,
                    _passwordController.text,
                    context,
                  );

                  if (success) {
                    if (authProvider.isLoggedIn) {
                      String route;
                      switch (authProvider.userRole) {
                        case 'superadmin':
                          route = AppRoutes.adminDashboard;
                          break;
                        case 'referee':
                          final userPrefs = Provider.of<UserPreferenceProvider>(
                            context,
                            listen: false,
                          );
                          route = userPrefs.isRefereeProfileComplete
                              ? AppRoutes.refereeDashboard
                              : AppRoutes.completeRefereeProfile;
                          break;
                        case 'captain':
                          // Check if profile or team form is needed for Captain role
                          if (authProvider.needsProfileForm) {
                            route = AppRoutes.completeCaptainProfile;
                          } else if (authProvider.needsTeamForm) {
                            route = AppRoutes.captainCreateTeam;
                          } else {
                            route = AppRoutes.captainDashboard;
                          }
                          break;
                        case 'player':
                          // Check if profile is completed for Player role
                          final isProfileCompleted =
                              await CompleteProfileProvider.checkProfileCompletion(
                                authProvider.userId,
                              );
                          route = isProfileCompleted
                              ? AppRoutes.playerDashboard
                              : AppRoutes.completeProfile;
                          break;
                        case 'statkeeper':
                          route = AppRoutes.statKeeperDashboard;
                          break;
                        case 'freeagent':
                          route = AppRoutes.freeAgentDashboard;
                          break;
                        default:
                          route = AppRoutes.playerDashboard;
                      }

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        route,
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
