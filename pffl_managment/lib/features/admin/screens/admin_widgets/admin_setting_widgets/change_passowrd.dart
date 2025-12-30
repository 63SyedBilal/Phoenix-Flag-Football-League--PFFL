import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';

class ChangePassowrd extends StatefulWidget {
  const ChangePassowrd({super.key});

  @override
  State<ChangePassowrd> createState() => _ChangePassowrdState();
}

class _ChangePassowrdState extends State<ChangePassowrd> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // Validation
    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    if (current.length < 6) {
      _showSnackBar(
        'Current password must be at least 6 characters',
        Colors.red,
      );
      return;
    }

    if (newPass.length < 6) {
      _showSnackBar('New password must be at least 6 characters', Colors.red);
      return;
    }

    if (newPass != confirm) {
      _showSnackBar('New passwords do not match', Colors.red);
      return;
    }

    if (current == newPass) {
      _showSnackBar(
        'New password must be different from current password',
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.changePassword(current, newPass);

      if (success && mounted) {
        _showSnackBar('Password changed successfully', Colors.green);

        // Clear fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
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

        _showSnackBar(errorMessage, Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Update your password to keep your account secure.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 25),

              // Current Password
              Text(
                "Current Password",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _currentPasswordController,
                hintText: "Enter your current password",
                obscureText: _obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              const SizedBox(height: 18),

              // New Password
              Text(
                "New Password",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _newPasswordController,
                hintText: "Create a new password (min 6 characters)",
                obscureText: _obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              const SizedBox(height: 18),

              // Confirm Password
              Text(
                "Confirm New Password",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: "Re-enter new password",
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              CustomButton(
                width: double.infinity,
                text: _isLoading ? 'Saving...' : 'Save Changes',
                isLoading: _isLoading,
                onPressed: () {
                  _handleSave();
                },
                textColor: Colors.white,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

