import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Map<String, String?> _fieldErrors = {};
  final UserPreferenceProvider _userPrefs;
  bool _disposed = false;

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
        _jerseyNumber != null &&
        _jerseyNumber!.isNotEmpty &&
        _emergencyContactName != null &&
        _emergencyContactName!.isNotEmpty &&
        _emergencyPhone != null &&
        _emergencyPhone!.isNotEmpty &&
        (_profileImagePath != null && _profileImagePath != 'null' ||
            _profileImageUrl != null && _profileImageUrl != 'null') &&
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
    } catch (e) {}
  }

  Future<void> _syncWithBackend() async {
    try {
      final dio = await AuthService.getWorkingDio();
      final userId = _userPrefs.userId;

      // Try profile endpoint first, then complete-profile
      final endpoints = [
        AppConfig.profileEndpoint,
        AppConfig.completeProfileEndpoint,
        '${AppConfig.profileEndpoint}/$userId',
      ];

      dynamic profileData;

      for (final endpoint in endpoints) {
        try {
          final response = await dio.get(
            endpoint,
            options: Options(validateStatus: (_) => true),
          );

          if (response.statusCode == 200) {
            final body = response.data;
            profileData = body['data'] ?? body['user'] ?? body;
            if (profileData != null) {
              break;
            }
          }
        } catch (e) {}
      }

      if (profileData != null && profileData is Map) {
        final data = profileData.cast<String, dynamic>();

        // Extract fields with multi-key support
        final firstName = data['firstName'] ?? data['first_name'];
        final lastName = data['lastName'] ?? data['last_name'];
        final phone = data['phone'] ?? data['phoneNumber'];
        final image = data['profileImage'] ?? data['avatar'] ?? data['image'];
        final pos = data['position'];
        final jersey = data['jerseyNumber'] ?? data['jersey_number'];
        final eContact =
            data['emergencyContactName'] ?? data['emergency_contact'];
        final ePhone = data['emergencyPhone'] ?? data['emergency_phone'];

        if (firstName != null)
          await _userPrefs.setFirstName(firstName.toString());
        if (lastName != null) await _userPrefs.setLastName(lastName.toString());
        if (phone != null) await _userPrefs.setUserPhone(phone.toString());
        if (image != null && image.toString() != 'null')
          await _userPrefs.setProfileImage(image.toString());
        if (pos != null) await _userPrefs.setPosition(pos.toString());
        if (jersey != null) await _userPrefs.setJerseyNumber(jersey.toString());
        if (eContact != null)
          await _userPrefs.setEmergencyContactName(eContact.toString());
        if (ePhone != null)
          await _userPrefs.setEmergencyPhone(ePhone.toString());

        final isComplete =
            data['isProfileComplete'] ?? data['complete'] ?? true;
        await _userPrefs.setProfileComplete(isComplete == true);

        // Update local state
        _firstName = _userPrefs.firstName;
        _lastName = _userPrefs.lastName;
        _email = _userPrefs.userEmail;
        _phone = _userPrefs.userPhone;

        if (image != null && image.toString() != 'null') {
          _profileImageUrl = image.toString();
        }

        if (pos != null) {
          _selectedPositions.clear();
          _selectedPositions.addAll(pos.toString().split(', '));
        }

        _jerseyNumber = _userPrefs.jerseyNumber;
        _emergencyContactName = _userPrefs.emergencyContactName;
        _emergencyPhone = _userPrefs.emergencyPhone;
        _profileImagePath = _userPrefs.profileImage;

        notifyListeners();
      }
    } catch (e) {}
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
    // 1. Try PUT /api/complete-profile (Primary endpoint - matches backend route export)
    try {
      final response = await dio.put(
        AppConfig.completeProfileEndpoint,
        data: profileData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201)
        return response;
    } catch (_) {}

    // 2. Try POST /api/profile (Legacy endpoint)
    try {
      final response = await dio.post(
        AppConfig.profileEndpoint,
        data: profileData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201)
        return response;
    } catch (_) {}

    // 3. Try PUT /api/user/:id (User update endpoint - matches backend route export)
    try {
      final response = await dio.put(
        '${AppConfig.userEndpoint}/${_userPrefs.userId}',
        data: profileData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201)
        return response;
      return response; // Return last error response if all fail
    } catch (e) {
      throw Exception('All profile submission attempts failed: $e');
    }
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

  /// Set jersey number
  void setJerseyNumber(String? number) {
    _jerseyNumber = number;
    _clearFieldError('jerseyNumber');
    notifyListeners();
  }

  Timer? _jerseyCheckTimer;

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

    // Jersey number validation (Mandatory)
    if (_jerseyNumber == null ||
        _jerseyNumber!.isEmpty ||
        _jerseyNumber == 'null') {
      _setFieldError('jerseyNumber', 'Jersey number is required');
      isValid = false;
    } else {
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

    // Profile image validation
    if ((_profileImagePath == null || _profileImagePath == 'null') &&
        (_profileImageUrl == null || _profileImageUrl == 'null')) {
      _setFieldError('profileImage', 'Profile image is required');
      isValid = false;
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
      // Upload image (Mandatory)
      String? imageUrl = _profileImageUrl;
      if (_profileImagePath != null &&
          _profileImagePath!.isNotEmpty &&
          !_profileImagePath!.startsWith('http')) {
        try {
          final imageFile = File(_profileImagePath!);
          if (await imageFile.exists()) {
            imageUrl = await AdminService.uploadImage(imageFile);
            if (imageUrl == null || imageUrl.isEmpty) {
              throw Exception('Failed to upload image. Please try again.');
            }
            _profileImageUrl = imageUrl;
          } else {
            throw Exception('Image file not found.');
          }
        } catch (e) {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          notifyListeners();
          return false;
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Profile image is required';
        notifyListeners();
        return false;
      }

      // Prepare profile data
      final positionString = _selectedPositions.join(', ');
      final profileData = <String, dynamic>{
        'userId': _userPrefs.userId,
        if (_firstName != null && _firstName!.trim().isNotEmpty)
          'firstName': _firstName!.trim(),
        if (_lastName != null && _lastName!.trim().isNotEmpty)
          'lastName': _lastName!.trim(),
        if (_phone != null && _phone!.trim().isNotEmpty)
          'phone': _phone!.trim(),
        'position': positionString,
        'emergencyContactName': _emergencyContactName!,
        'emergencyPhone': _emergencyPhone!,
        'profileImage': imageUrl,
        'image': imageUrl,
        'userImage': imageUrl,
      };

      // Add jersey number
      if (_jerseyNumber != null && _jerseyNumber!.isNotEmpty) {
        final jerseyNum = int.tryParse(_jerseyNumber!);
        if (jerseyNum != null) {
          profileData['jerseyNumber'] = jerseyNum;
          profileData['jersey_number'] = jerseyNum;
        }
      }

      try {
        // Submit with method/endpoint fallback. We also don't want Dio to throw for 405/400.
        final dio = await AuthService.getWorkingDio();
        final response = await _submitProfileWithFallback(dio, profileData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Update local cache and return success
          return await _handleProfileSuccess(
            response,
            positionString,
            imageUrl,
          );
        } else {
          final msg =
              _extractMessage(response.data) ??
              'Failed to complete profile (status: ${response.statusCode})';
          _errorMessage = msg;
          _isLoading = false;
          _applyBackendErrorToFields(msg);
          notifyListeners();
          return false;
        }
      } catch (e) {
        _isLoading = false;
        _errorMessage = 'Connection error: Could not save profile to server.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> _handleProfileSuccess(
    dynamic response,
    String positionString,
    String? imageUrl,
  ) async {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // CRITICAL: Get and preserve current role and user ID BEFORE any updates
    final currentRole = prefs.getString('userRole');
    final currentUserId = prefs.getString('userId');

    // Update local cache
    if (_firstName != null) await _userPrefs.setFirstName(_firstName!);
    if (_lastName != null) await _userPrefs.setLastName(_lastName!);
    await _userPrefs.setPosition(positionString);
    await _userPrefs.setEmergencyContactName(_emergencyContactName);
    await _userPrefs.setEmergencyPhone(_emergencyPhone);
    if (_jerseyNumber != null) await _userPrefs.setJerseyNumber(_jerseyNumber);
    // mark image as uploaded to user preference
    await _userPrefs.setProfileImage(imageUrl!);
    await _userPrefs.setProfileComplete(true);

    // CRITICAL: Restore user role and ID after profile updates
    // This prevents unwanted navigation to different dashboards after profile updates
    if (currentRole != null) {
      await prefs.setString('userRole', currentRole);
    }
    if (currentUserId != null) {
      await prefs.setString('userId', currentUserId);
    }

    // Show success sheet
    _showSuccessSheet = true;
    _isLoading = false;
    notifyListeners();

    return true;
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
    _disposed = true;
    _jerseyCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
