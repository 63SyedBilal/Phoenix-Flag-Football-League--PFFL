import 'package:flutter/material.dart';

enum MatchDetailsTab { summary, leaderboard, players, officials }

class CaptainMatchProvider extends ChangeNotifier {
  // Placeholder for match details data
  // In a real app, this would fetch data from an API or repository
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Selected tab for the match details screen
  MatchDetailsTab _selectedTab = MatchDetailsTab.summary;
  MatchDetailsTab get selectedTab => _selectedTab;

  void setTab(MatchDetailsTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // Helper to check if a specific tab is selected
  bool isTabSelected(MatchDetailsTab tab) => _selectedTab == tab;

  Future<void> loadMatchDetails(String matchId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }
}
