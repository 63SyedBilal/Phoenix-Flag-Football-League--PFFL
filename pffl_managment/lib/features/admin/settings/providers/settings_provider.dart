import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  // Notification settings
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  // Theme settings
  bool _darkMode = false;

  // Privacy settings
  bool _shareData = false;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  bool get darkMode => _darkMode;
  bool get shareData => _shareData;

  // Setters with notifyListeners
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
  }

  void setPushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setShareData(bool value) {
    _shareData = value;
    notifyListeners();
  }
}
