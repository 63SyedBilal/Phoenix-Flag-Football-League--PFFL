import 'package:intl_phone_field/phone_number.dart';

enum PasswordStrength { weak, medium, strong }

class SignupState {
  final String firstName;
  final String lastName;
  final String email;
  final PhoneNumber? phoneNumber;
  final String password;
  final String confirmPassword;
  final bool agreedToTerms;

  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? agreementError;
  final String? generalError;

  final PasswordStrength passwordStrength;

  final bool isLoading;

  const SignupState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber,
    this.password = '',
    this.confirmPassword = '',
    this.agreedToTerms = false,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.confirmPasswordError,
    this.agreementError,
    this.generalError,
    this.passwordStrength = PasswordStrength.weak,
    this.isLoading = false,
  });

  bool get isFormValid {
    return firstNameError == null &&
        lastNameError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        agreementError == null &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        phoneNumber != null &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        agreedToTerms;
  }

  SignupState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    PhoneNumber? phoneNumber,
    String? password,
    String? confirmPassword,
    bool? agreedToTerms,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? phoneError,
    String? passwordError,
    String? confirmPasswordError,
    String? agreementError,
    String? generalError,
    PasswordStrength? passwordStrength,
    bool? isLoading,
    bool clearPhoneNumber = false,
    bool clearFirstNameError = false,
    bool clearLastNameError = false,
    bool clearEmailError = false,
    bool clearPhoneError = false,
    bool clearPasswordError = false,
    bool clearConfirmPasswordError = false,
    bool clearAgreementError = false,
    bool clearGeneralError = false,
  }) {
    return SignupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      firstNameError: clearFirstNameError
          ? null
          : (firstNameError ?? this.firstNameError),
      lastNameError: clearLastNameError
          ? null
          : (lastNameError ?? this.lastNameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      agreementError: clearAgreementError
          ? null
          : (agreementError ?? this.agreementError),
      generalError: clearGeneralError
          ? null
          : (generalError ?? this.generalError),
      passwordStrength: passwordStrength ?? this.passwordStrength,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  SignupState reset() {
    return const SignupState();
  }
}
