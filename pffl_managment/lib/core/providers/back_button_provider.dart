import 'package:flutter/material.dart';

/// Provider to manage Android back button double-press exit logic.
class BackButtonProvider with ChangeNotifier {
  DateTime? _lastBackPressTime;

  /// Duration within which double-tap should occur to allow exit.
  static const Duration _exitDuration = Duration(seconds: 2);

  /// Handles the back press logic.
  /// Returns `true` if the app should close, `false` if it should show a message.
  bool handleBackPress() {
    final now = DateTime.now();

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > _exitDuration) {
      // First press or press after duration
      _lastBackPressTime = now;
      notifyListeners();
      return false; // Prevent closing
    }

    // Second press within duration
    return true; // Allow closing
  }

  /// Resets the back press time (useful when navigating away manually).
  void reset() {
    _lastBackPressTime = null;
    notifyListeners();
  }
}
