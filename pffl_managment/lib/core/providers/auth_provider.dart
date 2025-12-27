import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';

class AuthProvider extends ChangeNotifier {
  final UserPreferenceProvider _userPreferenceProvider;

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

  // Loading state
  bool _isLoggingIn = false;

  // User data object
  UserData? _userData;

  // Disposal flag to prevent notifications after disposal
  bool _disposed = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoggingIn => _isLoggingIn;
  String get userToken => _userToken;
  String get userRole => _userRole;
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;
  bool get needsProfileForm => _needsProfileForm;
  bool get needsTeamForm => _needsTeamForm;
  UserData? get userData => _userData;

  // Password visibility getters
  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  // Login error getters
  String? get loginEmailError => _loginEmailError;
  String? get loginPasswordError => _loginPasswordError;

  AuthProvider(this._userPreferenceProvider) {
    _syncWithPreferences();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void _syncWithPreferences() {
    _isLoggedIn = _userPreferenceProvider.isLoggedIn;
    _userToken = _userPreferenceProvider.userToken ?? '';
    _userRole = _userPreferenceProvider.userRole ?? '';
    _userId = _userPreferenceProvider.userId ?? '';
    _userEmail = _userPreferenceProvider.userEmail ?? '';
    _userName = _userPreferenceProvider.userName ?? '';
    notifyListeners();
  }

  // Client-side validation helper methods
  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _loginEmailError = 'Please enter your email address';
      return false;
    }
    // Simple email validation
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _loginEmailError =
          'Please enter a valid email address (e.g. user@example.com)';
      return false;
    }
    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      _loginPasswordError = 'Please enter your password';
      return false;
    }
    if (password.length < 6) {
      _loginPasswordError = 'Password must be at least 6 characters long';
      return false;
    }
    return true;
  }

  // Login method with real backend integration using AuthService
  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
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

    // Set loading state
    _isLoggingIn = true;
    notifyListeners();

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

        // Store the complete user data object
        _userData = userData;

        // Save to UserPreferenceProvider
        await _userPreferenceProvider.setUserToken(_userToken);
        await _userPreferenceProvider.setUserRole(_userRole);
        await _userPreferenceProvider.setUserId(_userId);
        await _userPreferenceProvider.setUserEmail(_userEmail);
        await _userPreferenceProvider.setUserName(_userName);
        await _userPreferenceProvider.setLoggedIn(true);

        _isLoggingIn = false;
        notifyListeners();
        return true;
      } else {
        // Handle unsuccessful response
        _loginPasswordError = 'Unable to login. Please check your credentials.';
        _isLoggingIn = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      // Handle network errors with field-specific error messages
      print('Login API error: ${e.message}');

      if (e.response?.statusCode == 401) {
        // Authentication error - check errorType from backend
        final errorData = e.response?.data;
        print('🔴 401 Error Data: $errorData');

        final errorType = errorData is Map
            ? (errorData['errorType'] ?? '').toString()
            : '';
        final errorMessage = errorData is Map
            ? (errorData['error'] ?? '').toString()
            : '';

        print('🔴 errorType: $errorType');
        print('🔴 errorMessage: $errorMessage');

        // Handle specific error types from backend
        if (errorType == 'email_not_found') {
          _loginEmailError = 'Email does not exist.';
          print('✅ Setting email error: Email does not exist.');
        } else if (errorType == 'invalid_password') {
          _loginPasswordError = 'Password is wrong';
          print('✅ Setting password error: Password is wrong');
        } else if (errorType == 'password_not_set') {
          _loginPasswordError =
              'Account setup incomplete. Please reset your password.';
        }
        // Fallback: parse error message for password
        else if (errorMessage.toLowerCase().contains('password')) {
          _loginPasswordError = 'Password is wrong';
          print('✅ Fallback - Setting password error: Password is wrong');
        }
        // Fallback: parse error message for email
        else if (errorMessage.toLowerCase().contains('email')) {
          _loginEmailError = 'Email does not exist.';
          print('✅ Fallback - Setting email error: Email does not exist.');
        }
        // Default - password error
        else {
          _loginPasswordError = 'Password is wrong';
          print('✅ Default - Setting password error: Password is wrong');
        }
      } else if (e.response?.statusCode == 404) {
        // Service not found - show connection error
        _loginPasswordError =
            'Cannot connect to server. Please check:\n1. Backend server is running\n2. Both devices are on same WiFi\n3. Firewall allows port 3000';
      } else if (e.response?.statusCode == 400) {
        // Bad request - parse error to determine field
        final errorData = e.response?.data;
        final errorMessage = errorData is Map
            ? (errorData['error'] ?? errorData['message'] ?? '').toString()
            : '';

        if (errorMessage.toLowerCase().contains('email') &&
            !errorMessage.toLowerCase().contains('password')) {
          _loginEmailError = 'Email does not exist.';
        } else if (errorMessage.toLowerCase().contains('password') &&
            !errorMessage.toLowerCase().contains('email')) {
          _loginPasswordError = 'Password is wrong';
        } else {
          _loginPasswordError = errorMessage.isNotEmpty
              ? errorMessage
              : 'Invalid request. Please check your input.';
        }
      } else if (e.response?.statusCode == 500) {
        // Server error - show error message
        _loginPasswordError = 'Server error. Please try again later.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Timeout - show error message
        _loginPasswordError =
            'Connection timeout. Please check:\n1. Backend server is running at http://192.168.18.32:3000\n2. Both devices are on same WiFi network\n3. Try restarting the backend server';
      } else if (e.type == DioExceptionType.connectionError) {
        // Connection error - show error message
        _loginPasswordError =
            'Cannot connect to server. Please check:\n1. Backend server is running at http://192.168.18.32:3000\n2. Both devices are on same WiFi network\n3. Firewall allows port 3000';
      } else {
        // Other network errors - show generic error
        _loginPasswordError =
            'Network error. Please check your connection and try again.';
      }
      _isLoggingIn = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Handle general errors - show error message
      print('Login general error: $e');
      _loginPasswordError = 'An unexpected error occurred. Please try again.';
      _isLoggingIn = false;
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

    await _userPreferenceProvider.logout();

    // Also clear token from AuthService
    await AuthService.clearToken();

    notifyListeners();
  }

  // Check if user is already logged in (deprecated, using constructor sync)
  Future<void> checkLoginStatus() async {
    _syncWithPreferences();
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

  /// Refresh user data from backend after payment or other updates
  /// IMPORTANT: This method preserves the user's original role to prevent unwanted navigation
  Future<void> refreshUserData() async {
    if (_userData == null) return;

    try {
      debugPrint('🔄 [AUTH PROVIDER] Refreshing user data...');
      debugPrint('🔄 [AUTH PROVIDER] Current role: ${_userData!.role}');

      final dio = await AuthService.getWorkingDio();
      final response = await dio.get('/user/${_userData!.id}');

      if (response.statusCode == 200) {
        final userDataResponse = response.data['data'] ?? response.data;
        if (userDataResponse != null) {
          // CRITICAL: Always preserve the original role to prevent unwanted navigation
          final originalRole = _userData!.role;

          // Update user data while preserving token and role
          final updatedUserData = UserData(
            id:
                userDataResponse['_id'] ??
                userDataResponse['id'] ??
                _userData!.id,
            firstName: userDataResponse['firstName'] ?? _userData!.firstName,
            lastName: userDataResponse['lastName'] ?? _userData!.lastName,
            email: userDataResponse['email'] ?? _userData!.email,
            phone: userDataResponse['phone'] ?? _userData!.phone,
            role: originalRole, // ALWAYS keep the original role
            needsProfileCompletion:
                userDataResponse['needsProfileCompletion'] ??
                _userData!.needsProfileCompletion,
            needsProfileForm:
                userDataResponse['needsProfileForm'] ??
                _userData!.needsProfileForm,
            needsTeamForm:
                userDataResponse['needsTeamForm'] ?? _userData!.needsTeamForm,
          );

          _userData = updatedUserData;

          // Also update individual fields for consistency but preserve role
          _userName =
              updatedUserData.firstName != null &&
                  updatedUserData.lastName != null
              ? '${updatedUserData.firstName} ${updatedUserData.lastName}'
                    .trim()
              : updatedUserData.email;
          _needsProfileForm = updatedUserData.needsProfileForm;
          _needsTeamForm = updatedUserData.needsTeamForm;

          // Ensure role is not changed in preferences
          await _userPreferenceProvider.setUserRole(originalRole);

          debugPrint('✅ [AUTH PROVIDER] User data refreshed successfully');
          debugPrint('✅ [AUTH PROVIDER] Role preserved: $originalRole');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [AUTH PROVIDER] Failed to refresh user data: $e');
      // Don't throw error, just log it
    }
  }

  /// Update user profile data without changing role
  /// This method is specifically for profile updates that should not affect user role
  Future<void> updateProfileData({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? imageUrl,
  }) async {
    if (_userData == null) return;

    try {
      debugPrint('🔄 [AUTH PROVIDER] Updating profile data...');
      debugPrint('🔄 [AUTH PROVIDER] Preserving role: ${_userData!.role}');

      // Update user data while preserving role and other critical fields
      final updatedUserData = UserData(
        id: _userData!.id,
        firstName: firstName ?? _userData!.firstName,
        lastName: lastName ?? _userData!.lastName,
        email: email ?? _userData!.email,
        phone: phone ?? _userData!.phone,
        role: _userData!.role, // NEVER change role during profile updates
        needsProfileCompletion: _userData!.needsProfileCompletion,
        needsProfileForm: _userData!.needsProfileForm,
        needsTeamForm: _userData!.needsTeamForm,
      );

      _userData = updatedUserData;

      // Update individual fields for consistency
      _userName =
          updatedUserData.firstName != null && updatedUserData.lastName != null
          ? '${updatedUserData.firstName} ${updatedUserData.lastName}'.trim()
          : updatedUserData.email;

      if (email != null) {
        _userEmail = email;
        await _userPreferenceProvider.setUserEmail(email);
      }

      // Update preferences but preserve role
      await _userPreferenceProvider.setUserName(_userName);
      await _userPreferenceProvider.setFirstName(updatedUserData.firstName);
      await _userPreferenceProvider.setLastName(updatedUserData.lastName);
      if (phone != null) {
        await _userPreferenceProvider.setUserPhone(phone);
      }
      if (imageUrl != null) {
        await _userPreferenceProvider.setProfileImage(imageUrl);
      }

      debugPrint('✅ [AUTH PROVIDER] Profile data updated successfully');
      debugPrint('✅ [AUTH PROVIDER] Role preserved: ${_userData!.role}');
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ [AUTH PROVIDER] Failed to update profile data: $e');
    }
  }
}
