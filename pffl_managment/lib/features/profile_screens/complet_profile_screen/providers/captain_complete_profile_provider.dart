import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/core/services/captain_profile_completion_service.dart';

class CaptainCompleteProfileProvider extends ChangeNotifier {
  final UserPreferenceProvider _userPrefs;

  // Controllers
  final jerseyNumberController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();

  CaptainCompleteProfileProvider(this._userPrefs);

  // State
  final Map<String, String?> _fieldErrors = {};
  bool _isLoading = false;
  String? _errorMessage;

  String? _phone;

  String? _profileImagePath;
  String? _profileImageUrl;
  bool _agreedToTerms = false;
  final List<String> _selectedPositions = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);

  String? get profileImagePath => _profileImagePath;
  bool get agreedToTerms => _agreedToTerms;
  List<String> get selectedPositions => List.unmodifiable(_selectedPositions);

  String get phone => _phone ?? '';

  String get position => _selectedPositions.join(', ');
  String get jerseyNumber => jerseyNumberController.text;
  String get emergencyContactName => emergencyContactNameController.text;
  String get emergencyPhone => emergencyPhoneController.text;

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

  Future<void> initialize() async {
    _selectedPositions.clear();
    final cachedPos = _userPrefs.position;
    if (cachedPos != null && cachedPos.trim().isNotEmpty) {
      _selectedPositions.addAll(
        cachedPos.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
      );
    }

    _phone = _userPrefs.userPhone;
    jerseyNumberController.text = _userPrefs.jerseyNumber ?? '';
    emergencyContactNameController.text = _userPrefs.emergencyContactName ?? '';
    emergencyPhoneController.text = _userPrefs.emergencyPhone ?? '';
    _profileImagePath = _userPrefs.profileImage;
    notifyListeners();
  }

  Future<void> skipForNow() async {
    await _userPrefs.setCaptainProfileComplete(false);
  }

  void setJerseyNumber(String value) {
    jerseyNumberController.text = value;
    _fieldErrors.remove('jerseyNumber');
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    _fieldErrors.remove('phone');
    notifyListeners();
  }

  void setEmergencyContactName(String value) {
    emergencyContactNameController.text = value;
    _fieldErrors.remove('emergencyContactName');
    notifyListeners();
  }

  void setEmergencyPhone(String value) {
    emergencyPhoneController.text = value;
    _fieldErrors.remove('emergencyPhone');
    notifyListeners();
  }

  void toggleTermsAgreement(bool value) {
    _agreedToTerms = value;
    _fieldErrors.remove('terms');
    notifyListeners();
  }

  void togglePosition(String position) {
    final p = position.trim();
    if (p.isEmpty) return;

    if (_selectedPositions.contains(p)) {
      _selectedPositions.remove(p);
    } else {
      _selectedPositions.add(p);
    }

    _fieldErrors.remove('position');
    notifyListeners();
  }

  void clearPositions() {
    _selectedPositions.clear();
    _fieldErrors.remove('position');
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        _profileImagePath = result.files.single.path!;
        _fieldErrors.remove('profileImage');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image. Please try again.';
      notifyListeners();
    }
  }

  bool _validate() {
    _fieldErrors.clear();
    bool ok = true;

    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      _fieldErrors['profileImage'] = 'Profile image is required';
      ok = false;
    }

    if (_selectedPositions.isEmpty) {
      _fieldErrors['position'] = 'Position is required';
      ok = false;
    }

    if (phone.trim().isEmpty) {
      _fieldErrors['phone'] =
          'Phone number is required. Please update your phone number first.';
      ok = false;
    }

    if (jerseyNumber.isNotEmpty) {
      final jerseyNum = int.tryParse(jerseyNumber);
      if (jerseyNum == null || jerseyNum < 1 || jerseyNum > 99) {
        _fieldErrors['jerseyNumber'] = 'Jersey number must be between 1 and 99';
        ok = false;
      }
    }

    if (emergencyContactName.trim().isEmpty) {
      _fieldErrors['emergencyContactName'] =
          'Emergency contact name is required';
      ok = false;
    }

    if (emergencyPhone.trim().isEmpty) {
      _fieldErrors['emergencyPhone'] =
          'Emergency phone number is required';
      ok = false;
    }

    if (!_agreedToTerms) {
      _fieldErrors['terms'] = 'You must agree to Terms & Privacy';
      ok = false;
    }

    notifyListeners();
    return ok;
  }

  Future<bool> submit() async {
    if (!_validate()) {
      _errorMessage = 'Please fix the errors below';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Upload image (required)
      String? imageUrl;
      if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
        if (_profileImagePath!.toLowerCase().startsWith('http')) {
          imageUrl = _profileImagePath;
        } else {
          final file = File(_profileImagePath!);
          imageUrl = await AdminService.uploadImage(file);
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        _fieldErrors['profileImage'] =
            'Failed to upload image. Please try again.';
        _errorMessage = 'Failed to upload image. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final profileData = <String, dynamic>{
        'phone': phone.trim(),
        'position': position,
        'emergencyContactName': emergencyContactName.trim(),
        'emergencyPhone': emergencyPhone.trim(),
        'isCaptainProfileComplete': true,
        'profileImage': imageUrl,
      };

      if (jerseyNumber.isNotEmpty) {
        final jerseyNum = int.tryParse(jerseyNumber);
        if (jerseyNum != null) {
          profileData['jerseyNumber'] = jerseyNum;
        }
      }

      final result = await CaptainProfileCompletionService.submitCaptainProfile(
        profileData: profileData,
      );

      if (!result.success) {
        final msg = result.message ?? 'Failed to complete profile';
        final lower = msg.toLowerCase();

        if (lower.contains('phone') && !lower.contains('emergency')) {
          _fieldErrors['phone'] = msg;
        } else if (lower.contains('emergency') && lower.contains('phone')) {
          _fieldErrors['emergencyPhone'] = msg;
        } else if (lower.contains('emergency')) {
          _fieldErrors['emergencyPhone'] = msg;
        }

        _errorMessage = msg;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _userPrefs.setUserPhone(phone);
      await _userPrefs.setPosition(position);
      await _userPrefs.setJerseyNumber(jerseyNumber);
      await _userPrefs.setEmergencyContactName(emergencyContactName);
      await _userPrefs.setEmergencyPhone(emergencyPhone);
      await _userPrefs.setProfileImage(imageUrl);
      await _userPrefs.setCaptainProfileComplete(true);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    jerseyNumberController.dispose();
    emergencyContactNameController.dispose();
    emergencyPhoneController.dispose();
    super.dispose();
  }
}
