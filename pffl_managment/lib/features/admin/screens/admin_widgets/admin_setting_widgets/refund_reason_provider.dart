import 'package:flutter/material.dart';

class RefundReasonProvider with ChangeNotifier {
  List<String> _refundReasons = [
    'Duplicate payment',
    'Player withdrawal',
    'Administrative error',
    'Other'
  ];
  
  String _selectedReason = 'Other';
  
  List<String> get refundReasons => _refundReasons;
  String get selectedReason => _selectedReason;
  
  void setSelectedReason(String reason) {
    _selectedReason = reason;
    notifyListeners();
  }
}