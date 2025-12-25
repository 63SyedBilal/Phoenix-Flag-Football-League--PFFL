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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _errorMessage = 'Failed to load profile';
      _isLoading = false;
      notifyListeners();
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

  /// Upload image to server
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
      // We don't set _errorMessage here to allow saveProfile to handle it or continue
      return null;
    }
  }

  /// Save profile to backend
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

      // Upload image first if a new image was selected
      String? finalImageUrl = _imageUrl;
      if (_selectedImageFile != null) {
        try {
          final uploadedUrl = await uploadImage();
          if (uploadedUrl != null) {
            finalImageUrl = uploadedUrl;
            print('✅ Profile image uploaded: $finalImageUrl');
          } else {
            print(
              '⚠️ Image upload returned null, continuing with existing image',
            );
          }
        } catch (e) {
          print('⚠️ Profile image upload failed: $e');
        }
      }

      // Prepare profile data WITHOUT ID (some backends don't like it in body if in URL)
      final cleanProfileData = <String, dynamic>{
        'email': _email,
        if (_firstName.isNotEmpty) 'firstName': _firstName,
        if (_lastName.isNotEmpty) 'lastName': _lastName,
        if (_phone.isNotEmpty) 'phone': _phone,
        if (finalImageUrl != null && finalImageUrl.startsWith('http'))
          'image': finalImageUrl,
      };

      // --- NUCLEAR STRATEGY PLAN ---
      // 1. PATCH /superadmin/:id (Standard partial update)
      // 2. PUT /superadmin/:id with EVERYTHING (Max ID keys)
      // 3. PATCH /profile (Role-neutral JWT update)
      // 4. PUT /superadmin/:id with wrapped 'admin' object (re-verified)
      // 5. PUT /superadmin/:id with ID in QUERY params

      Map<String, dynamic>? updatedData;
      final dio = await AuthService.getWorkingDio();

      // Variations of ID keys
      final allIdKeys = {
        'id': _userId,
        '_id': _userId,
        'userId': _userId,
        'adminId': _userId,
        'admin_id': _userId,
        'superadminId': _userId,
        'superadmin_id': _userId,
        'ID': _userId,
        'UID': _userId,
        'uId': _userId,
      };

      final profileWithAllIds = Map<String, dynamic>.from(cleanProfileData)
        ..addAll(allIdKeys);

      // --- STRATEGY 1: PATCH /superadmin/:id (Partial update convention) ---
      try {
        print(
          '🔄 Strategy 1: Attempting PATCH /superadmin/$_userId (Clean Body)...',
        );
        updatedData = await AdminService.patchAdminProfile(
          _userId!,
          cleanProfileData,
        );
      } catch (e1) {
        print('⚠️ Strategy 1 (PATCH) Failed: $e1');

        // --- STRATEGY 2: PUT /superadmin/:id (All IDs in body) ---
        try {
          print(
            '🔄 Strategy 2: Attempting PUT /superadmin/$_userId (All Possible ID Keys)...',
          );
          updatedData = await AdminService.updateAdminProfile(
            _userId!,
            profileWithAllIds,
          );
        } catch (e2) {
          print('⚠️ Strategy 2 (Max IDs) Failed: $e2');

          // --- STRATEGY 3: PATCH /profile (JWT-based role-neutral) ---
          try {
            print('🔄 Strategy 3: Attempting PATCH /profile (JWT-based)...');
            final patchResponse = await dio.patch(
              AppConfig.profileEndpoint,
              data: cleanProfileData,
            );
            if (patchResponse.statusCode == 200 ||
                patchResponse.statusCode == 204) {
              print('✅ Strategy 3 Succeeded!');
              final rData = patchResponse.data;
              updatedData = rData is Map ? (rData['data'] ?? rData) : {};
            } else {
              throw Exception('Status: ${patchResponse.statusCode}');
            }
          } catch (e3) {
            print('⚠️ Strategy 3 (PATCH /profile) Failed: $e3');

            // --- STRATEGY 4: Wrapped Object Strategy (PUT) ---
            try {
              print(
                '🔄 Strategy 4: Attempting Wrapped Admin Strategy (id + admin object)...',
              );
              final wrappedData = {
                ...allIdKeys,
                'admin': cleanProfileData,
                'data': cleanProfileData,
                'profile': cleanProfileData,
              };
              updatedData = await AdminService.updateAdminProfile(
                _userId!,
                wrappedData,
              );
            } catch (e4) {
              print('⚠️ Strategy 4 (Wrapped) Failed: $e4');

              // --- STRATEGY 5: ID in Query Params ---
              try {
                print(
                  '🔄 Strategy 5: Attempting PUT with ID in query params...',
                );
                final queryUrl =
                    '/superadmin/$_userId?id=$_userId&adminId=$_userId';
                print('🔄 PUT $queryUrl');
                final response = await dio.put(
                  queryUrl,
                  data: cleanProfileData,
                );
                if (response.statusCode == 200 || response.statusCode == 204) {
                  print('✅ Strategy 5 Succeeded!');
                  final rData = response.data;
                  updatedData = rData is Map ? (rData['data'] ?? rData) : {};
                } else {
                  throw Exception('Status: ${response.statusCode}');
                }
              } catch (e5) {
                print('⚠️ Strategy 5 (Query Params) Failed: $e5');

                // --- STRATEGY 6: Final Fallback (/complete-profile as POST) ---
                try {
                  print('🔄 Strategy 6: Attempting POST /complete-profile...');
                  final response = await dio.post(
                    AppConfig.completeProfileEndpoint,
                    data: profileWithAllIds,
                  );
                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    print('✅ Strategy 6 Succeeded!');
                    final rData = response.data;
                    updatedData = rData is Map
                        ? (rData['data'] ?? rData['user'] ?? rData)
                        : {};
                  } else {
                    throw Exception('Status: ${response.statusCode}');
                  }
                } catch (e6) {
                  print('❌ All strategies failed.');
                  throw Exception(
                    'All 6 update strategies failed. Latest Error (S6): $e6',
                  );
                }
              }
            }
          }
        }
      }

      if (updatedData == null) {
        throw Exception('No data returned from any update strategy');
      }

      // Update local state with response
      if (updatedData['firstName'] != null)
        _firstName = updatedData['firstName'] ?? '';
      if (updatedData['lastName'] != null)
        _lastName = updatedData['lastName'] ?? '';
      if (updatedData['email'] != null) _email = updatedData['email'] ?? '';
      if (updatedData['phone'] != null) _phone = updatedData['phone'] ?? '';
      if (updatedData['image'] != null) _imageUrl = updatedData['image'];

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
    } catch (e) {
      debugPrint('Error saving profile: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set user ID (should be called after login)
  Future<void> setUserId(String id) async {
    _userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    notifyListeners();
  }
}
