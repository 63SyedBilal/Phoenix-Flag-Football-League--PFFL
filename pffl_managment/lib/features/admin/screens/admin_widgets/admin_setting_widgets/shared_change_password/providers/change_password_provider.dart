import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get isLoading => _isLoading;
  bool get obscureCurrent => _obscureCurrent;
  bool get obscureNew => _obscureNew;
  bool get obscureConfirm => _obscureConfirm;

  void toggleObscureCurrent() {
    _obscureCurrent = !_obscureCurrent;
    notifyListeners();
  }

  void toggleObscureNew() {
    _obscureNew = !_obscureNew;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  Future<void> handleSave(BuildContext context) async {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    // Validation
    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnackBar(context, 'Please fill all fields', Colors.red);
      return;
    }

    if (current.length < 6) {
      _showSnackBar(
        context,
        'Current password must be at least 6 characters',
        Colors.red,
      );
      return;
    }

    if (newPass.length < 6) {
      _showSnackBar(
        context,
        'New password must be at least 6 characters',
        Colors.red,
      );
      return;
    }

    if (newPass != confirm) {
      _showSnackBar(context, 'New passwords do not match', Colors.red);
      return;
    }

    if (current == newPass) {
      _showSnackBar(
        context,
        'New password must be different from current password',
        Colors.red,
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.changePassword(current, newPass);

      if (success) {
        _showSnackBar(context, 'Password changed successfully', Colors.green);

        // Clear fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle specific error messages
      if (errorMessage.contains('Current password is incorrect')) {
        errorMessage = 'Current password is incorrect';
      } else if (errorMessage.contains('Failed to connect')) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      } else if (errorMessage.contains('No token provided')) {
        errorMessage = 'Session expired. Please login again.';
      }

      _showSnackBar(context, errorMessage, Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
