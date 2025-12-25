import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/core/utils/validators.dart';
import 'package:pffl_managment/features/auth/models/signup_state.dart';

/// Validation utilities for signup form
class SignupValidators {
  /// Validate first name
  static String? validateFirstName(String value) {
    return Validators.validateMinLength(value, 2, 'First Name');
  }

  /// Validate last name
  static String? validateLastName(String value) {
    return Validators.validateMinLength(value, 2, 'Last Name');
  }

  /// Validate email
  static String? validateEmail(String value) {
    return Validators.validateEmail(value);
  }

  /// Validate phone number
  static String? validatePhone(PhoneNumber? phoneNumber) {
    if (phoneNumber == null || phoneNumber.number.isEmpty) {
      return 'Phone number is required';
    }
    if (!phoneNumber.isValidNumber()) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String value) {
    return Validators.validatePassword(value);
  }

  /// Validate confirm password
  static String? validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate agreement to terms
  static String? validateAgreement(bool agreed) {
    if (!agreed) {
      return 'You must agree to Terms & Privacy';
    }
    return null;
  }

  /// Validate all fields in the signup state
  static Map<String, String?> validateAllFields(SignupState state) {
    return {
      'firstName': validateFirstName(state.firstName),
      'lastName': validateLastName(state.lastName),
      'email': validateEmail(state.email),
      'phone': validatePhone(state.phoneNumber),
      'password': validatePassword(state.password),
      'confirmPassword': validateConfirmPassword(
        state.password,
        state.confirmPassword,
      ),
      'agreement': validateAgreement(state.agreedToTerms),
    };
  }

  /// Check if all validations pass
  static bool isAllValid(Map<String, String?> validationResults) {
    return validationResults.values.every((error) => error == null);
  }

  /// Calculate password strength
  static PasswordStrength calculatePasswordStrength(String password) {
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
}
