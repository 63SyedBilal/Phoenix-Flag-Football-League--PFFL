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
  bool _needsProfileForm = false;
  bool _needsTeamForm = false;

  // Password visibility states
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Login error states (field-specific only)
  String? _loginEmailError;
  String? _loginPasswordError;

  bool get isLoggedIn => _isLoggedIn;
  String get userToken => _userToken;
  String get userRole => _userRole;
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;
  bool get needsProfileForm => _needsProfileForm;
  bool get needsTeamForm => _needsTeamForm;

  // Password visibility getters
  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  // Login error getters
  String? get loginEmailError => _loginEmailError;
  String? get loginPasswordError => _loginPasswordError;

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
        _needsProfileForm = userData.needsProfileForm;
        _needsTeamForm = userData.needsTeamForm;
        
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
        // Handle unsuccessful response - show on password field
        _loginPasswordError = 'Login failed. Please check your credentials.';
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      // Handle network errors with field-specific error messages
      print('Login API error: ${e.message}');
      
      if (e.response?.statusCode == 401) {
        // Authentication error - check error message to determine field
        final errorData = e.response?.data;
        final errorMessage = errorData is Map 
            ? (errorData['error'] ?? errorData['message'] ?? '').toString().toLowerCase()
            : '';
        
        // Check if error mentions email specifically
        if (errorMessage.contains('email') && !errorMessage.contains('password')) {
          _loginEmailError = 'Invalid email address';
        } 
        // Check if error mentions password specifically
        else if (errorMessage.contains('password') && !errorMessage.contains('email')) {
          _loginPasswordError = 'Invalid password';
        }
        // Default to password error for auth failures (most common)
        else {
          _loginPasswordError = 'Invalid email or password';
        }
      } else if (e.response?.statusCode == 404) {
        // Service not found - show as email error (connection issue)
        _loginEmailError = 'Login service not found. Please check your connection.';
      } else if (e.response?.statusCode == 400) {
        // Bad request - parse error to determine field
        final errorData = e.response?.data;
        final errorMessage = errorData is Map 
            ? (errorData['error'] ?? errorData['message'] ?? '').toString().toLowerCase()
            : '';
        
        if (errorMessage.contains('email')) {
          _loginEmailError = errorData is Map 
              ? (errorData['error'] ?? errorData['message'] ?? 'Invalid email address').toString()
              : 'Invalid email address';
        } else if (errorMessage.contains('password')) {
          _loginPasswordError = errorData is Map 
              ? (errorData['error'] ?? errorData['message'] ?? 'Invalid password').toString()
              : 'Invalid password';
        } else {
          _loginPasswordError = 'Invalid credentials. Please check your email and password.';
        }
      } else if (e.response?.statusCode == 500) {
        // Server error - show on password field (less intrusive)
        _loginPasswordError = 'Server error. Please try again later.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        // Timeout - show on email field
        _loginEmailError = 'Connection timeout. Please check your network connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        // Connection error - show on email field
        _loginEmailError = 'Cannot connect to server. Please check your network connection.';
      } else {
        // Other network errors - show on password field
        _loginPasswordError = 'Network error. Please check your connection.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      // Handle general errors - show on password field
      print('Login general error: $e');
      _loginPasswordError = 'Login failed. Please try again.';
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
    _needsProfileForm = false;
    _needsTeamForm = false;

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

  // Clear all login errors
  void clearLoginErrors() {
    _loginEmailError = null;
    _loginPasswordError = null;
    notifyListeners();
  }

  // Clear email error only
  void clearLoginEmailError() {
    _loginEmailError = null;
    notifyListeners();
  }

  // Clear password error only
  void clearLoginPasswordError() {
    _loginPasswordError = null;
    notifyListeners();
  }
}