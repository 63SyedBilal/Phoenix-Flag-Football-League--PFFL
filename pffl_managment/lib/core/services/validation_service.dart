/// Service for input validation and sanitization
class ValidationService {
  /// Email validation
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Please enter a valid email address';
    }

    return null; // Valid
  }

  /// Password validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    return null; // Valid
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null; // Valid
  }

  /// Name validation
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmedName = name.trim();

    if (trimmedName.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (trimmedName.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(trimmedName)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null; // Valid
  }

  /// Phone number validation
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return 'Phone number is required';
    }

    final trimmedPhone = phoneNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');

    // Basic phone number validation (10-15 digits)
    final phoneRegex = RegExp(r'^\+?[\d]{10,15}$');
    if (!phoneRegex.hasMatch(trimmedPhone)) {
      return 'Please enter a valid phone number';
    }

    return null; // Valid
  }

  /// League name validation
  static String? validateLeagueName(String? leagueName) {
    if (leagueName == null || leagueName.trim().isEmpty) {
      return 'League name is required';
    }

    final trimmedName = leagueName.trim();

    if (trimmedName.length < 3) {
      return 'League name must be at least 3 characters long';
    }

    if (trimmedName.length > 100) {
      return 'League name must be less than 100 characters';
    }

    return null; // Valid
  }

  /// Team name validation
  static String? validateTeamName(String? teamName) {
    if (teamName == null || teamName.trim().isEmpty) {
      return 'Team name is required';
    }

    final trimmedName = teamName.trim();

    if (trimmedName.length < 2) {
      return 'Team name must be at least 2 characters long';
    }

    if (trimmedName.length > 50) {
      return 'Team name must be less than 50 characters';
    }

    return null; // Valid
  }

  /// Sanitize string input (remove dangerous characters)
  static String sanitizeString(String input) {
    // Remove null bytes and other dangerous characters
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
  }

  /// Validate file size (in bytes)
  static String? validateFileSize(int fileSizeInBytes, {int maxSizeInMB = 10}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024; // Convert MB to bytes

    if (fileSizeInBytes > maxSizeInBytes) {
      return 'File size must be less than ${maxSizeInMB}MB';
    }

    return null; // Valid
  }

  /// Validate image file type
  static String? validateImageFileType(String fileName) {
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = fileName.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return 'Only JPG, PNG, GIF, and WebP images are allowed';
    }

    return null; // Valid
  }

  /// Validate payment amount
  static String? validatePaymentAmount(String? amount) {
    if (amount == null || amount.trim().isEmpty) {
      return 'Payment amount is required';
    }

    try {
      final parsedAmount = double.parse(amount.trim());
      if (parsedAmount <= 0) {
        return 'Payment amount must be greater than 0';
      }

      if (parsedAmount > 10000) {
        return 'Payment amount cannot exceed \$10,000';
      }

      return null; // Valid
    } catch (e) {
      return 'Please enter a valid payment amount';
    }
  }

  /// Validate URL
  static String? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedUrl = url.trim();
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(trimmedUrl)) {
      return 'Please enter a valid URL';
    }

    return null; // Valid
  }

  /// Validate date range
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Start and end dates are required';
    }

    if (startDate.isAfter(endDate)) {
      return 'Start date cannot be after end date';
    }

    if (endDate.difference(startDate).inDays > 365) {
      return 'Date range cannot exceed 1 year';
    }

    return null; // Valid
  }

  /// Comprehensive form validation
  static Map<String, String?> validateForm(Map<String, dynamic> formData, List<String> requiredFields) {
    final errors = <String, String?>{};

    // Check required fields
    for (final field in requiredFields) {
      if (formData[field] == null || formData[field].toString().trim().isEmpty) {
        errors[field] = '${field.replaceAll('_', ' ').toUpperCase()} is required';
      }
    }

    // Validate specific fields if they exist and are not empty
    if (formData['email'] != null && formData['email'].toString().isNotEmpty) {
      errors['email'] = validateEmail(formData['email']);
    }

    if (formData['password'] != null && formData['password'].toString().isNotEmpty) {
      errors['password'] = validatePassword(formData['password']);
    }

    if (formData['firstName'] != null && formData['firstName'].toString().isNotEmpty) {
      errors['firstName'] = validateName(formData['firstName']);
    }

    if (formData['lastName'] != null && formData['lastName'].toString().isNotEmpty) {
      errors['lastName'] = validateName(formData['lastName']);
    }

    if (formData['phoneNumber'] != null && formData['phoneNumber'].toString().isNotEmpty) {
      errors['phoneNumber'] = validatePhoneNumber(formData['phoneNumber']);
    }

    if (formData['leagueName'] != null && formData['leagueName'].toString().isNotEmpty) {
      errors['leagueName'] = validateLeagueName(formData['leagueName']);
    }

    if (formData['teamName'] != null && formData['teamName'].toString().isNotEmpty) {
      errors['teamName'] = validateTeamName(formData['teamName']);
    }

    if (formData['paymentAmount'] != null && formData['paymentAmount'].toString().isNotEmpty) {
      errors['paymentAmount'] = validatePaymentAmount(formData['paymentAmount']);
    }

    // Remove null errors (fields that passed validation)
    errors.removeWhere((key, value) => value == null);

    return errors;
  }
}
