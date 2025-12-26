import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/left_alaign_button.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Store references to providers to avoid accessing them after disposal
  AuthProvider? _authProvider;
  UserPreferenceProvider? _userPreferenceProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store provider references safely during widget lifecycle
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userPreferenceProvider = Provider.of<UserPreferenceProvider>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    // Properly dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    // Clear provider references
    _authProvider = null;
    _userPreferenceProvider = null;
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Check if widget is still mounted before proceeding
    if (!mounted || _authProvider == null) return;

    final success = await _authProvider!.login(
      _emailController.text,
      _passwordController.text,
      context,
    );

    // Check if widget is still mounted after async operation
    if (!mounted || _authProvider == null) return;

    if (success) {
      if (_authProvider!.isLoggedIn) {
        String route;
        switch (_authProvider!.userRole.toLowerCase()) {
          case 'superadmin':
          case 'admin':
            route = AppRoutes.adminDashboard;
            break;
          case 'referee':
            if (!mounted || _userPreferenceProvider == null) return;
            route = _userPreferenceProvider!.isRefereeProfileComplete
                ? AppRoutes.refereeDashboard
                : AppRoutes.completeRefereeProfile;
            break;
          case 'captain':
            // Check if profile or team form is needed for Captain role
            if (_authProvider!.needsProfileForm) {
              route = AppRoutes.completeCaptainProfile;
            } else if (_authProvider!.needsTeamForm) {
              route = AppRoutes.captainCreateTeam;
            } else {
              route = AppRoutes.captainDashboard;
            }
            break;
          case 'player':
            // Check if profile is completed for Player role
            if (!mounted || _authProvider == null) return;
            final isProfileCompleted =
                await CompleteProfileProvider.checkProfileCompletion(
                  _authProvider!.userId,
                );
            // Check again if widget is still mounted after async operation
            if (!mounted) return;
            route = isProfileCompleted
                ? AppRoutes.playerDashboard
                : AppRoutes.completeProfile;
            break;
          case 'statkeeper':
          case 'stat keeper':
          case 'stat-keeper':
            route = AppRoutes.statKeeperDashboard;
            break;
          case 'freeagent':
          case 'free-agent':
          case 'free agent':
            route = AppRoutes.freeAgentActiveLeagues;
            break;
          default:
            route = AppRoutes.playerDashboard;
        }

        // Final check before navigation
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: ArrowBackButton(
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
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

                  RightAlignedButton(text: "Next", onTap: _handleLogin),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
