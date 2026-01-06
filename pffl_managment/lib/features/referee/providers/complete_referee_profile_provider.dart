import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';

class CompleteRefereeProfileProvider extends ChangeNotifier {
  final UserPreferenceProvider _userPrefs;

  CompleteRefereeProfileProvider(this._userPrefs);

  String? _experience;
  String? _emergencyContactName;
  String? _emergencyPhone;
  String? _profileImagePath;
  String? _profileImageUrl;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneError;

  // Options for experience dropdown
  final List<String> experienceOptions = ['0–1', '1–3', '3–5', '5–10', '10+'];

  // Getters
  String? get experience => _experience;
  String? get emergencyContactName => _emergencyContactName;
  String? get emergencyPhone => _emergencyPhone;
  String? get profileImagePath => _profileImagePath;
  String? get profileImageUrl => _profileImageUrl;
  bool get agreedToTerms => _agreedToTerms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get phoneError => _phoneError;

  bool get isFormValid {
    return _profileImagePath != null &&
        _experience != null &&
        _emergencyContactName != null &&
        _emergencyContactName!.isNotEmpty &&
        _emergencyPhone != null &&
        _emergencyPhone!.isNotEmpty &&
        _agreedToTerms;
  }

  // Setters
  void setExperience(String? value) {
    _experience = value;
    notifyListeners();
  }

  void setEmergencyContactName(String? value) {
    _emergencyContactName = value;
    notifyListeners();
  }

  void setEmergencyPhone(String? value) {
    _emergencyPhone = value;
    _phoneError = null; // Clear error on change
    notifyListeners();
  }

  void setProfileImage(String? path) {
    _profileImagePath = path;
    notifyListeners();
  }

  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  Future<void> initialize() async {
    // Load from local cache
    _experience = _userPrefs.experience;
    _emergencyContactName = _userPrefs.emergencyContactName;
    _emergencyPhone = _userPrefs.emergencyPhone;
    _profileImagePath = _userPrefs.profileImage;
    _agreedToTerms = _userPrefs
        .isRefereeProfileComplete; // If complete, they probably agreed

    // Sync with backend
    _syncWithBackend();

    notifyListeners();
  }

  Future<void> _syncWithBackend() async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.get(AppConfig.profileEndpoint);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data['user'];
        if (data != null) {
          await _userPrefs.setExperience(data['experience']);
          await _userPrefs.setEmergencyContactName(
            data['emergencyContactName'],
          );
          await _userPrefs.setEmergencyPhone(data['emergencyPhone']);
          await _userPrefs.setProfileImage(data['profileImage']);
          await _userPrefs.setRefereeProfileComplete(
            data['isRefereeProfileComplete'] ?? true,
          );

          _experience = data['experience'];
          _emergencyContactName = data['emergencyContactName'];
          _emergencyPhone = data['emergencyPhone'];
          _profileImagePath = data['profileImage'];

          notifyListeners();
        }
      }
    } catch (e) {}
  }

  Future<bool> submitProfile() async {
    if (!isFormValid) {
      _errorMessage =
          'Please fill all required fields and upload a profile picture.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload image
      String? uploadedUrl;
      if (_profileImagePath != null) {
        final imageFile = File(_profileImagePath!);
        uploadedUrl = await AdminService.uploadImage(imageFile);
        _profileImageUrl = uploadedUrl;
      }

      // 2. Save profile to backend
      final profileData = {
        'experience': _experience,
        'emergencyContactName': _emergencyContactName,
        'emergencyPhone': _emergencyPhone,
        'profileImage': _profileImageUrl,
        'isRefereeProfileComplete': true,
      };

      final dio = await AuthService.getWorkingDio();
      final userId = _userPrefs.userId;

      if (userId == null || userId.isEmpty) {
        _errorMessage = 'User ID not found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Explicitly use PUT /api/user/:id
      // This is the correct endpoint for updating user profiles.
      // We do NOT use /api/profile for updates as it only supports POST/GET.
      Response? response;
      try {
        response = await dio.put(
          '${AppConfig.userEndpoint}/$userId',
          data: profileData,
          options: Options(validateStatus: (s) => s != null && s < 500),
        );
      } catch (e) {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // If user endpoint fails, try complete-profile as backup (for legacy support)
      if (response == null ||
          (response.statusCode != 200 && response.statusCode != 201)) {
        try {
          response = await dio.put(
            AppConfig.completeProfileEndpoint,
            data: profileData,
            options: Options(validateStatus: (s) => s != null && s < 500),
          );
        } catch (_) {}
      }

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        // 3. Update local cache
        await _userPrefs.setExperience(_experience);
        await _userPrefs.setEmergencyContactName(_emergencyContactName);
        await _userPrefs.setEmergencyPhone(_emergencyPhone);
        if (uploadedUrl != null) await _userPrefs.setProfileImage(uploadedUrl);
        await _userPrefs.setRefereeProfileComplete(true);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response?.data['message'] ?? 'Failed to save profile.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> skipForNow() async {
    // Just mark as incomplete and keep moving (navigation handled in UI)
    await _userPrefs.setRefereeProfileComplete(false);
  }
}
