import 'dart:io';
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
      // Assuming a generic endpoint for profile updates or a dedicated one for referees
      final response = await dio.put(
        AppConfig
            .completeProfileEndpoint, // Reusing existing endpoint if applicable
        data: profileData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 3. Update local state
        await _userPrefs.setRefereeProfileComplete(true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to save profile.';
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
