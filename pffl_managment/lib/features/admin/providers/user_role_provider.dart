import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/services/user_service.dart';

/// Provider for managing User Role updates
class UserRoleProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  /// Update the role of a user
  /// We use InviteService.sendInvite because the direct update endpoint is failing with 404
  /// and the invite endpoint handles both new and existing users correctly.
  Future<bool> changeUserRole(
    String userId,
    String email,
    String newRole,
  ) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Use InviteService as it works for existing users too (re-invite with new role)
      // Map UI role to backend role format if needed
      String backendRole = newRole.toLowerCase();
      if (backendRole == 'stat keeper' || backendRole == 'statkeeper') {
        backendRole = 'stat-keeper';
      }

      final success = await InviteService.sendInvite(email, backendRole);

      if (success) {
        _successMessage = 'User role updated successfully to $newRole';
      } else {
        _error = 'Failed to update user role';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('Error in UserRoleProvider: $e');
      _error = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
