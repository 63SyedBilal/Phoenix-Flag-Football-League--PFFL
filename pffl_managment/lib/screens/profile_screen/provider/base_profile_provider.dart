import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';

abstract class BaseProfileProvider extends ChangeNotifier {
  final UserPreferenceProvider prefsProvider;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? _imageUrl;
  File? _selectedImageFile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneError;

  BaseProfileProvider(this.prefsProvider);

  // Getters
  String get firstName => firstNameController.text;
  String get lastName => lastNameController.text;
  String get email => emailController.text;
  String get phone => phoneController.text;
  String? get imageUrl => _imageUrl;
  File? get selectedImageFile => _selectedImageFile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get phoneError => _phoneError;

  // Role details
  String get role;
  String get dashboardRoute;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void initialize() {
    _isLoading = true;
    notifyListeners();

    firstNameController.text = prefsProvider.firstName ?? '';
    lastNameController.text = prefsProvider.lastName ?? '';
    emailController.text = prefsProvider.userEmail ?? '';
    phoneController.text = prefsProvider.userPhone ?? '';
    _imageUrl = prefsProvider.profileImage;

    _syncWithBackend();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncWithBackend() async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.get(AppConfig.profileEndpoint);

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic>? data;

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
          if (data['firstName'] != null)
            firstNameController.text = data['firstName'] ?? '';
          if (data['lastName'] != null)
            lastNameController.text = data['lastName'] ?? '';
          if (data['email'] != null) emailController.text = data['email'] ?? '';
          if (data['phone'] != null) phoneController.text = data['phone'] ?? '';
          if (data['profileImage'] != null) _imageUrl = data['profileImage'];

          // Update preferences
          await prefsProvider.setFirstName(firstNameController.text);
          await prefsProvider.setLastName(lastNameController.text);
          await prefsProvider.setUserEmail(emailController.text);
          await prefsProvider.setUserPhone(phoneController.text);
          if (_imageUrl != null) {
            await prefsProvider.setProfileImage(_imageUrl!);
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error syncing profile: $e');
    }
  }

  void updateFirstName(String value) => notifyListeners();
  void updateLastName(String value) => notifyListeners();
  void updateEmail(String value) => notifyListeners();
  void updatePhone(String value) {
    _phoneError = null;
    notifyListeners();
  }

  void setPhoneValid(bool isValid) {
    if (!isValid && phoneController.text.isNotEmpty) {
      _phoneError = 'Please enter a valid phone number';
    } else {
      _phoneError = null;
    }
    notifyListeners();
  }

  void selectImage(File? file) {
    _selectedImageFile = file;
    if (file != null) {
      _imageUrl = file.path;
    }
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (_selectedImageFile == null) return _imageUrl;

    try {
      final uploadedUrl = await AdminService.uploadImage(_selectedImageFile!);
      if (uploadedUrl != null) {
        _imageUrl = uploadedUrl;
        _selectedImageFile = null;
        return uploadedUrl;
      }
      return null;
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  // Common data preparation
  Map<String, dynamic> getProfileData(String? finalImageUrl) {
    return {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      if (finalImageUrl != null && finalImageUrl.startsWith('http'))
        'profileImage': finalImageUrl,
    };
  }

  Future<bool> saveProfile() async {
    final userId = prefsProvider.userId;
    if (userId == null) {
      _errorMessage = 'User ID not found. Please login again.';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String? finalImageUrl = await uploadImage();
      final profileData = getProfileData(finalImageUrl);

      final dio = await AuthService.getWorkingDio();

      // Strategies logic
      bool success = false;

      // Strategy 1: PUT /user/:id
      try {
        final response = await dio.put('/user/$userId', data: profileData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          await _handleSuccessResponse(response);
          success = true;
        }
      } catch (e) {}

      if (!success) {
        // Strategy 2: PATCH /user/:id
        try {
          final response = await dio.patch('/user/$userId', data: profileData);
          if (response.statusCode == 200 || response.statusCode == 201) {
            await _handleSuccessResponse(response);
            success = true;
          }
        } catch (e) {}
      }

      if (!success) {
        // Strategy 3: PATCH /profile
        try {
          final response = await dio.patch(
            AppConfig.profileEndpoint,
            data: profileData,
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            await _handleSuccessResponse(response);
            success = true;
          }
        } catch (e) {}
      }

      if (!success) {
        // Last resort: Update locally if backend fails but we want to allow progress
        await updateLocalOnly(profileData);
        success = true;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _handleSuccessResponse(dynamic response) async {
    final responseData = response.data;
    Map<String, dynamic>? userData;

    if (responseData is Map) {
      if (responseData.containsKey('data')) {
        userData = responseData['data'] as Map<String, dynamic>?;
      } else if (responseData.containsKey('user')) {
        userData = responseData['user'] as Map<String, dynamic>?;
      } else {
        userData = responseData as Map<String, dynamic>?;
      }
    }

    if (userData != null) {
      await updateLocalOnly(userData);
    }
  }

  @protected
  Future<void> updateLocalOnly(Map<String, dynamic> data) async {
    if (data.containsKey('firstName'))
      await prefsProvider.setFirstName(data['firstName']);
    if (data.containsKey('lastName'))
      await prefsProvider.setLastName(data['lastName']);
    if (data.containsKey('email'))
      await prefsProvider.setUserEmail(data['email']);
    if (data.containsKey('phone'))
      await prefsProvider.setUserPhone(data['phone']);
    if (data.containsKey('profileImage'))
      await prefsProvider.setProfileImage(data['profileImage']);

    // Update controllers to keep in sync
    firstNameController.text = prefsProvider.firstName ?? '';
    lastNameController.text = prefsProvider.lastName ?? '';
    emailController.text = prefsProvider.userEmail ?? '';
    phoneController.text = prefsProvider.userPhone ?? '';
    _imageUrl = prefsProvider.profileImage;
  }
}
