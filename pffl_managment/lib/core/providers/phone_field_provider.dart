import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Provider for managing phone field state
class PhoneFieldProvider extends ChangeNotifier {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  PhoneNumber? _currentPhoneNumber;
  bool _isFocused = false;
  bool _isValid = false;
  String _countryCode = 'US';
  String _countryISOCode = 'US';

  // Callbacks
  ValueChanged<PhoneNumber>? onInputChanged;
  ValueChanged<bool>? onInputValidated;

  PhoneFieldProvider({PhoneNumber? initialValue}) {
    _focusNode = FocusNode();
    _controller = TextEditingController();
    if (initialValue != null) {
      _currentPhoneNumber = initialValue;
      _countryCode = initialValue.countryCode;
      _countryISOCode = initialValue.countryISOCode;
      _controller.text = initialValue.number;
    }
    _focusNode.addListener(_onFocusChange);
  }

  // Getters
  FocusNode get focusNode => _focusNode;
  TextEditingController get controller => _controller;
  PhoneNumber? get currentPhoneNumber => _currentPhoneNumber;
  bool get isFocused => _isFocused;
  bool get isValid => _isValid;
  String get countryCode => _countryCode;
  String get countryISOCode => _countryISOCode;

  /// Handle focus changes
  void _onFocusChange() {
    _isFocused = _focusNode.hasFocus;
    notifyListeners();
  }

  /// Handle phone number input changes (country or number)
  void handleInputChanged(PhoneNumber number) {
    final previousCountry = _countryISOCode;
    final newCountry = number.countryISOCode;
    final countryChanged = previousCountry != newCountry;

    // Update current phone number
    _currentPhoneNumber = number;
    _countryCode = number.countryCode;
    _countryISOCode = number.countryISOCode;

    // Debug logging

    // Notify listeners to rebuild UI
    notifyListeners();

    // Call external callback if provided
    onInputChanged?.call(number);
  }

  /// Handle phone number validation
  void handleInputValidated(bool isValid) {
    _isValid = isValid;
    notifyListeners();
    onInputValidated?.call(isValid);
  }

  /// Update initial value (called when widget updates)
  void updateInitialValue(PhoneNumber? initialValue) {
    if (initialValue != null) {
      _currentPhoneNumber = initialValue;
      _countryCode = initialValue.countryCode;
      _countryISOCode = initialValue.countryISOCode;
      _controller.text = initialValue.number;
      notifyListeners();
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}

