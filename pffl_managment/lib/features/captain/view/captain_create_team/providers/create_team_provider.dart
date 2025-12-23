import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'dart:io';

/// Provider for Captain Create Team screen state and business logic
class CreateTeamProvider extends ChangeNotifier {
  // Form fields
  String? _teamLogoPath;
  String? _teamLogoUrl;
  String? _teamName;
  String? _teamColor; // Optional field (not sent to API)
  bool _agreedToTerms = false;
  String? _location;
  String? _skillLevel;

  // UI state
  bool _isLoading = false;
  bool _showSkillDropdown = false;
  bool _showSuccessSheet = false;
  String? _errorMessage;
  final UserPreferenceProvider _userPrefs;

  CreateTeamProvider(this._userPrefs);

  // Validation state
  final Map<String, String?> _fieldErrors = {};

  // Skill level options (UI) -> API mapping
  static const List<String> skillLevels = [
    'Recreational',
    'Intermediate',
    'Competitive',
    'Complete',
  ];

  static const Map<String, String> skillLevelMapping = {
    'Recreational': 'beginner',
    'Intermediate': 'intermediate',
    'Competitive': 'advanced',
    'Complete': 'advanced',
  };

  // Getters
  String? get teamLogoPath => _teamLogoPath;
  String? get teamLogoUrl => _teamLogoUrl;
  String? get teamName => _teamName;
  String? get teamColor => _teamColor;
  String? get location => _location;
  String? get skillLevel => _skillLevel;
  bool get isLoading => _isLoading;
  bool get showSkillDropdown => _showSkillDropdown;
  bool get showSuccessSheet => _showSuccessSheet;
  bool get agreedToTerms => _agreedToTerms;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);

  /// Check if form is valid
  bool get isFormValid {
    return _teamName != null &&
        _teamName!.isNotEmpty &&
        _location != null &&
        _location!.isNotEmpty &&
        _fieldErrors.isEmpty;
  }

  /// Set team logo path
  void setTeamLogo(String? path) {
    _teamLogoPath = path;
    _clearFieldError('teamLogo');
    notifyListeners();
  }

  /// Set team name and validate
  void setTeamName(String? name) {
    _teamName = name;
    _clearFieldError('teamName');

    // Validate if provided
    if (name != null && name.isNotEmpty && name.length < 2) {
      _setFieldError('teamName', 'Team name must be at least 2 characters');
    }

    notifyListeners();
  }

  /// Set team color (optional, not sent to API)
  void setTeamColor(String? color) {
    _teamColor = color;
    notifyListeners();
  }

  /// Set location and validate
  void setLocation(String? loc) {
    _location = loc;
    _clearFieldError('location');

    // Validate if provided
    if (loc != null && loc.isNotEmpty && loc.length < 5) {
      _setFieldError('location', 'Location must be at least 5 characters');
    }

    notifyListeners();
  }

  /// Set skill level
  void setSkillLevel(String? level) {
    _skillLevel = level;
    _showSkillDropdown = false;
    _clearFieldError('skillLevel');
    notifyListeners();
  }

  /// Toggle skill dropdown
  void toggleSkillDropdown() {
    _showSkillDropdown = !_showSkillDropdown;
    notifyListeners();
  }

  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    _clearFieldError('terms');
    notifyListeners();
  }

  /// Validate entire form
  bool _validateForm() {
    _fieldErrors.clear();
    bool isValid = true;

    // Team name validation
    if (_teamName == null || _teamName!.isEmpty) {
      _setFieldError('teamName', 'Team name is required');
      isValid = false;
    } else if (_teamName!.length < 2) {
      _setFieldError('teamName', 'Team name must be at least 2 characters');
      isValid = false;
    }

    // Location validation
    if (_location == null || _location!.isEmpty) {
      _setFieldError('location', 'Location is required');
      isValid = false;
    } else if (_location!.length < 5) {
      _setFieldError('location', 'Location must be at least 5 characters');
      isValid = false;
    }

    // Skill level is optional, but if provided, validate it's in the list
    if (_skillLevel != null &&
        _skillLevel!.isNotEmpty &&
        !skillLevels.contains(_skillLevel)) {
      _setFieldError('skillLevel', 'Invalid skill level');
      isValid = false;
    }

    // Terms and Privacy validation
    if (!_agreedToTerms) {
      _setFieldError('terms', 'You must agree to Terms & Privacy');
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  /// Submit team to backend
  Future<bool> submitTeam() async {
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
      // Upload logo if provided
      String? imageUrl;
      if (_teamLogoPath != null && _teamLogoPath!.isNotEmpty) {
        try {
          final imageFile = File(_teamLogoPath!);
          if (await imageFile.exists()) {
            imageUrl = await AdminService.uploadImage(imageFile);
            _teamLogoUrl = imageUrl;
            print('✅ Team logo uploaded: $imageUrl');
          }
        } catch (e) {
          print('⚠️ Team logo upload failed: $e');
          // Continue without logo - it's optional
        }
      }

      // Map skill level from UI to API format
      String? apiSkillLevel;
      if (_skillLevel != null && _skillLevel!.isNotEmpty) {
        apiSkillLevel = skillLevelMapping[_skillLevel] ?? 'beginner';
      }

      // Create team via API
      await TeamService.createTeam(
        teamName: _teamName!,
        location: _location!,
        skillLevel: apiSkillLevel,
        imageUrl: imageUrl,
      );

      // Update local cache
      await _userPrefs.setHasCreatedTeam(true);
      print('✅ Team creation saved to local cache');

      // Show success sheet
      _showSuccessSheet = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('❌ Error submitting team: $e');
      notifyListeners();
      return false;
    }
  }

  /// Hide success sheet and prepare for navigation
  void hideSuccessSheet() {
    _showSuccessSheet = false;
    notifyListeners();
  }

  /// Static method to check if team is created (now uses UserPreferenceProvider if possible)
  static Future<bool> checkTeamCreation(
    UserPreferenceProvider userPrefs,
  ) async {
    try {
      // Check local cache first
      if (userPrefs.hasCreatedTeam) {
        return true;
      }

      // Check API
      final hasTeam = await TeamService.hasTeam();
      if (hasTeam) {
        // Save to local cache for future checks
        await userPrefs.setHasCreatedTeam(true);
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error checking team creation: $e');
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
