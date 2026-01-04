import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  bool get isInputComplete {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email) && password.length >= 6;
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void onEmailChanged(String value) {
    if (_emailError != null) {
      _emailError = null;
    }
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    if (_passwordError != null) {
      _passwordError = null;
    }
    notifyListeners();
  }

  bool _validate() {
    bool isValid = true;
    _emailError = null;
    _passwordError = null;

    if (emailController.text.isEmpty) {
      _emailError = 'Please enter your email address';
      isValid = false;
    } else {
      final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailController.text)) {
        _emailError =
            'Please enter a valid email address (e.g. user@example.com)';
        isValid = false;
      }
    }

    if (passwordController.text.isEmpty) {
      _passwordError = 'Please enter your password';
      isValid = false;
    } else if (passwordController.text.length < 6) {
      _passwordError = 'Password must be at least 6 characters long';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  Future<void> handleLogin(BuildContext context) async {
    if (!_validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userPref = Provider.of<UserPreferenceProvider>(
        context,
        listen: false,
      );

      final success = await authProvider.login(
        emailController.text,
        passwordController.text,
        context,
      );

      if (success) {
        String route;
        final role = authProvider.userRole.toLowerCase();

        switch (role) {
          case 'superadmin':
          case 'admin':
            route = AppRoutes.adminDashboard;
            break;
          case 'referee':
            route = userPref.isRefereeProfileComplete
                ? AppRoutes.refereeDashboard
                : AppRoutes.completeRefereeProfile;
            break;
          case 'captain':
            if (authProvider.needsProfileForm) {
              route = AppRoutes.completeCaptainProfile;
            } else if (authProvider.needsTeamForm) {
              route = AppRoutes.captainCreateTeam;
            } else {
              route = AppRoutes.captainDashboard;
            }
            break;
          case 'player':
            final isProfileCompleted =
                await CompleteProfileProvider.checkProfileCompletion(
                  authProvider.userId,
                );
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

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        }
      } else {
        // Sync errors from AuthProvider if any
        _emailError = authProvider.loginEmailError;
        _passwordError = authProvider.loginPasswordError;
      }
    } catch (e) {
      _passwordError = 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
