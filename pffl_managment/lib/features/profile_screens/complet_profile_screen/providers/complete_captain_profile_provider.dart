import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Provider for Complete Captain Profile screen state and business logic
class CompleteCaptainProfileProvider extends ChangeNotifier {
  // TextEditingControllers for inputs
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final jerseyNumberController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final UserPreferenceProvider _userPrefs;

  CompleteCaptainProfileProvider(this._userPrefs);

  // Profile fields
  String? _profileImagePath;
  String? _profileImageUrl;
  bool _agreedToTerms = false;
  final List<String> _selectedPositions = [];

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
  String get position => _selectedPositions.join(', ');
  List<String> get selectedPositions => List.unmodifiable(_selectedPositions);
  String get jerseyNumber => jerseyNumberController.text;
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

  String? get selectedPosition => _selectedPositions.isNotEmpty
      ? _selectedPositions.first
      : null;

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
    jerseyNumberController.dispose();
    emergencyContactNameController.dispose();
    emergencyPhoneController.dispose();
    super.dispose();
  }

  /// Check if form is valid
  bool get isFormValid {
    return _profileImagePath != null &&
        _profileImagePath!.isNotEmpty &&
        position.isNotEmpty &&
        _fieldErrors['jerseyNumber'] == null &&
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
      _selectedPositions.clear();
      final cachedPos = _userPrefs.position;
      if (cachedPos != null && cachedPos.trim().isNotEmpty) {
        _selectedPositions.addAll(
          cachedPos
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }
      jerseyNumberController.text = _userPrefs.jerseyNumber ?? '';
      emergencyContactNameController.text =
          _userPrefs.emergencyContactName ?? '';
      emergencyPhoneController.text = _userPrefs.emergencyPhone ?? '';
      _profileImagePath = _userPrefs.profileImage;

      // Asynchronously fetch from backend to sync
      _syncWithBackend();

      notifyListeners();
    } catch (e) {
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
          final candidate =
              responseData['data'] ?? responseData['user'] ?? responseData;
          if (candidate is Map<String, dynamic>) {
            data = candidate;
          } else if (candidate is List && candidate.isNotEmpty) {
            final first = candidate.first;
            if (first is Map<String, dynamic>) {
              data = first;
            } else if (first is Map) {
              data = Map<String, dynamic>.from(first);
            }
          }
        } else if (responseData is List && responseData.isNotEmpty) {
          final first = responseData.first;
          if (first is Map<String, dynamic>) {
            data = first;
          } else if (first is Map) {
            data = Map<String, dynamic>.from(first);
          }
        }

        if (data != null) {
          await _userPrefs.setFirstName(data['firstName']);
          await _userPrefs.setLastName(data['lastName']);
          await _userPrefs.setUserPhone(data['phone']);
          await _userPrefs.setPosition(data['position']);
          await _userPrefs.setJerseyNumber(data['jerseyNumber']?.toString());
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
          if (_selectedPositions.isEmpty) {
            final pos = data['position'];
            if (pos is String && pos.trim().isNotEmpty) {
              _selectedPositions.addAll(
                pos
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty),
              );
            }
          }
          if (jerseyNumberController.text.isEmpty)
            jerseyNumberController.text = data['jerseyNumber']?.toString() ?? '';
          if (emergencyContactNameController.text.isEmpty)
            emergencyContactNameController.text =
                data['emergencyContactName'] ?? '';
          if (emergencyPhoneController.text.isEmpty)
            emergencyPhoneController.text = data['emergencyPhone'] ?? '';
          final img = data['profileImage'];
          if (img is String && img.isNotEmpty) {
            _profileImagePath = img;
          }

          notifyListeners();
        }
      }
    } catch (e) {
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

  void setEmergencyContactName(String? name) {
    emergencyContactNameController.text = name ?? '';
    _fieldErrors.remove('emergencyContactName');

    if (name != null && name.isNotEmpty && name.trim().length < 2) {
      _fieldErrors['emergencyContactName'] =
          'Name must be at least 2 characters';
    }

    notifyListeners();
  }

  void setJerseyNumber(String? number) {
    jerseyNumberController.text = number ?? '';
    _fieldErrors.remove('jerseyNumber');

    if (number != null && number.isNotEmpty) {
      final jerseyNum = int.tryParse(number);
      if (jerseyNum == null || jerseyNum < 1 || jerseyNum > 99) {
        _fieldErrors['jerseyNumber'] = 'Jersey number must be between 1 and 99';
      }
    }

    notifyListeners();
  }

  void setPosition(String? value) {
    if (value == null) return;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    if (_selectedPositions.contains(trimmed)) {
      _selectedPositions.remove(trimmed);
    } else {
      _selectedPositions.add(trimmed);
    }
    _fieldErrors.remove('position');
    notifyListeners();
  }

  void clearPositions() {
    _selectedPositions.clear();
    _fieldErrors.remove('position');
    notifyListeners();
  }

  void setProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    _fieldErrors.remove('profileImage');
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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setProfileImage(image.path);
      }

      // For demonstration, we'll just show that the method exists
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setProfileImage(result.files.single.path!);
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image. Please try again.';
      notifyListeners();
    }
  }

  /// Validate form
  bool _validateForm() {
    _fieldErrors.clear();
    bool isValid = true;

    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      _fieldErrors['profileImage'] = 'Profile image is required';
      isValid = false;
    }

    // Do not require first/last/phone here because this screen doesn't collect them.
    if (_selectedPositions.isEmpty) {
      _fieldErrors['position'] = 'Position is required';
      isValid = false;
    }

    if (jerseyNumber.isNotEmpty) {
      final jerseyNum = int.tryParse(jerseyNumber);
      if (jerseyNum == null || jerseyNum < 1 || jerseyNum > 99) {
        _fieldErrors['jerseyNumber'] =
            'Jersey number must be between 1 and 99';
        isValid = false;
      }
    }
    if (emergencyContactName.isEmpty) {
      _fieldErrors['emergencyContactName'] =
          'Emergency contact name is required';
      isValid = false;
    } else if (emergencyContactName.trim().length < 2) {
      _fieldErrors['emergencyContactName'] = 'Name must be at least 2 characters';
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
    debugPrint(
      '➡️ CompleteCaptainProfileProvider: position=$position jersey=$jerseyNumber emergencyName=$emergencyContactName emergencyPhone=$emergencyPhone agreed=$_agreedToTerms imagePath=$_profileImagePath',
    );
    if (!_validateForm()) {
      debugPrint(
        '❌ CompleteCaptainProfileProvider: validation failed fieldErrors=$_fieldErrors errorMessage=$_errorMessage',
      );
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
          if (_profileImagePath!.toLowerCase().startsWith('http')) {
            imageUrl = _profileImagePath;
            _profileImageUrl = imageUrl;
            debugPrint(
              '➡️ CompleteCaptainProfileProvider: using existing imageUrl=$imageUrl',
            );
          } else {
            final imageFile = File(_profileImagePath!);
            if (await imageFile.exists()) {
              debugPrint(
                '➡️ CompleteCaptainProfileProvider: uploading image file=${imageFile.path}',
              );
              imageUrl = await AdminService.uploadImage(imageFile);
              _profileImageUrl = imageUrl;
              debugPrint(
                '✅ CompleteCaptainProfileProvider: image uploaded imageUrl=$imageUrl',
              );
            } else {
              debugPrint(
                '❌ CompleteCaptainProfileProvider: image file does not exist at path=$_profileImagePath',
              );
            }
          }
        } catch (e) {
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        _isLoading = false;
        _fieldErrors['profileImage'] = 'Failed to upload image. Please try again.';
        _errorMessage = 'Failed to upload image. Please try again.';
        notifyListeners();
        return false;
      }

      // Prepare profile data
      final profileData = <String, dynamic>{
        // Backend requires user's phone number even if this screen doesn't collect it.
        'phone': _userPrefs.userPhone ?? phoneController.text,
        'position': position,
        'emergencyContactName': emergencyContactName,
        'emergencyPhone': emergencyPhone,
        'isCaptainProfileComplete': true,
      };

      if (jerseyNumber.isNotEmpty) {
        final jerseyNum = int.tryParse(jerseyNumber);
        if (jerseyNum != null) {
          profileData['jerseyNumber'] = jerseyNum;
        }
      }

      profileData['profileImage'] = imageUrl;

      final dio = await AuthService.getWorkingDio();
      Response<dynamic>? response;
      debugPrint(
        '➡️ CompleteCaptainProfileProvider: sending profileData=$profileData',
      );

      // Strategy: backend commonly supports POST /profile (see ProfileService.createProfile).
      // We try that first, and only then fall back to other endpoints/methods.
      Future<Response<dynamic>?> tryRequest(
        Future<Response<dynamic>> Function() request,
        String label,
      ) async {
        try {
          final res = await request();
          return res;
        } on DioException catch (e) {
          debugPrint(
            '❌ CompleteCaptainProfileProvider: $label failed status=${e.response?.statusCode} message=${e.message} data=${e.response?.data}',
          );
          if (e.response?.statusCode == 504) {
            await Future.delayed(const Duration(seconds: 2));
            final retryRes = await request();
            debugPrint(
              '➡️ CompleteCaptainProfileProvider: $label retry status=${retryRes.statusCode}',
            );
            return retryRes;
          }
          // For 404/405 and other errors, return response (if any) so caller can decide next fallback.
          return e.response;
        }
      }

      response = await tryRequest(
        () => dio.post(AppConfig.profileEndpoint, data: profileData),
        'POST ${AppConfig.profileEndpoint}',
      );

      if (response == null || response.statusCode == 404 || response.statusCode == 405) {
        response = await tryRequest(
          () => dio.patch(AppConfig.profileEndpoint, data: profileData),
          'PATCH ${AppConfig.profileEndpoint}',
        );
      }

      if (response == null || response.statusCode == 404 || response.statusCode == 405) {
        response = await tryRequest(
          () => dio.put(AppConfig.profileEndpoint, data: profileData),
          'PUT ${AppConfig.profileEndpoint}',
        );
      }

      if (response == null || response.statusCode == 404 || response.statusCode == 405) {
        response = await tryRequest(
          () => dio.post(AppConfig.completeProfileEndpoint, data: profileData),
          'POST ${AppConfig.completeProfileEndpoint}',
        );
      }

      if (response == null) {
        throw Exception('Failed to complete profile');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
          '✅ CompleteCaptainProfileProvider: submitProfile success status=${response.statusCode} data=${response.data}',
        );
        // Update local cache
        await _userPrefs.setPosition(position);
        await _userPrefs.setJerseyNumber(jerseyNumber);
        await _userPrefs.setEmergencyContactName(emergencyContactName);
        await _userPrefs.setEmergencyPhone(emergencyPhone);
        await _userPrefs.setProfileImage(imageUrl);
        await _userPrefs.setCaptainProfileComplete(true);

        _showSuccessSheet = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint(
          '❌ CompleteCaptainProfileProvider: submitProfile non-success status=${response.statusCode} data=${response.data}',
        );
        String msg = 'Failed to complete profile';
        final data = response.data;
        if (data is Map) {
          msg =
              data['message']?.toString() ??
              data['error']?.toString() ??
              msg;
        } else if (data != null) {
          msg = data.toString();
        }

        // Surface backend validation errors inline (no UI redesign).
        final lower = msg.toLowerCase();
        if (lower.contains('emergency') && lower.contains('required')) {
          _fieldErrors['emergencyPhone'] = msg;
        }

        if (lower.contains('phone') && lower.contains('required')) {
          // This screen doesn't collect phone; still show a helpful message.
          _fieldErrors['emergencyPhone'] = msg;
        }

        notifyListeners();
        throw Exception(msg);
      }
    } on DioException catch (e) {
      _isLoading = false;
      debugPrint(
        '❌ CompleteCaptainProfileProvider: DioException status=${e.response?.statusCode} message=${e.message} data=${e.response?.data}',
      );
      String msg = e.message ?? 'Request failed';
      final data = e.response?.data;
      if (data is Map) {
        msg =
            data['message']?.toString() ??
            data['error']?.toString() ??
            msg;
      } else if (data != null) {
        msg = data.toString();
      }

      final lower = msg.toLowerCase();
      if (e.response?.statusCode == 400 &&
          (lower.contains('emergency') || lower.contains('phone'))) {
        _fieldErrors['emergencyPhone'] = msg;
      }

      _errorMessage = msg;
      notifyListeners();
      return false;
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

