import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';

/// Provider for Admin Profile Screen
class AdminProfileProvider extends ChangeNotifier {
  // State variables
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String? _imageUrl;
  File? _selectedImageFile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneError; // Phone-specific error
  String? _userId;
  String? _userRole;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get phone => _phone;
  String? get imageUrl => _imageUrl;
  File? get selectedImageFile => _selectedImageFile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get phoneError => _phoneError;

  /// Initialize and load profile data
  Future<void> initialize() async {
    if (_isLoading) return;
    await loadProfile();
  }

  /// Load profile data from stored user data or token
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get user ID and role from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      _userRole = prefs.getString('userRole');

      if (_userId == null) {
        debugPrint('Warning: User ID not found. Profile update may fail.');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load stored profile data if available
      final storedFirstName = prefs.getString('admin_firstName');
      final storedLastName = prefs.getString('admin_lastName');
      final storedEmail = prefs.getString('userEmail');
      final storedPhone = prefs.getString('admin_phone');
      final storedImage = prefs.getString('admin_image');

      if (storedFirstName != null) _firstName = storedFirstName;
      if (storedLastName != null) _lastName = storedLastName;
      if (storedEmail != null) _email = storedEmail;
      if (storedPhone != null) _phone = storedPhone;
      if (storedImage != null) _imageUrl = storedImage;

      // Try to sync with backend
      await _syncWithBackend();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _errorMessage = 'Failed to load profile';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync profile data with backend
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
          // Update local state with backend data
          if (data['firstName'] != null) _firstName = data['firstName'] ?? '';
          if (data['lastName'] != null) _lastName = data['lastName'] ?? '';
          if (data['email'] != null) _email = data['email'] ?? '';
          if (data['phone'] != null) _phone = data['phone'] ?? '';
          if (data['profileImage'] != null) _imageUrl = data['profileImage'];

          // Update SharedPreferences cache
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_firstName', _firstName);
          await prefs.setString('admin_lastName', _lastName);
          await prefs.setString('userEmail', _email);
          if (_phone.isNotEmpty) {
            await prefs.setString('admin_phone', _phone);
          }
          if (_imageUrl != null) {
            await prefs.setString('admin_image', _imageUrl!);
          }

          debugPrint('✅ Profile synced with backend');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Backend sync failed: $e');
      // Don't throw error - this is just a background sync
      // The app should work with cached data if sync fails
    }
  }

  /// Update first name
  void updateFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  /// Update last name
  void updateLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  /// Update email
  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  /// Update phone
  void updatePhone(String value) {
    _phone = value;
    // Clear phone error when user starts typing
    if (_phoneError != null) {
      _phoneError = null;
    }
    notifyListeners();
  }

  /// Set phone validation state
  void setPhoneValid(bool isValid) {
    if (!isValid && _phone.isNotEmpty) {
      _phoneError = 'Please enter a valid phone number';
    } else {
      _phoneError = null;
    }
    notifyListeners();
  }

  /// Set error message
  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _phoneError = null;
    notifyListeners();
  }

  /// Select image file
  void selectImage(File? file) {
    _selectedImageFile = file;
    if (file != null) {
      // Preview the selected image
      _imageUrl = file.path;
    }
    notifyListeners();
  }

  /// Upload image to server (completely optional - don't fail profile update if this fails)
  Future<String?> uploadImage() async {
    if (_selectedImageFile == null) {
      return _imageUrl; // Return existing URL if no new image
    }

    try {
      // Note: We don't set _isLoading here because this is called within saveProfile
      // which already manages loading state.

      final uploadedUrl = await AdminService.uploadImage(_selectedImageFile!);

      if (uploadedUrl != null) {
        _imageUrl = uploadedUrl;
        _selectedImageFile = null; // Clear selected file after upload
        return uploadedUrl;
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error uploading image: $e');

      // Check for specific Cloudinary configuration errors
      if (e.toString().contains('Cloudinary') ||
          e.toString().contains('CLOUDINARY') ||
          e.toString().contains('500')) {
        debugPrint(
          '⚠️ Cloudinary configuration issue detected - image upload is optional',
        );
      }

      // We don't set _errorMessage here to allow saveProfile to handle it or continue
      // Image upload failure should not prevent profile updates
      return null;
    }
  }

  /// Save profile to backend using multiple endpoint strategies
  Future<bool> saveProfile() async {
    print('💾 saveProfile called. userId: $_userId, userRole: $_userRole');

    if (_userId == null) {
      print('❌ userId is null in saveProfile');
      _errorMessage = 'User ID not found. Please login again.';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Upload image first if a new image was selected (OPTIONAL - don't fail if it doesn't work)
      String? finalImageUrl = _imageUrl;
      if (_selectedImageFile != null) {
        try {
          final uploadedUrl = await uploadImage();
          if (uploadedUrl != null) {
            finalImageUrl = uploadedUrl;
            print('✅ Profile image uploaded: $finalImageUrl');
          } else {
            print('⚠️ Image upload returned null, continuing without image');
          }
        } catch (e) {
          print('⚠️ Profile image upload failed: $e');
          // Continue without image - it's completely optional
          // Don't include image in profile data if upload failed
          if (e.toString().contains('Cloudinary')) {
            print(
              '⚠️ Cloudinary configuration issue detected, skipping image upload',
            );
          }
        }
      }

      // Prepare profile data
      final profileData = <String, dynamic>{
        if (_firstName.isNotEmpty) 'firstName': _firstName.trim(),
        if (_lastName.isNotEmpty) 'lastName': _lastName.trim(),
        if (_email.isNotEmpty) 'email': _email.trim(),
        if (_phone.isNotEmpty) 'phone': _phone.trim(),
        if (finalImageUrl != null && finalImageUrl.startsWith('http'))
          'profileImage': finalImageUrl,
      };

      print('🔄 Profile data prepared: $profileData');

      // Try multiple endpoint strategies until one works
      final dio = await AuthService.getWorkingDio();

      // Strategy 1: PATCH /profile
      try {
        print('🔄 Strategy 1: PATCH /profile');
        final response = await dio.patch(
          AppConfig.profileEndpoint,
          data: profileData,
        );
        print('📡 Strategy 1 Response: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return await _handleSuccessResponse(response);
        }
      } catch (e) {
        print('❌ Strategy 1 failed: $e');
      }

      // Strategy 2: PUT /profile
      try {
        print('🔄 Strategy 2: PUT /profile');
        final response = await dio.put(
          AppConfig.profileEndpoint,
          data: profileData,
        );
        print('📡 Strategy 2 Response: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return await _handleSuccessResponse(response);
        }
      } catch (e) {
        print('❌ Strategy 2 failed: $e');
      }

      // Strategy 3: POST /complete-profile
      try {
        print('🔄 Strategy 3: POST /complete-profile');
        final response = await dio.post(
          AppConfig.completeProfileEndpoint,
          data: profileData,
        );
        print('📡 Strategy 3 Response: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return await _handleSuccessResponse(response);
        }
      } catch (e) {
        print('❌ Strategy 3 failed: $e');
      }

      // Strategy 4: PUT /user (generic user update)
      try {
        print('🔄 Strategy 4: PUT /user');
        final response = await dio.put(
          AppConfig.userEndpoint,
          data: profileData,
        );
        print('📡 Strategy 4 Response: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return await _handleSuccessResponse(response);
        }
      } catch (e) {
        print('❌ Strategy 4 failed: $e');
      }

      // Strategy 5: PATCH /user
      try {
        print('🔄 Strategy 5: PATCH /user');
        final response = await dio.patch(
          AppConfig.userEndpoint,
          data: profileData,
        );
        print('📡 Strategy 5 Response: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return await _handleSuccessResponse(response);
        }
      } catch (e) {
        print('❌ Strategy 5 failed: $e');
      }

      // If all strategies failed
      throw Exception(
        'All profile update strategies failed. Please contact support.',
      );
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');

      // Handle specific error types
      if (e.toString().contains('401')) {
        _errorMessage = 'Authentication failed. Please login again.';
      } else if (e.toString().contains('409')) {
        _errorMessage =
            'Phone number already exists. Please use a different number.';
      } else if (e.toString().contains('404')) {
        _errorMessage = 'User not found. Please login again.';
      } else if (e.toString().contains('500')) {
        _errorMessage = 'Server error. Please try again later.';
      } else if (e.toString().contains(
        'All profile update strategies failed',
      )) {
        _errorMessage =
            'Unable to update profile. Please check your connection and try again.';
      } else {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Handle successful response from any strategy
  Future<bool> _handleSuccessResponse(dynamic response) async {
    print('✅ Profile update successful with status: ${response.statusCode}');
    print('📡 Response data: ${response.data}');

    // Handle response data
    final responseData = response.data;
    Map<String, dynamic>? userData;

    // Handle different response formats
    if (responseData is Map) {
      if (responseData.containsKey('data')) {
        userData = responseData['data'] as Map<String, dynamic>?;
      } else if (responseData.containsKey('user')) {
        userData = responseData['user'] as Map<String, dynamic>?;
      } else {
        userData = responseData as Map<String, dynamic>?;
      }
    }

    // Update local state with response data
    if (userData != null) {
      if (userData['firstName'] != null)
        _firstName = userData['firstName'] ?? '';
      if (userData['lastName'] != null) _lastName = userData['lastName'] ?? '';
      if (userData['email'] != null) _email = userData['email'] ?? '';
      if (userData['phone'] != null) _phone = userData['phone'] ?? '';
      if (userData['profileImage'] != null)
        _imageUrl = userData['profileImage'];
    }

    // Save to SharedPreferences for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_firstName', _firstName);
    await prefs.setString('admin_lastName', _lastName);
    await prefs.setString('userEmail', _email);
    if (_phone.isNotEmpty) {
      await prefs.setString('admin_phone', _phone);
    }
    if (_imageUrl != null) {
      await prefs.setString('admin_image', _imageUrl!);
    }

    print('✅ Profile updated successfully');
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Set user ID (should be called after login)
  Future<void> setUserId(String id) async {
    _userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    notifyListeners();
  }
}
