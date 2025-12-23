import 'package:flutter/material.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';

class PlayerDashboardProvider extends ChangeNotifier {
  // User information
  String _userName = 'Player';
  bool _hasNotification = true;

  // Upcoming games
  List<GameModel> _upcomingGames = [];

  // Loading state
  bool _isLoading = false;

  // Getters
  String get userName => _userName;
  bool get hasNotification => _hasNotification;
  List<GameModel> get upcomingGames => _upcomingGames;
  bool get isLoading => _isLoading;

  PlayerDashboardProvider() {
    _initializeData();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _initializeData() async {
    _setLoading(true);
    try {
      // 1. Get current user's team
      final teamData = await TeamService.getTeamByCaptain();
      if (teamData == null) {
        _upcomingGames = [];
        return;
      }

      final teamId = teamData['_id']?.toString() ?? teamData['id']?.toString();
      if (teamId == null) {
        _upcomingGames = [];
        return;
      }

      // 2. Get all matches
      final allMatches = await MatchService.getAllMatches();

      // 3. Filter matches for this team
      final now = DateTime.now();
      final myMatches = allMatches.where((m) {
        final isMyTeam = m.homeTeamId == teamId || m.awayTeamId == teamId;
        final isFuture =
            m.matchDateTime != null && m.matchDateTime!.isAfter(now);
        // Also consider 'upcoming' status just in case date is today but later time,
        // though isAfter works for time too if matchDateTime includes time.
        return isMyTeam && isFuture;
      }).toList();

      // 4. Sort by date
      myMatches.sort(
        (a, b) => (a.matchDateTime ?? DateTime(2100)).compareTo(
          b.matchDateTime ?? DateTime(2100),
        ),
      );

      // 5. Map to GameModel
      _upcomingGames = myMatches
          .map(
            (m) => GameModel(
              id: m.id ?? '',
              leagueName: m.leagueName,
              team1Name: m.homeTeam,
              team1Logo: m.homeTeamLogo,
              team2Name: m.awayTeam,
              team2Logo: m.awayTeamLogo,
              date: m.matchDateTime ?? DateTime.now(),
              time: m.time,
              isFeePaid: true, // Assuming true or logic unavailable
              isMyGame: true,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error loading player dashboard data: $e');
      _upcomingGames = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData() async {
    await _initializeData();
  }

  void clearNotification() {
    _hasNotification = false;
    notifyListeners();
  }
}
