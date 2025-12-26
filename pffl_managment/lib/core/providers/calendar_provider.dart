import 'package:flutter/material.dart';

enum DateSelectionType { startDate, endDate }

class CalendarProvider extends ChangeNotifier {
  DateTime? _selectedDate;
  DateSelectionType _selectionType = DateSelectionType.startDate;
  DateTime? _minDate;
  String? _errorMessage;

  DateTime? get selectedDate => _selectedDate;
  DateSelectionType get selectionType => _selectionType;
  DateTime? get minDate => _minDate;
  String? get errorMessage => _errorMessage;

  void setSelectionType(
    DateSelectionType type,
    DateTime? initialDate, {
    DateTime? minDate,
  }) {
    _selectionType = type;
    _minDate = minDate;
    _errorMessage = null;
    _selectedDate = initialDate;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    if (_minDate != null && date.isBefore(_minDate!)) {
      _errorMessage = 'Date cannot be before ${_formatDate(_minDate!)}';
      notifyListeners();
      return;
    }

    _selectedDate = date;
    _errorMessage = null;
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool isDateSelectable(DateTime date) {
    if (_minDate == null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return !date.isBefore(today);
    }
    return !date.isBefore(_minDate!);
  }
}
