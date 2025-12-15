import 'package:flutter/material.dart';

class CaptainSettingsProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Simulate logout delay
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();

    // In a real app, you would clear auth state and navigate to login
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    }
  }
}
