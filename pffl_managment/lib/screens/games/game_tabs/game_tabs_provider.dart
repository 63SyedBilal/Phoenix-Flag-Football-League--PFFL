import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

class GameTabsProvider extends ChangeNotifier {
  final MatchModel match;
  int _selectedTabIndex = 0;

  List<MatchModel> _upcomingGames = [];
  bool _isLoading = false;

  Map<String, dynamic>? _homeTeamDetails;
  Map<String, dynamic>? _awayTeamDetails;

  GameTabsProvider({required this.match});

  int get selectedTabIndex => _selectedTabIndex;
  List<MatchModel> get upcomingGames => _upcomingGames;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? get homeTeamDetails => _homeTeamDetails;
  Map<String, dynamic>? get awayTeamDetails => _awayTeamDetails;

  final Set<String> _expandedPlayerIds = {};
  bool isPlayerExpanded(String id) => _expandedPlayerIds.contains(id);

  void togglePlayerExpansion(String id) {
    if (_expandedPlayerIds.contains(id)) {
      _expandedPlayerIds.remove(id);
    } else {
      _expandedPlayerIds.add(id);
    }
    notifyListeners();
  }

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
      // Fetch team details
      if (match.homeTeamId != null && match.homeTeamId!.isNotEmpty) {
        _homeTeamDetails = await TeamService.getTeamById(match.homeTeamId!);
      }
      if (match.awayTeamId != null && match.awayTeamId!.isNotEmpty) {
        _awayTeamDetails = await TeamService.getTeamById(match.awayTeamId!);
      }

      // Fetch all matches to find upcoming ones for these teams
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

