import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// Provider for Complete Captain Profile screen state and business logic
class CompleteCaptainProfileProvider extends ChangeNotifier {
  // TextEditingControllers for inputs
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final UserPreferenceProvider _userPrefs;

  CompleteCaptainProfileProvider(this._userPrefs);

  // Profile fields
  String? _profileImagePath;
  String? _profileImageUrl;
  bool _agreedToTerms = false;
  String? _selectedPosition;

  // UI state
  bool _isLoading = false;
  bool _showSuccessSheet = false;
  String? _errorMessage;

  // Validation state
  final Map<String, String?> _fieldErrors = {};

  // Getters - Controllers
  String get firstName => firstNameController.text;
  String get lastName => lastNameController.text;
  String get phone => phoneController.text;
  String get position => _selectedPosition ?? '';
  String get emergencyContactName => emergencyContactNameController.text;
  String get emergencyPhone => emergencyPhoneController.text;

  // Position options
  static const List<String> positionOptions = [
    'Center',
    'Blocker',
    'Receiver',
    'Slot',
    'QB',
    'Star QB',
    'Rusher',
    'LB',
    'Corner',
    'Safety',
  ];

  String? get selectedPosition => _selectedPosition;

  // Getters - Profile fields
  String? get profileImagePath => _profileImagePath;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;
  bool get showSuccessSheet => _showSuccessSheet;
  bool get agreedToTerms => _agreedToTerms;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emergencyContactNameController.dispose();
    emergencyPhoneController.dispose();
    super.dispose();
  }

  /// Check if form is valid
  bool get isFormValid {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        phone.isNotEmpty &&
        position.isNotEmpty &&
        emergencyContactName.isNotEmpty &&
        emergencyPhone.isNotEmpty &&
        _agreedToTerms &&
        _fieldErrors.isEmpty;
  }

  /// Initialize provider - load user data
  Future<void> initialize() async {
    try {
      // Load from local cache
      firstNameController.text = _userPrefs.firstName ?? '';
      lastNameController.text = _userPrefs.lastName ?? '';
      phoneController.text = _userPrefs.userPhone ?? '';
      _selectedPosition = _userPrefs.position;
      emergencyContactNameController.text =
          _userPrefs.emergencyContactName ?? '';
      emergencyPhoneController.text = _userPrefs.emergencyPhone ?? '';
      _profileImagePath = _userPrefs.profileImage;

      // Asynchronously fetch from backend to sync
      _syncWithBackend();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing provider: $e');
    }
  }

  Future<void> _syncWithBackend() async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.get(AppConfig.profileEndpoint);
      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic>? data;

        // Handle different response formats
        if (responseData is Map) {
          if (responseData.containsKey('data')) {
            data = responseData['data'] as Map<String, dynamic>?;
          } else if (responseData.containsKey('user')) {
            data = responseData['user'] as Map<String, dynamic>?;
          } else {
            data = responseData as Map<String, dynamic>?;
          }
        }

        if (data != null) {
          await _userPrefs.setFirstName(data['firstName']);
          await _userPrefs.setLastName(data['lastName']);
          await _userPrefs.setUserPhone(data['phone']);
          await _userPrefs.setPosition(data['position']);
          await _userPrefs.setEmergencyContactName(
            data['emergencyContactName'],
          );
          await _userPrefs.setEmergencyPhone(data['emergencyPhone']);
          await _userPrefs.setProfileImage(data['profileImage']);
          await _userPrefs.setCaptainProfileComplete(
            data['isCaptainProfileComplete'] ?? true,
          );

          // Update controllers if they are still empty or if data changed significantly
          if (firstNameController.text.isEmpty)
            firstNameController.text = data['firstName'] ?? '';
          if (lastNameController.text.isEmpty)
            lastNameController.text = data['lastName'] ?? '';
          if (phoneController.text.isEmpty)
            phoneController.text = data['phone'] ?? '';
          if (_selectedPosition == null) _selectedPosition = data['position'];
          if (emergencyContactNameController.text.isEmpty)
            emergencyContactNameController.text =
                data['emergencyContactName'] ?? '';
          if (emergencyPhoneController.text.isEmpty)
            emergencyPhoneController.text = data['emergencyPhone'] ?? '';
          _profileImagePath = data['profileImage'];

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Backend sync failed: $e');
      // Don't throw error - this is just a background sync
      // The app should work with cached data if sync fails
    }
  }

  // Setters
  void setPhone(String value) {
    phoneController.text = value;
    _fieldErrors.remove('phone');
    notifyListeners();
  }

  void setEmergencyPhone(String value) {
    emergencyPhoneController.text = value;
    _fieldErrors.remove('emergencyPhone');
    notifyListeners();
  }

  void setPosition(String? value) {
    _selectedPosition = value;
    _fieldErrors.remove('position');
    notifyListeners();
  }

  void setProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  void toggleTermsAgreement(bool value) {
    _agreedToTerms = value;
    _fieldErrors.remove('terms');
    notifyListeners();
  }

  /// Pick image from gallery or camera
  Future<void> pickImage() async {
    try {
      // TODO: Implement image picker functionality
      // For now, we'll simulate image selection
      // In a real implementation, you would use image_picker package

      // Example implementation:
      // final ImagePicker picker = ImagePicker();
      // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      // if (image != null) {
      //   setProfileImage(image.path);
      // }

      // For demonstration, we'll just show that the method exists
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setProfileImage(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _errorMessage = 'Failed to pick image. Please try again.';
      notifyListeners();
    }
  }

  /// Validate form
  bool _validateForm() {
    _fieldErrors.clear();
    bool isValid = true;

    if (firstName.isEmpty) {
      _fieldErrors['firstName'] = 'First name is required';
      isValid = false;
    }
    if (lastName.isEmpty) {
      _fieldErrors['lastName'] = 'Last name is required';
      isValid = false;
    }
    if (phone.isEmpty) {
      _fieldErrors['phone'] = 'Phone number is required';
      isValid = false;
    }
    if (position.isEmpty) {
      _fieldErrors['position'] = 'Position is required';
      isValid = false;
    }
    if (emergencyContactName.isEmpty) {
      _fieldErrors['emergencyContactName'] =
          'Emergency contact name is required';
      isValid = false;
    }
    if (emergencyPhone.isEmpty) {
      _fieldErrors['emergencyPhone'] = 'Emergency phone number is required';
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
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'position': position,
        'emergencyContactName': emergencyContactName,
        'emergencyPhone': emergencyPhone,
        'isCaptainProfileComplete': true,
      };

      if (imageUrl != null) {
        profileData['profileImage'] = imageUrl;
      }

      final dio = await AuthService.getWorkingDio();
      final response = await dio.put(
        AppConfig.profileEndpoint,
        data: profileData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local cache
        await _userPrefs.setFirstName(firstName);
        await _userPrefs.setLastName(lastName);
        await _userPrefs.setUserPhone(phone);
        await _userPrefs.setPosition(position);
        await _userPrefs.setEmergencyContactName(emergencyContactName);
        await _userPrefs.setEmergencyPhone(emergencyPhone);
        if (imageUrl != null) await _userPrefs.setProfileImage(imageUrl);
        await _userPrefs.setCaptainProfileComplete(true);

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

  Future<void> skipForNow() async {
    // Mark as incomplete but allowed to proceed
    await _userPrefs.setCaptainProfileComplete(false);
  }
}
