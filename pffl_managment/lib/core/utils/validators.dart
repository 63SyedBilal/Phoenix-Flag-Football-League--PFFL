class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(
    String? value,
    int minLength, [
    String fieldName = 'Field',
  ]) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(
    String? value,
    int maxLength, [
    String fieldName = 'Field',
  ]) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be no more than $maxLength characters long';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final numericRegex = RegExp(r'^\d+$');
    if (!numericRegex.hasMatch(value)) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Password validation (at least 8 characters, 1 uppercase, 1 lowercase, 1 number)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final uppercaseRegex = RegExp(r'[A-Z]');
    final lowercaseRegex = RegExp(r'[a-z]');
    final numberRegex = RegExp(r'[0-9]');

    if (!uppercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!lowercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!numberRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // League name validation
  static String? validateLeagueName(String? value) {
    return validateMinLength(value, 3, 'League name');
  }

  // Player name validation
  static String? validatePlayerName(String? value) {
    return validateMinLength(value, 2, 'Player name');
  }

  // Team name validation
  static String? validateTeamName(String? value) {
    return validateMinLength(value, 2, 'Team name');
  }
}
