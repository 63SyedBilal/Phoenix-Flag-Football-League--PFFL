import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userToken = '';
  String _userRole = '';
  String _userId = '';
  String _userEmail = '';
  String _userName = '';

  // Password visibility states
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Login error states
  String? _loginEmailError;
  String? _loginPasswordError;
  String? _loginGeneralError;

  bool get isLoggedIn => _isLoggedIn;
  String get userToken => _userToken;
  String get userRole => _userRole;
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;

  // Password visibility getters
  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  // Login error getters
  String? get loginEmailError => _loginEmailError;
  String? get loginPasswordError => _loginPasswordError;
  String? get loginGeneralError => _loginGeneralError;

  AuthProvider() {
    checkLoginStatus();
  }

  // Client-side validation helper methods
  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _loginEmailError = 'Email is required';
      return false;
    }
    // Simple email validation
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _loginEmailError = 'Please enter a valid email address';
      return false;
    }
    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      _loginPasswordError = 'Password is required';
      return false;
    }
    if (password.length < 6) {
      _loginPasswordError = 'Password must be at least 6 characters';
      return false;
    }
    return true;
  }

  // Login method with real backend integration using AuthService
  Future<bool> login(String email, String password, BuildContext context) async {
    print('Attempting login with email: $email');
    // Clear previous errors
    clearLoginErrors();
    
    // Perform client-side validation
    final isEmailValid = _validateEmail(email);
    final isPasswordValid = _validatePassword(password);
    
    // If validation fails, update UI and return
    if (!isEmailValid || !isPasswordValid) {
      notifyListeners();
      return false;
    }
    
    try {
      // Use AuthService to make the API call
      final authResponse = await AuthService.login(email, password);
      
      if (authResponse != null) {
        // Extract user data from response
        final userData = authResponse.data;
        
        _isLoggedIn = true;
        _userToken = authResponse.token;
        _userRole = userData.role; // Already mapped by AuthService
        _userId = userData.id;
        _userEmail = userData.email;
        _userName = userData.firstName != null && userData.lastName != null
            ? '${userData.firstName} ${userData.lastName}'.trim()
            : userData.email;
        
        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _userToken);
        await prefs.setString('role', _userRole);
        await prefs.setString('userId', _userId);
        await prefs.setString('userEmail', _userEmail);
        await prefs.setString('userName', _userName);
        
        notifyListeners();
        return true;
      } else {
        // Handle unsuccessful response
        _loginGeneralError = 'Login failed. Please check your credentials.';
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      // Handle network errors
      print('Login API error: ${e.message}');
      if (e.response?.statusCode == 401) {
        _loginEmailError = 'Invalid email or password';
        _loginPasswordError = 'Invalid email or password';
      } else if (e.response?.statusCode == 404) {
        _loginGeneralError = 'Login service not found. Please check your connection.';
      } else if (e.response?.statusCode == 500) {
        _loginGeneralError = 'Server error. Please try again later.';
      } else {
        _loginGeneralError = 'Network error. Please check your connection.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      // Handle general errors
      print('Login general error: $e');
      _loginGeneralError = 'Login failed. Please try again.';
      notifyListeners();
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
    _userName = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    
    // Also clear token from AuthService
    await AuthService.clearToken();

    notifyListeners();
  }

  // Check if user is already logged in
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final userId = prefs.getString('userId');
    final userEmail = prefs.getString('userEmail');
    final userName = prefs.getString('userName');

    if (token != null && role != null && userId != null && userEmail != null) {
      _isLoggedIn = true;
      _userToken = token;
      _userRole = role;
      _userId = userId;
      _userEmail = userEmail;
      _userName = userName ?? '';
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
    _loginGeneralError = null;
    notifyListeners();
  }
}