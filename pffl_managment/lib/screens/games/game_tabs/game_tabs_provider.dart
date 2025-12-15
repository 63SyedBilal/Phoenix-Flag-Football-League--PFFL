import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

class GameTabsProvider extends ChangeNotifier {
  final MatchModel match;
  int _selectedTabIndex = 0;

  GameTabsProvider({required this.match});

  int get selectedTabIndex => _selectedTabIndex;

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  // Placeholder for tab data loading
  // In a real app, you might fetch specific data for each tab here
}
