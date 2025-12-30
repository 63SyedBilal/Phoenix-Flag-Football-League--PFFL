import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/core/services/upload_service.dart';
import 'dart:io';
import 'package:pffl_managment/features/captain/view/captain_create_team/providers/create_team_helpers.dart';

/// Provider for Captain Create Team screen state and business logic
class CreateTeamProvider extends ChangeNotifier {
  // Form fields
  String? _teamLogoPath;
  String? _teamLogoUrl;
  String? _teamName;
  String? _teamColor;
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
    return _teamLogoPath != null &&
        _teamLogoPath!.isNotEmpty &&
        _teamName != null &&
        _teamName!.isNotEmpty &&
        _teamColor != null &&
        _teamColor!.isNotEmpty &&
        _location != null &&
        _location!.isNotEmpty &&
        _skillLevel != null &&
        _skillLevel!.isNotEmpty &&
        _agreedToTerms &&
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
    if (name != null && name.isNotEmpty) {
      if (name.trim().length < 3) {
        _setFieldError('teamName', 'Team name must be at least 3 characters');
      } else if (name.trim().length > 50) {
        _setFieldError('teamName', 'Team name must be at most 50 characters');
      }
    }

    notifyListeners();
  }

  /// Set team color
  void setTeamColor(String? color) {
    _teamColor = color;
    _clearFieldError('teamColor');
    if (color == null || color.isEmpty) {
      _setFieldError('teamColor', 'Team color is required');
    }
    notifyListeners();
  }

  /// Set location and validate
  void setLocation(String? loc) {
    _location = loc;
    _clearFieldError('location');

    // Validate if provided
    if (loc != null && loc.isNotEmpty) {
      if (loc.trim().length < 2) {
        _setFieldError('location', 'Location is required');
      }
    }

    notifyListeners();
  }

  /// Set skill level
  void setSkillLevel(String? level) {
    _skillLevel = level;
    _showSkillDropdown = false;
    _clearFieldError('skillLevel');
    if (level == null || level.isEmpty) {
      _setFieldError('skillLevel', 'Skill level is required');
    }
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

  // Helper methods moved to CreateTeamHelpers to keep this provider file small.

  /// Validate entire form
  bool _validateForm() {
    _fieldErrors.clear();
    bool isValid = true;

    if (_teamLogoPath == null || _teamLogoPath!.isEmpty) {
      _setFieldError('teamLogo', 'Team logo is required');
      isValid = false;
    }

    // Team name validation
    if (_teamName == null || _teamName!.isEmpty) {
      _setFieldError('teamName', 'Team name is required');
      isValid = false;
    } else if (_teamName!.trim().length < 3) {
      _setFieldError('teamName', 'Team name must be at least 3 characters');
      isValid = false;
    } else if (_teamName!.trim().length > 50) {
      _setFieldError('teamName', 'Team name must be at most 50 characters');
      isValid = false;
    }

    if (_teamColor == null || _teamColor!.isEmpty) {
      _setFieldError('teamColor', 'Team color is required');
      isValid = false;
    }

    // Location validation
    if (_location == null || _location!.isEmpty) {
      _setFieldError('location', 'Location is required');
      isValid = false;
    }

    if (_skillLevel == null || _skillLevel!.isEmpty) {
      _setFieldError('skillLevel', 'Skill level is required');
      isValid = false;
    } else if (!skillLevels.contains(_skillLevel)) {
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
      // Upload logo (required)
      String? imageUrl;
      final imageFile = File(_teamLogoPath!);
      if (!await imageFile.exists()) {
        throw Exception('Selected logo could not be found');
      }
      final compressed = await CreateTeamHelpers.compressLogoIfNeeded(imageFile);
      imageUrl = await UploadService.uploadImage(
        compressed ?? imageFile,
        folder: 'pffl/teams',
      );
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Failed to upload team logo');
      }
      _teamLogoUrl = imageUrl;

      // Map skill level from UI to API format
      String? apiSkillLevel;
      if (_skillLevel != null && _skillLevel!.isNotEmpty) {
        apiSkillLevel = skillLevelMapping[_skillLevel] ?? 'beginner';
      }

      // Create team via API
      final created = await TeamService.createTeam(
        teamName: _teamName!,
        location: _location!,
        skillLevel: apiSkillLevel,
        imageUrl: imageUrl,
      );

      final teamId =
          created?['_id']?.toString() ?? created?['id']?.toString() ?? '';
      if (teamId.isNotEmpty) {
        await _userPrefs.setSelectedTeamId(teamId);
        await CreateTeamHelpers.linkCaptainToTeam(teamId);
      }

      // Update local cache
      await _userPrefs.setHasCreatedTeam(true);

      // Show success sheet
      _showSuccessSheet = true;
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

  /// Hide success sheet and prepare for navigation
  void hideSuccessSheet() {
    _showSuccessSheet = false;
    notifyListeners();
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

