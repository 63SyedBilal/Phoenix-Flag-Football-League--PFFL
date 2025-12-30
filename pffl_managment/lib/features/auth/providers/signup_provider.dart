import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/features/auth/models/signup_state.dart';
import 'package:pffl_managment/features/auth/utils/signup_validators.dart';
import 'package:pffl_managment/features/auth/repositories/signup_repository.dart';

class SignupProvider extends ChangeNotifier {
  SignupState _state = const SignupState();

  String get firstName => _state.firstName;
  String get lastName => _state.lastName;
  String get email => _state.email;
  PhoneNumber? get phoneNumber => _state.phoneNumber;
  String get password => _state.password;
  String get confirmPassword => _state.confirmPassword;
  bool get agreedToTerms => _state.agreedToTerms;
  PasswordStrength get passwordStrength => _state.passwordStrength;
  bool get isLoading => _state.isLoading;

  String? get firstNameError => _state.firstNameError;
  String? get lastNameError => _state.lastNameError;
  String? get emailError => _state.emailError;
  String? get phoneError => _state.phoneError;
  String? get passwordError => _state.passwordError;
  String? get confirmPasswordError => _state.confirmPasswordError;
  String? get agreementError => _state.agreementError;
  String? get generalError => _state.generalError;

  bool get isFormValid => _state.isFormValid;

  void updateFirstName(String value) {
    _state = _state.copyWith(
      firstName: value,
      clearFirstNameError: true,
      clearGeneralError: true,
    );
    notifyListeners();
  }

  void updateLastName(String value) {
    _state = _state.copyWith(
      lastName: value,
      clearLastNameError: true,
      clearGeneralError: true,
    );
    notifyListeners();
  }

  void updateEmail(String value) {
    _state = _state.copyWith(
      email: value,
      clearEmailError: true,
      clearGeneralError: true,
    );
    notifyListeners();
  }

  void updatePhoneNumber(PhoneNumber? value) {
    _state = _state.copyWith(
      phoneNumber: value,
      clearPhoneError: true,
      clearGeneralError: true,
    );
    notifyListeners();
  }

  void updatePassword(String value) {
    final strength = SignupValidators.calculatePasswordStrength(value);
    _state = _state.copyWith(
      password: value,
      passwordStrength: strength,
      clearPasswordError: true,
      clearGeneralError: true,
    );

    // Re-validate confirm password if it's already filled
    if (_state.confirmPassword.isNotEmpty) {
      _validateConfirmPassword();
    }

    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    _state = _state.copyWith(confirmPassword: value, clearGeneralError: true);
    _validateConfirmPassword();
    notifyListeners();
  }

  void updateAgreedToTerms(bool value) {
    _state = _state.copyWith(
      agreedToTerms: value,
      clearAgreementError: true,
      clearGeneralError: true,
    );
    notifyListeners();
  }

  // Validation methods
  bool validateFirstName() {
    final error = SignupValidators.validateFirstName(_state.firstName);
    _state = _state.copyWith(firstNameError: error);
    notifyListeners();
    return error == null;
  }

  bool validateLastName() {
    final error = SignupValidators.validateLastName(_state.lastName);
    _state = _state.copyWith(lastNameError: error);
    notifyListeners();
    return error == null;
  }

  bool validateEmail() {
    final error = SignupValidators.validateEmail(_state.email);
    _state = _state.copyWith(emailError: error);
    notifyListeners();
    return error == null;
  }

  bool validatePhone() {
    final error = SignupValidators.validatePhone(_state.phoneNumber);
    _state = _state.copyWith(phoneError: error);
    notifyListeners();
    return error == null;
  }

  bool validatePassword() {
    final error = SignupValidators.validatePassword(_state.password);
    _state = _state.copyWith(passwordError: error);
    notifyListeners();
    return error == null;
  }

  bool _validateConfirmPassword() {
    final error = SignupValidators.validateConfirmPassword(
      _state.password,
      _state.confirmPassword,
    );
    _state = _state.copyWith(confirmPasswordError: error);
    return error == null;
  }

  bool validateConfirmPassword() {
    final isValid = _validateConfirmPassword();
    notifyListeners();
    return isValid;
  }

  bool validateAgreement() {
    final error = SignupValidators.validateAgreement(_state.agreedToTerms);
    _state = _state.copyWith(agreementError: error);
    notifyListeners();
    return error == null;
  }

  // Validate all fields
  bool validateAllFields() {
    final validationResults = SignupValidators.validateAllFields(_state);

    _state = _state.copyWith(
      firstNameError: validationResults['firstName'],
      lastNameError: validationResults['lastName'],
      emailError: validationResults['email'],
      phoneError: validationResults['phone'],
      passwordError: validationResults['password'],
      confirmPasswordError: validationResults['confirmPassword'],
      agreementError: validationResults['agreement'],
    );

    notifyListeners();
    return SignupValidators.isAllValid(validationResults);
  }

  // Clear field error
  void clearFieldError(String fieldName) {
    switch (fieldName) {
      case 'firstName':
        _state = _state.copyWith(clearFirstNameError: true);
        break;
      case 'lastName':
        _state = _state.copyWith(clearLastNameError: true);
        break;
      case 'email':
        _state = _state.copyWith(clearEmailError: true);
        break;
      case 'phone':
        _state = _state.copyWith(clearPhoneError: true);
        break;
      case 'password':
        _state = _state.copyWith(clearPasswordError: true);
        break;
      case 'confirmPassword':
        _state = _state.copyWith(clearConfirmPasswordError: true);
        break;
      case 'agreement':
        _state = _state.copyWith(clearAgreementError: true);
        break;
    }
    _state = _state.copyWith(clearGeneralError: true);
    notifyListeners();
  }

  // Clear all errors
  void clearAllErrors() {
    _state = _state.copyWith(
      clearFirstNameError: true,
      clearLastNameError: true,
      clearEmailError: true,
      clearPhoneError: true,
      clearPasswordError: true,
      clearConfirmPasswordError: true,
      clearAgreementError: true,
      clearGeneralError: true,
    );
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
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // Prepare user data for API
      final userData = {
        'firstName': _state.firstName.trim(),
        'lastName': _state.lastName.trim(),
        'email': _state.email.trim().toLowerCase(),
        'phone': _state.phoneNumber!.completeNumber,
        'password': _state.password,
        'role': 'free-agent', // HARDCODED - never user-selectable
      };

      // Call repository signup method
      final result = await SignupRepository.signup(userData);

      if (result.success) {
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return true;
      } else {
        // Handle errors from repository
        _state = _state.copyWith(
          isLoading: false,
          generalError: result.generalError,
          emailError: result.fieldErrors?['email'],
          phoneError: result.fieldErrors?['phone'],
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        generalError: 'An unexpected error occurred. Please try again.',
      );
      notifyListeners();
      return false;
    }
  }

  // Reset form
  void reset() {
    _state = _state.reset();
    notifyListeners();
  }
}

