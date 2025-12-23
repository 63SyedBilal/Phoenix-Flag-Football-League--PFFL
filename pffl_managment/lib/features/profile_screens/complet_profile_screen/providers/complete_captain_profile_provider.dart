import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'dart:io';

/// Provider for Complete Captain Profile screen state and business logic
class CompleteCaptainProfileProvider extends ChangeNotifier {
  // Basic user info fields
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;

  // Profile fields
  String? _profileImagePath;
  String? _profileImageUrl;
  bool _agreedToTerms = false;

  // UI state
  bool _isLoading = false;
  bool _showSuccessSheet = false;
  String? _errorMessage;

  // Validation state
  final Map<String, String?> _fieldErrors = {};

  // Getters - Basic info
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get phone => _phone;

  // Getters - Profile fields
  String? get profileImagePath => _profileImagePath;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;
  bool get showSuccessSheet => _showSuccessSheet;
  bool get agreedToTerms => _agreedToTerms;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);

  /// Check if form is valid
  bool get isFormValid {
    return _firstName != null &&
        _firstName!.isNotEmpty &&
        _lastName != null &&
        _lastName!.isNotEmpty &&
        _phone != null &&
        _phone!.isNotEmpty &&
        _agreedToTerms &&
        _fieldErrors.isEmpty;
  }

  /// Initialize provider - load user data
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _firstName = prefs.getString('firstName');
      _lastName = prefs.getString('lastName');
      _email = prefs.getString('userEmail');
      _phone = prefs.getString('userPhone');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing provider: $e');
    }
  }

  // Setters
  void setFirstName(String value) {
    _firstName = value;
    _fieldErrors.remove('firstName');
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    _fieldErrors.remove('lastName');
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    _fieldErrors.remove('phone');
    notifyListeners();
  }

  void setProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  void toggleTermsAgreement(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  /// Validate form
  bool _validateForm() {
    _fieldErrors.clear();
    bool isValid = true;

    if (_firstName == null || _firstName!.isEmpty) {
      _fieldErrors['firstName'] = 'First name is required';
      isValid = false;
    }
    if (_lastName == null || _lastName!.isEmpty) {
      _fieldErrors['lastName'] = 'Last name is required';
      isValid = false;
    }
    if (_phone == null || _phone!.isEmpty) {
      _fieldErrors['phone'] = 'Phone number is required';
      isValid = false;
    }
    if (!_agreedToTerms) {
      _fieldErrors['terms'] = 'You must agree to Terms & Privacy';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  /// Submit profile to backend
  Future<bool> submitProfile() async {
    if (!_validateForm()) {
      _errorMessage = 'Please fix the errors below';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Upload image if provided
      String? imageUrl;
      if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
        try {
          final imageFile = File(_profileImagePath!);
          if (await imageFile.exists()) {
            imageUrl = await AdminService.uploadImage(imageFile);
            _profileImageUrl = imageUrl;
          }
        } catch (e) {
          debugPrint('⚠️ Image upload failed: $e');
        }
      }

      // Prepare profile data
      final profileData = <String, dynamic>{
        'firstName': _firstName,
        'lastName': _lastName,
        'phone': _phone,
        'isCaptainProfileComplete': true,
      };

      if (imageUrl != null) {
        profileData['profileImage'] = imageUrl;
      }

      final dio = await AuthService.getWorkingDio();
      final response = await dio.put(
        AppConfig.completeProfileEndpoint,
        data: profileData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        if (userId != null) {
          await prefs.setBool('profile_completed_$userId', true);
        }

        _showSuccessSheet = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to complete profile',
        );
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void hideSuccessSheet() {
    _showSuccessSheet = false;
    notifyListeners();
  }
}
