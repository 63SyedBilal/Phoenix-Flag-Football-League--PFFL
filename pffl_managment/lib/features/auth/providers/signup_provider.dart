import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/utils/validators.dart';

/// Password strength levels
enum PasswordStrength { weak, medium, strong }

/// Provider for managing signup form state, validation, and API calls
class SignupProvider extends ChangeNotifier {
  // Form field values
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  PhoneNumber? _phoneNumber;
  String _password = '';
  String _confirmPassword = '';
  bool _agreedToTerms = false;

  // Validation errors
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _agreementError;
  String? _generalError;

  // Password strength
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  // Loading state
  bool _isLoading = false;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  PhoneNumber? get phoneNumber => _phoneNumber;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get agreedToTerms => _agreedToTerms;
  PasswordStrength get passwordStrength => _passwordStrength;
  bool get isLoading => _isLoading;

  // Error getters
  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;
  String? get emailError => _emailError;
  String? get phoneError => _phoneError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get agreementError => _agreementError;
  String? get generalError => _generalError;

  // Check if form is valid
  bool get isFormValid {
    return _firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _agreementError == null &&
        _firstName.isNotEmpty &&
        _lastName.isNotEmpty &&
        _email.isNotEmpty &&
        _phoneNumber != null &&
        _password.isNotEmpty &&
        _confirmPassword.isNotEmpty &&
        _agreedToTerms;
  }

  // Update methods
  void updateFirstName(String value) {
    _firstName = value;
    clearFieldError('firstName');
    notifyListeners();
  }

  void updateLastName(String value) {
    _lastName = value;
    clearFieldError('lastName');
    notifyListeners();
  }

  void updateEmail(String value) {
    _email = value;
    clearFieldError('email');
    notifyListeners();
  }

  void updatePhoneNumber(PhoneNumber? value) {
    _phoneNumber = value;
    clearFieldError('phone');
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    _passwordStrength = _calculatePasswordStrength(value);
    clearFieldError('password');
    // Re-validate confirm password if it's already filled
    if (_confirmPassword.isNotEmpty) {
      _validateConfirmPassword();
    }
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    _confirmPassword = value;
    _validateConfirmPassword();
    notifyListeners();
  }

  void updateAgreedToTerms(bool value) {
    _agreedToTerms = value;
    clearFieldError('agreement');
    notifyListeners();
  }

  // Validation methods
  bool validateFirstName() {
    _firstNameError = Validators.validateMinLength(_firstName, 2, 'First Name');
    notifyListeners();
    return _firstNameError == null;
  }

  bool validateLastName() {
    _lastNameError = Validators.validateMinLength(_lastName, 2, 'Last Name');
    notifyListeners();
    return _lastNameError == null;
  }

  bool validateEmail() {
    _emailError = Validators.validateEmail(_email);
    notifyListeners();
    return _emailError == null;
  }

  bool validatePhone() {
    if (_phoneNumber == null || _phoneNumber!.number.isEmpty) {
      _phoneError = 'Phone number is required';
      notifyListeners();
      return false;
    }
    if (!_phoneNumber!.isValidNumber()) {
      _phoneError = 'Please enter a valid phone number';
      notifyListeners();
      return false;
    }
    _phoneError = null;
    notifyListeners();
    return true;
  }

  bool validatePassword() {
    _passwordError = Validators.validatePassword(_password);
    notifyListeners();
    return _passwordError == null;
  }

