import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Enhanced Provider for Complete Profile screen with full functionality
/// Handles image upload, multiple position selection, validation, and backend integration
class EnhancedCompleteProfileProvider extends ChangeNotifier {
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
  bool _isUploadingImage = false;
  bool _showPositionDropdown = false;
  bool _showSuccessSheet = false;
  bool _agreedToTerms = false;
  String? _errorMessage;

  // Validation state
  final Map<String, String?> _fieldErrors = {};
  final UserPreferenceProvider _userPrefs;

  // Available positions
  final List<String> _availablePositions = [
    'Quarterback',
    'Receiver',
    'Running Back',
    'Linebacker',
    'Cornerback',
    'Safety',
  ];

  EnhancedCompleteProfileProvider(this._userPrefs);

  // Getters - Basic info
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get phone => _phone;

  // Getters - Profile fields
  List<String> get selectedPositions => List.unmodifiable(_selectedPositions);
  List<String> get availablePositions => List.unmodifiable(_availablePositions);

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
  bool get isUploadingImage => _isUploadingImage;
  bool get showPositionDropdown => _showPositionDropdown;
  bool get showSuccessSheet => _showSuccessSheet;
  bool get agreedToTerms => _agreedToTerms;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);
  String? get phoneError => _fieldErrors['emergencyPhone'];

  /// Check if form is valid
  bool get isFormValid {
    return _profileImagePath != null &&
        _selectedPositions.isNotEmpty &&
        _phone != null &&
        _phone!.isNotEmpty &&
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
      await _syncWithBackend();

      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> _syncWithBackend() async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.get(AppConfig.profileEndpoint);
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
    }
  }

  /// Pick image from file picker (camera/gallery)
  Future<void> pickImage() async {
    try {
      _isUploadingImage = true;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Validate file size (max 10MB)
          final fileSize = await File(file.path!).length();
          if (fileSize > 10 * 1024 * 1024) {
            _setFieldError('profileImage', 'Image size must be less than 10MB');
            return;
          }

          // Validate file extension
          final extension = file.extension?.toLowerCase();
          if (extension == null ||
              ![
                'jpg',
                'jpeg',
                'png',
                'gif',
                'bmp',
                'webp',
              ].contains(extension)) {
            _setFieldError(
              'profileImage',
              'Please select a valid image file (JPG, PNG, GIF, BMP, WebP)',
            );
            return;
          }

          _profileImagePath = file.path!;
          _clearFieldError('profileImage');
        }
      }
    } catch (e) {
      _setFieldError('profileImage', 'Error selecting image: ${e.toString()}');
    } finally {
      _isUploadingImage = false;
      notifyListeners();
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

    // Validate phone number
    if (value != null && value.isNotEmpty) {
      final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleaned.length < 10) {
        _setFieldError('phone', 'Please enter a valid phone number');
      }
    }

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
      final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleaned.length < 10) {
        _setFieldError('emergencyPhone', 'Please enter a valid phone number');
      }
    }

    notifyListeners();
  }

  /// Set profile image path
  void setProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    _clearFieldError('profileImage');
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
    _clearFieldError('terms');
    notifyListeners();
  }

  /// Validate entire form
  bool _validateForm() {
    _fieldErrors.clear();
    bool isValid = true;

    // Profile image validation - required
    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      _setFieldError('profileImage', 'Profile image is required');
      isValid = false;
    }

    // Position validation - at least one position must be selected
    if (_selectedPositions.isEmpty) {
      _setFieldError('position', 'Please select at least one position');
      isValid = false;
    }

    // Phone number validation - required
    if (_phone == null || _phone!.isEmpty) {
      _setFieldError('phone', 'Phone number is required');
      isValid = false;
    } else {
      final cleaned = _phone!.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleaned.length < 10) {
        _setFieldError('phone', 'Please enter a valid phone number');
        isValid = false;
      }
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

    // Emergency contact name validation - required
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

    // Emergency phone validation - required
    if (_emergencyPhone == null || _emergencyPhone!.isEmpty) {
      _setFieldError('emergencyPhone', 'Emergency phone number is required');
      isValid = false;
    } else {
      final cleaned = _emergencyPhone!.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleaned.length < 10) {
        _setFieldError('emergencyPhone', 'Please enter a valid phone number');
        isValid = false;
      }
    }

    // Terms agreement validation - required
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
          }
        } catch (e) {
          _setFieldError(
            'profileImage',
            'Failed to upload image. Please try again.',
          );
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Prepare profile data - all stored in User model
      final positionString = _selectedPositions.join(', ');
      final profileData = <String, dynamic>{
        'phone': _phone!,
        'position': positionString,
        'emergencyContactName': _emergencyContactName!,
        'emergencyPhone': _emergencyPhone!,
        'isProfileComplete': true,
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

      // Submit to complete-profile endpoint (updates User model directly)
      final dio = await AuthService.getWorkingDio();
      final response = await dio.put(
        AppConfig.profileEndpoint,
        data: profileData,
      );

      if (response.statusCode == 200) {
        // Update local cache
        await _userPrefs.setUserPhone(_phone);
        await _userPrefs.setPosition(positionString);
        await _userPrefs.setEmergencyContactName(_emergencyContactName);
        await _userPrefs.setEmergencyPhone(_emergencyPhone);
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
        throw Exception(response.data['error'] ?? 'Failed to complete profile');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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

