import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Provider for Complete Profile screen state and business logic
/// Profile data is stored directly in the User model (no separate Profile collection)
class CompleteProfileProvider extends ChangeNotifier {
  // Basic user info fields
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;

  // Profile fields
  final List<String> _selectedPositions = [];
  String? _jerseyNumber;
  String? _emergencyContactName;
  String? _emergencyPhone;
  String? _profileImagePath;
  String? _profileImageUrl;

  // UI state
  bool _isLoading = false;
  bool _showPositionDropdown = false;
  bool _showSuccessSheet = false;
  bool _agreedToTerms = false;
  String? _errorMessage;

  // Validation state
  final Map<String, String?> _fieldErrors = {};
  final UserPreferenceProvider _userPrefs;

  CompleteProfileProvider(this._userPrefs);

  // Getters - Basic info
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get phone => _phone;

  // Getters - Profile fields
  List<String> get selectedPositions => List.unmodifiable(_selectedPositions);
  String get positionsDisplayText {
    if (_selectedPositions.isEmpty) {
      return 'Select positions (e.g. Rusher, Blocker)';
    }
    return _selectedPositions.join(', ');
  }

  String? get jerseyNumber => _jerseyNumber;
  String? get emergencyContactName => _emergencyContactName;
  String? get emergencyPhone => _emergencyPhone;
  String? get profileImagePath => _profileImagePath;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;
  bool get showPositionDropdown => _showPositionDropdown;
  bool get showSuccessSheet => _showSuccessSheet;
  bool get agreedToTerms => _agreedToTerms;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);
  String? get phoneError => _fieldErrors['emergencyPhone'];

  /// Check if form is valid
  bool get isFormValid {
    return _selectedPositions.isNotEmpty &&
        _emergencyContactName != null &&
        _emergencyContactName!.isNotEmpty &&
        _emergencyPhone != null &&
        _emergencyPhone!.isNotEmpty &&
        _agreedToTerms &&
        _fieldErrors.isEmpty;
  }

  /// Initialize provider - load user data and sync with backend
  Future<void> initialize() async {
    try {
      // Load from local cache
      _firstName = _userPrefs.firstName;
      _lastName = _userPrefs.lastName;
      _email = _userPrefs.userEmail;
      _phone = _userPrefs.userPhone;

      final savedPositions = _userPrefs.position;
      if (savedPositions != null && savedPositions.isNotEmpty) {
        _selectedPositions.clear();
        _selectedPositions.addAll(savedPositions.split(', '));
      }

      _jerseyNumber = _userPrefs.jerseyNumber;
      _emergencyContactName = _userPrefs.emergencyContactName;
      _emergencyPhone = _userPrefs.emergencyPhone;
      _profileImagePath = _userPrefs.profileImage;

      // Sync with backend
      _syncWithBackend();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing provider: $e');
    }
  }

  Future<void> _syncWithBackend() async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.get(
        AppConfig.profileEndpoint,
        options: Options(validateStatus: (_) => true),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data['user'];
        if (data != null) {
          await _userPrefs.setFirstName(data['firstName']);
          await _userPrefs.setLastName(data['lastName']);
          await _userPrefs.setUserPhone(data['phone']);
          await _userPrefs.setProfileImage(data['profileImage']);
          await _userPrefs.setPosition(data['position']);
          await _userPrefs.setJerseyNumber(data['jerseyNumber']?.toString());
          await _userPrefs.setEmergencyContactName(
            data['emergencyContactName'],
          );
          await _userPrefs.setEmergencyPhone(data['emergencyPhone']);
          await _userPrefs.setProfileComplete(
            data['isProfileComplete'] ?? true,
          );

          _firstName = data['firstName'];
          _lastName = data['lastName'];
          _email = data['email'];
          _phone = data['phone'];

          final pos = data['position'] as String?;
          if (pos != null) {
            _selectedPositions.clear();
            _selectedPositions.addAll(pos.split(', '));
          }

          _jerseyNumber = data['jerseyNumber']?.toString();
          _emergencyContactName = data['emergencyContactName'];
          _emergencyPhone = data['emergencyPhone'];
          _profileImagePath = data['profileImage'];

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Profile backend sync failed: $e');
    }
  }

  String? _extractMessage(dynamic body) {
    if (body is Map) {
      return body['message']?.toString() ?? body['error']?.toString();
    }
    if (body is String) return body;
    return null;
  }

  void _applyBackendErrorToFields(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('phone') && !lower.contains('emergency')) {
      _setFieldError('phone', message);
      return;
    }
    if (lower.contains('emergency') && lower.contains('phone')) {
      _setFieldError('emergencyPhone', message);
      return;
    }
    if (lower.contains('position')) {
      _setFieldError('position', message);
      return;
    }
    if (lower.contains('jersey')) {
      _setFieldError('jerseyNumber', message);
      return;
    }
    if (lower.contains('terms')) {
      _setFieldError('terms', message);
      return;
    }
  }

  Future<Response<dynamic>> _submitProfileWithFallback(
    Dio dio,
    Map<String, dynamic> profileData,
  ) async {
    final methods = <String>['PUT', 'POST', 'PATCH'];
    final paths = <String>[AppConfig.profileEndpoint, AppConfig.completeProfileEndpoint];

    Response<dynamic>? lastResponse;
    for (final path in paths) {
      for (final method in methods) {
        lastResponse = await dio.request(
          path,
          data: profileData,
          options: Options(method: method, validateStatus: (_) => true),
        );

        final status = lastResponse.statusCode ?? 0;

        if (status == 200 || status == 201) {
          return lastResponse;
        }

        // If method is not allowed, try next method.
        if (status == 405) {
          continue;
        }

        // For 400s, still allow trying next endpoint because some envs validate differently.
        if (status == 400) {
          continue;
        }
      }
    }

    // If everything failed, return the last attempt.
    return lastResponse!;
  }

  // Setters for basic info
  void setFirstName(String? value) {
    _firstName = value;
    _clearFieldError('firstName');
    notifyListeners();
  }

  void setLastName(String? value) {
    _lastName = value;
    _clearFieldError('lastName');
    notifyListeners();
  }

  void setEmail(String? value) {
    _email = value;
    _clearFieldError('email');
    notifyListeners();
  }

  void setPhone(String? value) {
    _phone = value;
    _clearFieldError('phone');
    notifyListeners();
  }

  /// Toggle position selection (add if not selected, remove if selected)
  void togglePosition(String position) {
    if (_selectedPositions.contains(position)) {
      _selectedPositions.remove(position);
    } else {
      _selectedPositions.add(position);
    }
    _clearFieldError('position');
    notifyListeners();
  }

  /// Check if position is selected
  bool isPositionSelected(String position) {
    return _selectedPositions.contains(position);
  }

  /// Set jersey number and validate
  void setJerseyNumber(String? number) {
    _jerseyNumber = number;
    _clearFieldError('jerseyNumber');

    // Validate if provided
    if (number != null && number.isNotEmpty) {
      final jerseyNum = int.tryParse(number);
      if (jerseyNum == null || jerseyNum < 1 || jerseyNum > 99) {
        _setFieldError(
          'jerseyNumber',
          'Jersey number must be between 1 and 99',
        );
      }
    }

    notifyListeners();
  }

  /// Set emergency contact name and validate
  void setEmergencyContactName(String? name) {
    _emergencyContactName = name;
    _clearFieldError('emergencyContactName');

    // Validate if provided
    if (name != null && name.isNotEmpty && name.length < 2) {
      _setFieldError(
        'emergencyContactName',
        'Name must be at least 2 characters',
      );
    }

    notifyListeners();
  }

  /// Set emergency phone
  void setEmergencyPhone(String? phone) {
    _emergencyPhone = phone;
    _clearFieldError('emergencyPhone');

    // Basic validation
    if (phone != null && phone.isNotEmpty) {
      final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
      if (cleaned.length < 10) {
        _setFieldError('emergencyPhone', 'Please enter a valid phone number');
      }
    }

    notifyListeners();
  }

  /// Set profile image path
  void setProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  /// Toggle position dropdown
  void togglePositionDropdown() {
    _showPositionDropdown = !_showPositionDropdown;
    notifyListeners();
  }

  /// Toggle terms agreement
  void toggleTermsAgreement(bool? value) {
    _agreedToTerms = value ?? false;
    notifyListeners();
  }

  /// Validate entire form
  bool _validateForm() {
    _fieldErrors.clear();
    bool isValid = true;

    // Position validation - at least one position must be selected
    if (_selectedPositions.isEmpty) {
      _setFieldError('position', 'Please select at least one position');
      isValid = false;
    }

    // Jersey number validation (optional but must be valid if provided)
    if (_jerseyNumber != null && _jerseyNumber!.isNotEmpty) {
      final jerseyNum = int.tryParse(_jerseyNumber!);
      if (jerseyNum == null || jerseyNum < 1 || jerseyNum > 99) {
        _setFieldError(
          'jerseyNumber',
          'Jersey number must be between 1 and 99',
        );
        isValid = false;
      }
    }

    // Emergency contact name validation
    if (_emergencyContactName == null || _emergencyContactName!.isEmpty) {
      _setFieldError(
        'emergencyContactName',
        'Emergency contact name is required',
      );
      isValid = false;
    } else if (_emergencyContactName!.length < 2) {
      _setFieldError(
        'emergencyContactName',
        'Name must be at least 2 characters',
      );
      isValid = false;
    }

    // Emergency phone validation
    if (_emergencyPhone == null || _emergencyPhone!.isEmpty) {
      _setFieldError('emergencyPhone', 'Emergency phone number is required');
      isValid = false;
    } else {
      final cleaned = _emergencyPhone!.replaceAll(RegExp(r'\s+'), '');
      if (cleaned.length < 10) {
        _setFieldError('emergencyPhone', 'Please enter a valid phone number');
        isValid = false;
      }
    }

    // Terms agreement validation
    if (!_agreedToTerms) {
      _setFieldError('terms', 'You must agree to Terms & Privacy');
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  /// Submit profile to backend - saves directly to User model
  Future<bool> submitProfile() async {
    // Validate form
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
            debugPrint('✅ Image uploaded: $imageUrl');
          }
        } catch (e) {
          debugPrint('⚠️ Image upload failed: $e');
          // Continue without image - it's optional
        }
      }

      // Prepare profile data - all stored in User model
      final positionString = _selectedPositions.join(', ');
      final profileData = <String, dynamic>{
        if (_phone != null && _phone!.trim().isNotEmpty) 'phone': _phone!.trim(),
        'position': positionString,
        'emergencyContactName': _emergencyContactName!,
        'emergencyPhone': _emergencyPhone!,
      };

      // Add optional fields
      if (_jerseyNumber != null && _jerseyNumber!.isNotEmpty) {
        final jerseyNum = int.tryParse(_jerseyNumber!);
        if (jerseyNum != null) {
          profileData['jerseyNumber'] = jerseyNum;
        }
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        profileData['profileImage'] = imageUrl;
      }

      // Submit with method/endpoint fallback. We also don't want Dio to throw for 405/400.
      final dio = await AuthService.getWorkingDio();
      final response = await _submitProfileWithFallback(dio, profileData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local cache
        await _userPrefs.setPosition(positionString);
        await _userPrefs.setEmergencyContactName(_emergencyContactName);
        await _userPrefs.setEmergencyPhone(_emergencyPhone);
        if (_phone != null && _phone!.trim().isNotEmpty) {
          await _userPrefs.setUserPhone(_phone);
        }
        if (_jerseyNumber != null)
          await _userPrefs.setJerseyNumber(_jerseyNumber);
        if (imageUrl != null) await _userPrefs.setProfileImage(imageUrl);
        await _userPrefs.setProfileComplete(true);

        // Show success sheet
        _showSuccessSheet = true;
        _isLoading = false;
        notifyListeners();

        return true;
      } else {
        final msg = _extractMessage(response.data) ??
            'Failed to complete profile (status: ${response.statusCode})';
        _applyBackendErrorToFields(msg);
        throw Exception(msg);
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Error submitting profile: $e');
      notifyListeners();
      return false;
    }
  }

  /// Hide success sheet and prepare for navigation
  void hideSuccessSheet() {
    _showSuccessSheet = false;
    notifyListeners();
  }

  Future<void> skipForNow() async {
    // Mark as incomplete but allows proceeding to dashboard
    await _userPrefs.setProfileComplete(false);
  }

  /// Static method to check if profile is completed
  static Future<bool> checkProfileCompletion(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check SharedPreferences first
      final isCompleted = prefs.getBool('profile_completed_$userId');
      if (isCompleted == true) {
        return true;
      }

      // Could also check via API if needed
      return false;
    } catch (e) {
      debugPrint('❌ Error checking profile completion: $e');
      return false;
    }
  }

  /// Set field error
  void _setFieldError(String field, String error) {
    _fieldErrors[field] = error;
  }

  /// Clear field error
  void _clearFieldError(String field) {
    _fieldErrors.remove(field);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
