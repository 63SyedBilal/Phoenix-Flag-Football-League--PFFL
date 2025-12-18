import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/admin_service.dart';

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
  String? _adminId;

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

      // Get admin ID from SharedPreferences (stored during login)
      final prefs = await SharedPreferences.getInstance();
      _adminId = prefs.getString('userId');
      
      if (_adminId == null) {
        debugPrint('Warning: Admin ID not found. Profile update may fail.');
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final uploadedUrl = await AdminService.uploadImage(_selectedImageFile!);
      
      if (uploadedUrl != null) {
        _imageUrl = uploadedUrl;
        _selectedImageFile = null; // Clear selected file after upload
        _isLoading = false;
        notifyListeners();
        return uploadedUrl;
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Save profile to backend
  Future<bool> saveProfile() async {
    if (_adminId == null) {
      _errorMessage = 'Admin ID not found. Please login again.';
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
        final uploadedUrl = await uploadImage();
        if (uploadedUrl == null) {
          _isLoading = false;
          notifyListeners();
          return false; // Upload failed
        }
        finalImageUrl = uploadedUrl;
      }

      // Prepare profile data
      final profileData = <String, dynamic>{
        'email': _email,
        if (_firstName.isNotEmpty) 'firstName': _firstName,
        if (_lastName.isNotEmpty) 'lastName': _lastName,
        if (_phone.isNotEmpty) 'phone': _phone,
        if (finalImageUrl != null) 'image': finalImageUrl,
      };

      // Update profile via API
      final updatedData = await AdminService.updateAdminProfile(_adminId!, profileData);

      if (updatedData != null) {
        // Update local state with response
        if (updatedData['firstName'] != null) _firstName = updatedData['firstName'] ?? '';
        if (updatedData['lastName'] != null) _lastName = updatedData['lastName'] ?? '';
        if (updatedData['email'] != null) _email = updatedData['email'] ?? '';
        if (updatedData['phone'] != null) _phone = updatedData['phone'] ?? '';
        if (updatedData['image'] != null) _imageUrl = updatedData['image'];

        // Save to SharedPreferences for persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_firstName', _firstName);
        await prefs.setString('admin_lastName', _lastName);
        await prefs.setString('admin_email', _email);
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

      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error saving profile: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set admin ID (should be called after login)
  Future<void> setAdminId(String id) async {
    _adminId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
  }
}
