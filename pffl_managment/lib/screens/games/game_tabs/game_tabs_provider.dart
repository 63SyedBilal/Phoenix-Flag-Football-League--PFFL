import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

class GameTabsProvider extends ChangeNotifier {
  final MatchModel match;
  int _selectedTabIndex = 0;

  List<MatchModel> _upcomingGames = [];
  bool _isLoading = false;

  GameTabsProvider({required this.match});

  int get selectedTabIndex => _selectedTabIndex;
  List<MatchModel> get upcomingGames => _upcomingGames;
  bool get isLoading => _isLoading;

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch all matches to find upcoming ones for these teams
      // Ideally this would be an API call like /match?teamId=...
      final allMatches = await MatchService.getAllMatches();

      final now = DateTime.now();
      final teamIds = {
        match.homeTeamId,
        match.awayTeamId,
      }.whereType<String>().toSet();

      if (teamIds.isNotEmpty) {
        final related = allMatches.where((m) {
          if (m.id == match.id) return false; // Exclude current match
          if (m.status == MatchStatus.completed) return false;

          // Check if it involves either team
          final hasTeam =
              (m.homeTeamId != null && teamIds.contains(m.homeTeamId)) ||
              (m.awayTeamId != null && teamIds.contains(m.awayTeamId));

          // Check if future or strictly upcoming status
          final isFuture =
              (m.matchDateTime != null && m.matchDateTime!.isAfter(now)) ||
              m.status == MatchStatus.upcoming;

          return hasTeam && isFuture;
        }).toList();

        // Sort by date ascending
        related.sort((a, b) {
          final da = a.matchDateTime ?? DateTime(2100);
          final db = b.matchDateTime ?? DateTime(2100);
          return da.compareTo(db);
        });

        _upcomingGames = related.take(5).toList();
      }
    } catch (e) {
      print('Error loading upcoming games: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