  bool _validateConfirmPassword() {
    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      return false;
    }
    if (_confirmPassword != _password) {
      _confirmPasswordError = 'Passwords do not match';
      return false;
    }
    _confirmPasswordError = null;
    return true;
  }

  bool validateConfirmPassword() {
    final isValid = _validateConfirmPassword();
    notifyListeners();
    return isValid;
  }

  bool validateAgreement() {
    if (!_agreedToTerms) {
      _agreementError = 'You must agree to Terms & Privacy';
      notifyListeners();
      return false;
    }
    _agreementError = null;
    notifyListeners();
    return true;
  }

  // Validate all fields
  bool validateAllFields() {
    final isValid =
        validateFirstName() &&
        validateLastName() &&
        validateEmail() &&
        validatePhone() &&
        validatePassword() &&
        validateConfirmPassword() &&
        validateAgreement();
    return isValid;
  }

  // Calculate password strength
  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.weak;
    }

    if (password.length < 8) {
      return PasswordStrength.weak;
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    // Check if basic requirements are met
    if (!hasUppercase || !hasLowercase || !hasNumber) {
      return PasswordStrength.weak;
    }

    // Medium: basic requirements met
    if (password.length >= 8 && hasUppercase && hasLowercase && hasNumber) {
      // Strong: has special char OR length >= 12
      if (hasSpecialChar || password.length >= 12) {
        return PasswordStrength.strong;
      }
      return PasswordStrength.medium;
    }

    return PasswordStrength.weak;
  }

  // Clear field error
  void clearFieldError(String fieldName) {
    switch (fieldName) {
      case 'firstName':
        _firstNameError = null;
        break;
      case 'lastName':
        _lastNameError = null;
        break;
      case 'email':
        _emailError = null;
        break;
      case 'phone':
        _phoneError = null;
        break;
      case 'password':
        _passwordError = null;
        break;
      case 'confirmPassword':
        _confirmPasswordError = null;
        break;
      case 'agreement':
        _agreementError = null;
        break;
    }
    _generalError = null;
    notifyListeners();
  }

  // Clear all errors
  void clearAllErrors() {
    _firstNameError = null;
    _lastNameError = null;
    _emailError = null;
    _phoneError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    _agreementError = null;
    _generalError = null;
    notifyListeners();
  }

  // Signup method
  Future<bool> signup(BuildContext context) async {
    // Clear previous errors
    clearAllErrors();

    // Validate all fields
    if (!validateAllFields()) {
      return false;
    }

    // Set loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Prepare user data for API
      final userData = {
        'firstName': _firstName.trim(),
        'lastName': _lastName.trim(),
        'email': _email.trim().toLowerCase(),
        'phone': _phoneNumber!.completeNumber,
        'password': _password,
        'role': 'free-agent', // HARDCODED - never user-selectable
      };

      print('📝 Attempting signup with data: ${userData['email']}');
      print('📝 Role: ${userData['role']} (hardcoded)');

      // Call AuthService register method
      final authResponse = await AuthService.register(userData);

      if (authResponse != null) {
        print('✅ Signup successful');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // This should not happen as exceptions are re-thrown, but handle it anyway
        _generalError = 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      print('❌ Signup Dio error: ${e.message}');
      print('❌ Error type: ${e.type}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');

      _isLoading = false;

      // Handle specific error cases
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        if (statusCode == 409) {
          // Conflict - email or phone already exists
          final errorMessage =
              errorData['error'] ?? 'Email or phone already exists';
          if (errorMessage.toLowerCase().contains('email')) {
            _emailError = 'This email is already registered';
          } else if (errorMessage.toLowerCase().contains('phone')) {
            _phoneError = 'This phone number is already registered';
          } else {
            _generalError = errorMessage;
          }
        } else if (statusCode == 400) {
          // Bad request - validation error
          final errorMessage =
              errorData['error'] ?? 'Invalid data. Please check your input.';
          _generalError = errorMessage;
        } else if (statusCode == 500) {
          // Server error
          _generalError = 'Server error. Please try again later.';
        } else {
          _generalError =
              errorData['error'] ?? 'Registration failed. Please try again.';
        }
      } else {
        // Network or connection error
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          _generalError =
              'Connection timeout. Please check:\n1. Backend server is running\n2. Both devices are on same WiFi\n3. Firewall allows port 3000';
        } else if (e.type == DioExceptionType.connectionError) {
          _generalError =
              'Cannot connect to server. Please check:\n1. Backend server is running at http://192.168.18.26:3000\n2. Both devices are on same WiFi network\n3. Try restarting the backend server';
        } else {
          _generalError =
              'Network error. Please check your connection and try again.';
        }
      }

      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Signup general error: $e');
      _isLoading = false;
      _generalError = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Reset form
  void reset() {
    _firstName = '';
    _lastName = '';
    _email = '';
    _phoneNumber = null;
    _password = '';
    _confirmPassword = '';
    _agreedToTerms = false;
    clearAllErrors();
    _passwordStrength = PasswordStrength.weak;
    _isLoading = false;
    notifyListeners();
  }
}
