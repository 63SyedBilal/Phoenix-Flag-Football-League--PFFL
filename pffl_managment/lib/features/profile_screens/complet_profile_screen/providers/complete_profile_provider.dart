import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/profile_service.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'dart:io';

/// Provider for Complete Profile screen state and business logic
class CompleteProfileProvider extends ChangeNotifier {
  // Form fields
  final List<String> _selectedPositions = [];
  String? _jerseyNumber;
  String? _emergencyContactName;
  String? _emergencyPhone;
  String? _profileImagePath;
  String? _profileImageUrl;
  
  // UI state
  bool _isLoading = false;
  bool _showPositionDropdown = false;
  bool _showSuccessSheet = false;
  bool _agreedToTerms = false;
  String? _errorMessage;
  
  // Validation state
  final Map<String, String?> _fieldErrors = {};
  
  // Getters
  List<String> get selectedPositions => List.unmodifiable(_selectedPositions);
  String get positionsDisplayText {
    if (_selectedPositions.isEmpty) {
      return 'Select positions (e.g. Rusher, Blocker)';
    }
    return _selectedPositions.join(', ');
  }
  String? get jerseyNumber => _jerseyNumber;
  String? get emergencyContactName => _emergencyContactName;
  String? get emergencyPhone => _emergencyPhone;
  String? get profileImagePath => _profileImagePath;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;
  bool get showPositionDropdown => _showPositionDropdown;
  bool get showSuccessSheet => _showSuccessSheet;
  bool get agreedToTerms => _agreedToTerms;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);
  
  /// Check if form is valid
  bool get isFormValid {
    return _selectedPositions.isNotEmpty &&
        _emergencyContactName != null &&
        _emergencyContactName!.isNotEmpty &&
        _emergencyPhone != null &&
        _emergencyPhone!.isNotEmpty &&
        _agreedToTerms &&
        _fieldErrors.isEmpty;
  }
  
  /// Initialize provider - check if profile already exists
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        print('⚠️ No userId found in SharedPreferences');
        return;
      }
      
      // Check SharedPreferences first
      final isCompleted = prefs.getBool('profile_completed_$userId');
      if (isCompleted == true) {
        print('✅ Profile already completed (from SharedPreferences)');
        return;
      }
      
      // Check API if not in SharedPreferences
      final profile = await ProfileService.getProfile(userId);
      if (profile != null) {
        // Profile exists, mark as completed
        await prefs.setBool('profile_completed_$userId', true);
        print('✅ Profile already exists (from API)');
      }
    } catch (e) {
      print('❌ Error initializing provider: $e');
      // Don't throw - allow user to proceed with form
    }
  }
  
  /// Toggle position selection (add if not selected, remove if selected)
  void togglePosition(String position) {
    if (_selectedPositions.contains(position)) {
      _selectedPositions.remove(position);
    } else {
      _selectedPositions.add(position);
    }
    _clearFieldError('position');
    notifyListeners();
  }
  
  /// Check if position is selected
  bool isPositionSelected(String position) {
    return _selectedPositions.contains(position);
  }
  
  /// Set jersey number and validate
  void setJerseyNumber(String? number) {
    _jerseyNumber = number;
    _clearFieldError('jerseyNumber');
    
    // Validate if provided
    if (number != null && number.isNotEmpty) {
      final jerseyNum = int.tryParse(number);
      if (jerseyNum == null || jerseyNum < 1 || jerseyNum > 99) {
        _setFieldError('jerseyNumber', 'Jersey number must be between 1 and 99');
      }
    }
    
    notifyListeners();
  }
  
  /// Set emergency contact name and validate
  void setEmergencyContactName(String? name) {
    _emergencyContactName = name;
    _clearFieldError('emergencyContactName');
    
    // Validate if provided
    if (name != null && name.isNotEmpty && name.length < 2) {
      _setFieldError('emergencyContactName', 'Name must be at least 2 characters');
    }
    
    notifyListeners();
  }
  
  /// Set emergency phone (from CustomPhoneField)
  void setEmergencyPhone(String? phone) {
    _emergencyPhone = phone;
    _clearFieldError('emergencyPhone');
    
    // Basic validation
    if (phone != null && phone.isNotEmpty) {
      // Remove spaces and check if it's a valid phone format
      final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
      if (cleaned.length < 10) {
        _setFieldError('emergencyPhone', 'Please enter a valid phone number');
      }
    }
    
    notifyListeners();
  }
  
  /// Set profile image path
  void setProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }
  
  /// Toggle position dropdown
  void togglePositionDropdown() {
    _showPositionDropdown = !_showPositionDropdown;
    notifyListeners();
  }
  
  /// Toggle terms agreement
  void toggleTermsAgreement(bool? value) {
    _agreedToTerms = value ?? false;
    notifyListeners();
  }
  
  /// Validate entire form
  bool _validateForm() {
    _fieldErrors.clear();
    bool isValid = true;
    
    // Position validation - at least one position must be selected
    if (_selectedPositions.isEmpty) {
      _setFieldError('position', 'Please select at least one position');
      isValid = false;
    }
    
    // Jersey number validation (optional but must be valid if provided)
    if (_jerseyNumber != null && _jerseyNumber!.isNotEmpty) {
      final jerseyNum = int.tryParse(_jerseyNumber!);
      if (jerseyNum == null || jerseyNum < 1 || jerseyNum > 99) {
        _setFieldError('jerseyNumber', 'Jersey number must be between 1 and 99');
        isValid = false;
      }
    }
    
    // Emergency contact name validation
    if (_emergencyContactName == null || _emergencyContactName!.isEmpty) {
      _setFieldError('emergencyContactName', 'Emergency contact name is required');
      isValid = false;
    } else if (_emergencyContactName!.length < 2) {
      _setFieldError('emergencyContactName', 'Name must be at least 2 characters');
      isValid = false;
    }
    
    // Emergency phone validation
    if (_emergencyPhone == null || _emergencyPhone!.isEmpty) {
      _setFieldError('emergencyPhone', 'Emergency phone number is required');
      isValid = false;
    } else {
      final cleaned = _emergencyPhone!.replaceAll(RegExp(r'\s+'), '');
      if (cleaned.length < 10) {
        _setFieldError('emergencyPhone', 'Please enter a valid phone number');
        isValid = false;
      }
    }
    
    // Terms agreement validation
    if (!_agreedToTerms) {
      _setFieldError('terms', 'You must agree to Terms & Privacy');
      isValid = false;
    }
    
    notifyListeners();
    return isValid;
  }
  
  /// Submit profile to backend
  Future<bool> submitProfile() async {
    // Validate form
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
            print('✅ Image uploaded: $imageUrl');
          }
        } catch (e) {
          print('⚠️ Image upload failed: $e');
          // Continue without image - it's optional
        }
      }
      
      // Prepare profile data
      // Convert selected positions list to comma-separated string for backend
      final positionString = _selectedPositions.join(', ');
      final profileData = <String, dynamic>{
        'position': positionString,
        'emergencyNumber': _emergencyContactName!,
        'emergencyPhoneNumber': _emergencyPhone!,
        'yearOfExperience': 0,
        'paymentStatus': 'unpaid',
      };
      
      // Add optional fields
      if (_jerseyNumber != null && _jerseyNumber!.isNotEmpty) {
        final jerseyNum = int.tryParse(_jerseyNumber!);
        if (jerseyNum != null) {
          profileData['jerseyNumber'] = jerseyNum;
        }
      }
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        profileData['image'] = imageUrl;
      }
      
      // Create profile via API
      await ProfileService.createProfile(profileData);
      
      // Save completion status to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null) {
        await prefs.setBool('profile_completed_$userId', true);
        print('✅ Profile completion saved to SharedPreferences');
      }
      
      // Show success sheet
      _showSuccessSheet = true;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('❌ Error submitting profile: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Hide success sheet and prepare for navigation
  void hideSuccessSheet() {
    _showSuccessSheet = false;
    notifyListeners();
  }
  
  /// Static method to check if profile is completed
  static Future<bool> checkProfileCompletion(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check SharedPreferences first
      final isCompleted = prefs.getBool('profile_completed_$userId');
      if (isCompleted == true) {
        return true;
      }
      
      // Check API
      final profile = await ProfileService.getProfile(userId);
      if (profile != null) {
        // Save to SharedPreferences for future checks
        await prefs.setBool('profile_completed_$userId', true);
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error checking profile completion: $e');
      return false;
    }
  }
  
  /// Set field error
  void _setFieldError(String field, String error) {
    _fieldErrors[field] = error;
  }
  
  /// Clear field error
  void _clearFieldError(String field) {
    _fieldErrors.remove(field);
  }
  
  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}

