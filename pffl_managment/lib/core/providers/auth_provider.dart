import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userToken = '';
  String _userRole = '';
  String _userId = '';
  String _userEmail = '';

  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _loginEmailError;
  String? _loginPasswordError;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userToken => _userToken;
  String get userRole => _userRole;
  String get userId => _userId;
  String get userEmail => _userEmail;

  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  String? get loginEmailError => _loginEmailError;
  String? get loginPasswordError => _loginPasswordError;

  AuthProvider() {
    checkLoginStatus();
  }

  // Login method with real backend integration
  Future<bool> login(String email, String password, BuildContext context) async {
    try {
      // Trim whitespace from email and password
      final trimmedEmail = email.trim();
      final trimmedPassword = password.trim();
      
      // Call the AuthService to perform login
      final authResponse = await AuthService.login(trimmedEmail, trimmedPassword);
      
      if (authResponse != null) {
        // Login successful
        _isLoggedIn = true;
        _userToken = authResponse.token;
        _userRole = authResponse.data.role;
        _userId = authResponse.data.id;
        _userEmail = authResponse.data.email;

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _userToken);
        await prefs.setString('role', _userRole);
        await prefs.setString('userId', _userId);
        await prefs.setString('userEmail', _userEmail);

        notifyListeners();

        // Show success message
        Flushbar(
          message: 'Login successful!',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ).show(context);

        return true;
      } else {
        // Login failed
        Flushbar(
          message: 'Incorrect email or password. Please check your credentials and try again.',
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
          icon: Icon(Icons.error_outline, color: Colors.white),
        ).show(context);
        return false;
      }
    } catch (e) {
      // Show error message with icon
      print('Login exception: $e');
      Flushbar(
        message: 'Login failed. Please check your connection and try again.',
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        icon: Icon(Icons.error_outline, color: Colors.white),
      ).show(context);
      return false;
    }
  }

  // Register method with real backend integration
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Prepare user data
      final userData = {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone,
        'password': password,
        'role': 'free-agent', // Default role for new registrations is free-agent
      };
      
      // Call the AuthService to perform registration
      final authResponse = await AuthService.register(userData);
      
      if (authResponse != null) {
        // Registration successful
        _isLoggedIn = true;
        _userToken = authResponse.token;
        _userRole = authResponse.data.role;
        _userId = authResponse.data.id;
        _userEmail = authResponse.data.email;

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _userToken);
        await prefs.setString('role', _userRole);
        await prefs.setString('userId', _userId);
        await prefs.setString('userEmail', _userEmail);

        notifyListeners();

        // Show success message
        Flushbar(
          message: 'Registration successful!',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ).show(context);

        return true;
      } else {
        // Registration failed, show error
        Flushbar(
          message: 'Registration failed. Please try again.',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          icon: Icon(Icons.error_outline, color: Colors.white),
        ).show(context);
        return false;
      }
    } catch (e) {
      // Show error message with icon
      print('Registration exception: $e');
      Flushbar(
        message: 'Registration failed. Please check your connection and try again.',
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        icon: Icon(Icons.error_outline, color: Colors.white),
      ).show(context);
      return false;
    }
  }

  // Logout method
  Future<void> logout(BuildContext context) async {
    _isLoggedIn = false;
    _userToken = '';
    _userRole = '';
    _userId = '';
    _userEmail = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('userId');
    await prefs.remove('userEmail');

    notifyListeners();

    // Show success message
    Flushbar(
      message: 'Logged out successfully!',
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    ).show(context);
  }

  // Check if user is already logged in
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final userId = prefs.getString('userId');
    final userEmail = prefs.getString('userEmail');

    if (token != null && role != null && userId != null && userEmail != null) {
      _isLoggedIn = true;
      _userToken = token;
      _userRole = role;
      _userId = userId;
      _userEmail = userEmail;
      notifyListeners();
    }
  }

  // Password visibility toggle methods
  void toggleLoginPasswordVisibility() {
    _isLoginPasswordVisible = !_isLoginPasswordVisible;
    notifyListeners();
  }

  void toggleSignupPasswordVisibility() {
    _isSignupPasswordVisible = !_isSignupPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  // Clear login errors
  void clearLoginErrors() {
    _loginEmailError = null;
    _loginPasswordError = null;
    notifyListeners();
  }
}