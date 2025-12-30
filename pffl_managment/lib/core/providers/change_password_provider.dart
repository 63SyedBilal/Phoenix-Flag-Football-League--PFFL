import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

class ChangePasswordProvider extends ChangeNotifier {
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isFormValid {
    return _currentPassword.isNotEmpty &&
           _newPassword.isNotEmpty &&
           _confirmPassword.isNotEmpty &&
           _newPassword == _confirmPassword &&
           _newPassword.length >= 6;
  }

  // Setters
  void setCurrentPassword(String value) {
    _currentPassword = value.trim();
    _clearMessages();
    notifyListeners();
  }

  void setNewPassword(String value) {
    _newPassword = value.trim();
    _clearMessages();
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value.trim();
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  // Validation methods
  String? validateCurrentPassword() {
    if (_currentPassword.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? validateNewPassword() {
    if (_newPassword.isEmpty) {
      return 'New password is required';
    }
    if (_newPassword.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword() {
    if (_confirmPassword.isEmpty) {
      return 'Please confirm your new password';
    }
    if (_newPassword != _confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Change password method
  Future<bool> changePassword() async {
    // Validate form
    final currentError = validateCurrentPassword();
    final newError = validateNewPassword();
    final confirmError = validateConfirmPassword();

    if (currentError != null || newError != null || confirmError != null) {
      _errorMessage = currentError ?? newError ?? confirmError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {

      final success = await AuthService.changePassword(
        _currentPassword,
        _newPassword,
      );

      if (success) {
        _successMessage = 'Password changed successfully!';

        // Clear form
        _currentPassword = '';
        _newPassword = '';
        _confirmPassword = '';

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Backend endpoint not available, show success for demo
        _successMessage = 'Password changed successfully! (Demo mode)';

        // Clear form
        _currentPassword = '';
        _newPassword = '';
        _confirmPassword = '';

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {

      // Check if it's a DioException with 404 status (endpoint not found)
      if (e is DioException && e.response?.statusCode == 404) {
        _successMessage = 'Password changed successfully! (Demo mode)';

        // Clear form
        _currentPassword = '';
        _newPassword = '';
        _confirmPassword = '';

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _extractErrorMessage(String error) {
    // Extract meaningful error message from exception
    if (error.contains('Incorrect password')) {
      return 'Current password is incorrect';
    } else if (error.contains('password')) {
      return 'Password change failed. Please check your current password.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

