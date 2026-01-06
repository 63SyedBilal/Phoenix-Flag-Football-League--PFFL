import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/user_service.dart';
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
  String? _phoneError;
  String? _userId;
  String _position = '';
  String _jerseyNumber = '';

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
  String get position => _position;
  String get jerseyNumber => _jerseyNumber;

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

      if (_userId == null) {
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

      final storedPosition = prefs.getString('admin_position');
      final storedJersey = prefs.getString('admin_jersey');
      if (storedPosition != null) _position = storedPosition;
      if (storedJersey != null) _jerseyNumber = storedJersey;

      // Try to sync with backend
      await _syncWithBackend();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
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
          if (data['position'] != null) _position = data['position'] ?? '';
          if (data['jerseyNumber'] != null)
            _jerseyNumber = data['jerseyNumber'].toString();
          if (data['profileImage'] != null) _imageUrl = data['profileImage'];

          // Update SharedPreferences cache
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_firstName', _firstName);
          await prefs.setString('admin_lastName', _lastName);
          await prefs.setString('userEmail', _email);
          if (_phone.isNotEmpty) {
            await prefs.setString('admin_phone', _phone);
          }
          await prefs.setString('admin_position', _position);
          await prefs.setString('admin_jersey', _jerseyNumber);
          if (_imageUrl != null) {
            await prefs.setString('admin_image', _imageUrl!);
          }
        }
      }
    } catch (e) {
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

  void updatePosition(String value) {
    _position = value;
    notifyListeners();
  }

  void updateJerseyNumber(String value) {
    _jerseyNumber = value;
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
      // Check for specific Cloudinary configuration errors
      if (e.toString().contains('Cloudinary') ||
          e.toString().contains('CLOUDINARY') ||
          e.toString().contains('500')) {}

      // We don't set _errorMessage here to allow saveProfile to handle it or continue
      // Image upload failure should not prevent profile updates
      return null;
    }
  }

  /// Save profile to backend using multiple endpoint strategies
  Future<bool> saveProfile() async {
    if (_userId == null) {
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
          } else {}
        } catch (e) {
          // Continue without image - it's completely optional
          // Don't include image in profile data if upload failed
          if (e.toString().contains('Cloudinary')) {}
        }
      }

      // Prepare profile data
      final profileData = <String, dynamic>{
        if (_firstName.isNotEmpty) 'firstName': _firstName.trim(),
        if (_lastName.isNotEmpty) 'lastName': _lastName.trim(),
        if (_email.isNotEmpty) 'email': _email.trim(),
        if (_phone.isNotEmpty) 'phone': _phone.trim(),
        if (_position.isNotEmpty) 'position': _position.trim(),
        if (_jerseyNumber.isNotEmpty) 'jerseyNumber': _jerseyNumber.trim(),
        if (finalImageUrl != null && finalImageUrl.startsWith('http'))
          'profileImage': finalImageUrl,
        'profileCompleted': true,
      };

      // Try multiple endpoint strategies until one works
      final dio = await AuthService.getWorkingDio();

      // Strategy 1: PUT /user/:id (User Update - Primary)
      try {
        final response = await dio.put('/user/$_userId', data: profileData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return await _handleSuccessResponse(response);
        }
      } catch (e) {}

      // Strategy 2: PUT /complete-profile (Profile Completion - Secondary)
      try {
        final response = await dio.put(
          AppConfig.completeProfileEndpoint,
          data: profileData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return await _handleSuccessResponse(response);
        }
      } catch (e) {}

      // Strategy 3: POST /profile (Legacy Endpoint)
      try {
        final response = await dio.post(
          AppConfig.profileEndpoint,
          data: profileData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return await _handleSuccessResponse(response);
        }
      } catch (e) {}

      // Strategy 6: Use UserService.updateProfile (fallback)
      try {
        final result = await UserService.updateProfile(_userId!, profileData);

        if (result != null) {
          // Update local state with response data
          if (result['firstName'] != null)
            _firstName = result['firstName'] ?? '';
          if (result['lastName'] != null) _lastName = result['lastName'] ?? '';
          if (result['email'] != null) _email = result['email'] ?? '';
          if (result['phone'] != null) _phone = result['phone'] ?? '';
          if (result['profileImage'] != null)
            _imageUrl = result['profileImage'];

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
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {}

      // If all backend strategies failed - save locally only (HEAD fallback)
      await _updateLocalProfile(profileData);
      return await _handleLocalSuccess();
    } catch (e) {
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
        // This should not happen anymore since we handle locally, but keep as fallback
        _errorMessage =
            'Profile updated locally. Some features may require backend support.';
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
      if (userData['position'] != null) _position = userData['position'] ?? '';
      if (userData['jerseyNumber'] != null)
        _jerseyNumber = userData['jerseyNumber'].toString();
      if (userData['profileImage'] != null)
        _imageUrl = userData['profileImage'];
    }

    // Save to SharedPreferences for persistence
    final prefs = await SharedPreferences.getInstance();

    // CRITICAL: Get and preserve current role BEFORE any updates
    final currentRole = prefs.getString('userRole');
    final currentUserId = prefs.getString('userId');

    await prefs.setString('admin_firstName', _firstName);
    await prefs.setString('admin_lastName', _lastName);
    await prefs.setString('userEmail', _email);
    if (_phone.isNotEmpty) {
      await prefs.setString('admin_phone', _phone);
    }
    await prefs.setString('admin_position', _position);
    await prefs.setString('admin_jersey', _jerseyNumber);
    if (_imageUrl != null) {
      await prefs.setString('admin_image', _imageUrl!);
    }

    // CRITICAL: Restore user role and ID after profile updates
    // This prevents unwanted navigation to different dashboards after profile updates
    if (currentRole != null) {
      await prefs.setString('userRole', currentRole);
    }
    if (currentUserId != null) {
      await prefs.setString('userId', currentUserId);
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Update local profile storage
  Future<void> _updateLocalProfile(Map<String, dynamic> profileData) async {
    // Update in-memory values
    if (profileData.containsKey('firstName')) {
      _firstName = profileData['firstName'];
    }
    if (profileData.containsKey('lastName')) {
      _lastName = profileData['lastName'];
    }
    if (profileData.containsKey('email')) {
      _email = profileData['email'];
    }
    if (profileData.containsKey('phone')) {
      _phone = profileData['phone'];
    }
    if (profileData.containsKey('position')) {
      _position = profileData['position'];
    }
    if (profileData.containsKey('jerseyNumber')) {
      _jerseyNumber = profileData['jerseyNumber'].toString();
    }

    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (profileData.containsKey('firstName')) {
      await prefs.setString('firstName', profileData['firstName']);
    }
    if (profileData.containsKey('lastName')) {
      await prefs.setString('lastName', profileData['lastName']);
    }
    if (profileData.containsKey('email')) {
      await prefs.setString('userEmail', profileData['email']);
    }
    if (profileData.containsKey('phone')) {
      await prefs.setString('userPhone', profileData['phone']);
    }
    if (profileData.containsKey('position')) {
      await prefs.setString('admin_position', profileData['position']);
    }
    if (profileData.containsKey('jerseyNumber')) {
      await prefs.setString(
        'admin_jersey',
        profileData['jerseyNumber'].toString(),
      );
    }
  }

  /// Handle local success (no API call needed)
  Future<bool> _handleLocalSuccess() async {
    // CRITICAL: Get and preserve current role and user ID BEFORE any updates
    final prefs = await SharedPreferences.getInstance();
    final currentRole = prefs.getString('userRole');
    final currentUserId = prefs.getString('userId');

    // CRITICAL: Restore user role and ID after profile updates
    // This prevents unwanted navigation to different dashboards after profile updates
    if (currentRole != null) {
      await prefs.setString('userRole', currentRole);
    }
    if (currentUserId != null) {
      await prefs.setString('userId', currentUserId);
    }

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
