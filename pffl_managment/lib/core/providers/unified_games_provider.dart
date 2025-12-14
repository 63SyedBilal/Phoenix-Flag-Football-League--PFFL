import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';

class UnifiedGamesProvider extends ChangeNotifier {
  // SINGLE SOURCE OF TRUTH - All games in one list
  List<MatchModel> _allGames = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MatchModel> get allGames => List.unmodifiable(_allGames);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MatchModel> get upcomingGames =>
      _allGames.where((game) => game.status == MatchStatus.upcoming).toList();

  List<MatchModel> get liveGames =>
      _allGames.where((game) => game.status == MatchStatus.live).toList();

  List<MatchModel> get completedGames =>
      _allGames.where((game) => game.status == MatchStatus.completed).toList();

  // Filter by date
  List<MatchModel> getGamesByDate(DateTime date) {
    return _allGames.where((game) {
      if (game.matchDateTime == null) return false;
      return game.matchDateTime!.year == date.year &&
          game.matchDateTime!.month == date.month &&
          game.matchDateTime!.day == date.day;
    }).toList();
  }

  // Filter by status
  List<MatchModel> getGamesByStatus(MatchStatus status) {
    return _allGames.where((game) => game.status == status).toList();
  }

  /// Fetch games for a specific league from backend
  Future<void> fetchGamesForLeague(String leagueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final matches = await MatchService.getMatchesByLeague(leagueId);
      _allGames = matches;
      _sortGames();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load games: ${e.toString()}';
      debugPrint('Error fetching games: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh games for a league
  Future<void> refreshGamesForLeague(String leagueId) async {
    await fetchGamesForLeague(leagueId);
  }

  // Admin-only: Add new game (syncs with backend)
  void addGame(MatchModel game) {
    _allGames.add(game);
    _sortGames();
    notifyListeners();
  }

  // Admin-only: Update existing game (syncs with backend)
  void updateGame(String gameId, MatchModel updatedGame) {
    final index = _allGames.indexWhere((g) => g.id == gameId);
    if (index != -1) {
      _allGames[index] = updatedGame;
      _sortGames();
      notifyListeners();
    }
  }

  // Admin-only: Delete game
  void deleteGame(String gameId) {
    _allGames.removeWhere((g) => g.id == gameId);
    notifyListeners();
  }

  // Sort games by stage priority, then by date/time
  void _sortGames() {
    final stagePriority = {
      'Final': 1,
      'Semi-Final': 2,
      'Quarter-Final': 3,
      'Group Stage': 4,
    };

    _allGames.sort((a, b) {
      // First sort by stage priority
      final aStage = a.roundName ?? 'Group Stage';
      final bStage = b.roundName ?? 'Group Stage';
      final aPriority = stagePriority[aStage] ?? 99;
      final bPriority = stagePriority[bStage] ?? 99;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      // Then sort by date/time within same stage
      if (a.matchDateTime != null && b.matchDateTime != null) {
        return a.matchDateTime!.compareTo(b.matchDateTime!);
      }
      if (a.matchDateTime != null) return -1;
      if (b.matchDateTime != null) return 1;
      return 0;
    });
  }

  // Initialize with mock data
  void loadMockGames() {
    _allGames = [
      MatchModel(
        id: '1',
        leagueName: 'Phoenix Flag Football League',
        homeTeam: 'RC',
        homeTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=RC&backgroundColor=db1f35',
        awayTeam: 'STA',
        awayTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=STA&backgroundColor=f59e0b',
        date: '08/11',
        time: '01:05 AM PKT',
        status: MatchStatus.upcoming,
        matchDateTime: DateTime(2025, 12, 11, 1, 5),
      ),
      MatchModel(
        id: '2',
        leagueName: 'Six Nations',
        homeTeam: 'GEO',
        homeTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=GEO&backgroundColor=3b82f6',
        awayTeam: 'STB',
        awayTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=STB&backgroundColor=10b981',
        date: '08/11',
        time: '02:15 AM PKT',
        status: MatchStatus.upcoming,
        matchDateTime: DateTime(2025, 12, 11, 2, 15),
      ),
      MatchModel(
        id: '3',
        leagueName: 'World Cup Qualifiers',
        homeTeam: 'WQ',
        homeTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=WQ&backgroundColor=db1f35',
        awayTeam: 'STC',
        awayTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=STC&backgroundColor=f59e0b',
        date: '08/11',
        time: '03:30 AM PKT',
        status: MatchStatus.upcoming,
        matchDateTime: DateTime(2025, 12, 11, 3, 30),
      ),
      MatchModel(
        id: '4',
        leagueName: 'Champions League',
        homeTeam: 'MAN',
        homeTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=MAN&backgroundColor=db1f35',
        awayTeam: 'CHE',
        awayTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=CHE&backgroundColor=3b82f6',
        date: '09/11',
        time: '04:00 PM PKT',
        status: MatchStatus.upcoming,
        matchDateTime: DateTime(2025, 12, 12, 16, 0),
      ),
      MatchModel(
        id: '5',
        leagueName: 'Premier League',
        homeTeam: 'ARS',
        homeTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=ARS&backgroundColor=db1f35',
        awayTeam: 'LIV',
        awayTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=LIV&backgroundColor=db1f35',
        date: '10/11',
        time: '06:30 PM PKT',
        status: MatchStatus.live,
        matchDateTime: DateTime(2025, 12, 13, 18, 30),
      ),
      MatchModel(
        id: '6',
        leagueName: 'La Liga',
        homeTeam: 'BAR',
        homeTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=BAR&backgroundColor=3b82f6',
        awayTeam: 'MAD',
        awayTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=MAD&backgroundColor=f59e0b',
        date: '05/11',
        time: '08:00 PM PKT',
        status: MatchStatus.completed,
        matchDateTime: DateTime(2025, 12, 8, 20, 0),
        homeScore: 3,
        awayScore: 1,
      ),
      MatchModel(
        id: '7',
        leagueName: 'Serie A',
        homeTeam: 'JUV',
        homeTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=JUV&backgroundColor=10b981',
        awayTeam: 'MIL',
        awayTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=MIL&backgroundColor=db1f35',
        date: '06/11',
        time: '09:00 PM PKT',
        status: MatchStatus.completed,
        matchDateTime: DateTime(2025, 12, 9, 21, 0),
        homeScore: 2,
        awayScore: 2,
      ),
      MatchModel(
        id: '8',
        leagueName: 'Bundesliga',
        homeTeam: 'BAY',
        homeTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=BAY&backgroundColor=db1f35',
        awayTeam: 'DOR',
        awayTeamLogo:
            'https://api.dicebear.com/7.x/shapes/png?seed=DOR&backgroundColor=f59e0b',
        date: '11/11',
        time: '10:00 PM PKT',
        status: MatchStatus.upcoming,
        matchDateTime: DateTime(2025, 12, 14, 22, 0),
      ),
    ];
    _sortGames();
    notifyListeners();
  }
}
