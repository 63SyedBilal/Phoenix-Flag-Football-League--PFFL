import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';

class UnifiedGamesProvider extends ChangeNotifier {
  // SINGLE SOURCE OF TRUTH - All games in one list
  List<MatchModel> _allGames = [];
  bool _isLoading = false;
  String? _errorMessage;

  UnifiedGamesProvider() {
    _initializeData();
  }

  // Getters
  List<MatchModel> get allGames => List.unmodifiable(_allGames);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get upcoming games - future matches only, sorted by nearest date/time
  List<MatchModel> get upcomingGames {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter for upcoming matches (not completed or cancelled)
    final futureMatches = _allGames.where((game) {
      // Skip if match is completed or cancelled
      if (game.status == MatchStatus.completed ||
          game.status == MatchStatus.cancelled) {
        return false;
      }

      // If matchDateTime is null, still include if status is upcoming
      if (game.matchDateTime == null) {
        return game.status == MatchStatus.upcoming;
      }

      // Get match date (without time for date comparison)
      final matchDate = DateTime(
        game.matchDateTime!.year,
        game.matchDateTime!.month,
        game.matchDateTime!.day,
      );

      // Include if match is today or in the future, OR if status is upcoming (to catch games with date issues)
      final isTodayOrFuture = !matchDate.isBefore(today);

      // Include if status is upcoming (regardless of date for now, to debug)
      if (game.status == MatchStatus.upcoming) {
        return true;
      }

      return isTodayOrFuture;
    }).toList();

    // Sort by nearest date/time first
    futureMatches.sort((a, b) {
      final dateA = a.matchDateTime ?? DateTime(2099);
      final dateB = b.matchDateTime ?? DateTime(2099);
      return dateA.compareTo(dateB);
    });

    return futureMatches;
  }

  /// Get ONLY the next upcoming game for each league
  /// Requirement: Minimum match date >= current date per league
  List<MatchModel> get upcomingGamesPerLeague {
    final now = DateTime.now();
    // Use mid-day for "today" to avoid timezone/boundary issues if needed,
    // but here we just need to compare with 'now' or start of today.
    final today = DateTime(now.year, now.month, now.day);

    // 1. Filter matches that are today or in the future
    final futureMatches = _allGames.where((game) {
      if (game.matchDateTime == null) return false;

      // Get match date (without time for date comparison)
      final matchDate = DateTime(
        game.matchDateTime!.year,
        game.matchDateTime!.month,
        game.matchDateTime!.day,
      );

      // Requirement: Match date equal to or after current date
      return !matchDate.isBefore(today);
    }).toList();

    // 2. Sort by date/time ascending to pick the EARLIEST one first
    futureMatches.sort(
      (a, b) => (a.matchDateTime!).compareTo(b.matchDateTime!),
    );

    // 3. Group by League and pick only the FIRST (nearest) match for each
    final Map<String, MatchModel> leagueNextMatch = {};
    for (var match in futureMatches) {
      final key = match.leagueId ?? match.leagueName;
      if (!leagueNextMatch.containsKey(key)) {
        leagueNextMatch[key] = match;
      }
    }

    // 4. Return as a list, sorted by time
    final result = leagueNextMatch.values.toList();
    result.sort((a, b) => (a.matchDateTime!).compareTo(b.matchDateTime!));

    return result;
  }

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
  Future<bool> updateMatchDetails(
    String matchId,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedMatch = await MatchService.updateMatch(matchId, data);
      final index = _allGames.indexWhere((g) => g.id == matchId);
      if (index != -1) {
        _allGames[index] = updatedMatch;
        _sortGames();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update game: ${e.toString()}';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Admin-only: Update existing game (local only - deprecated or for internal use)
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

  /// Initialize data by fetching real upcoming games from backend
  Future<void> _initializeData() async {
    await fetchAllMatches();
  }

  /// Fetch all matches from backend API
  /// Filters to show only future matches
  /// Sorts by nearest date/time first
  Future<void> fetchAllMatches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch all matches from backend
      final allMatches = await MatchService.getAllMatches();

      _allGames = allMatches;
      _sortGames();
      _errorMessage = null;

      // Log error (consider using a logger or crash analytics in production)
    } catch (e) {
      if (e is DioException) {
        _errorMessage =
            'Failed to load matches: ${e.response?.data?['error'] ?? e.message ?? 'Unknown error'}';
      } else {
        _errorMessage = 'Failed to load matches: ${e.toString()}';
      }
      _allGames = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sort games by creation order (using id as proxy for creation time)
  // In MongoDB, ObjectIds contain timestamp, so sorting by id gives creation order
  void _sortGames() {
    _allGames.sort((a, b) {
      // Primary sort: by creation order (using id)
      if (a.id != null && b.id != null) {
        // MongoDB ObjectIds are sortable by creation time
        return a.id!.compareTo(b.id!);
      }
      // Fallback: if one has id and other doesn't, prioritize the one with id
      if (a.id != null) return -1;
      if (b.id != null) return 1;

      // Secondary fallback: use matchDateTime if available
      if (a.matchDateTime != null && b.matchDateTime != null) {
        return a.matchDateTime!.compareTo(b.matchDateTime!);
      }
      if (a.matchDateTime != null) return -1;
      if (b.matchDateTime != null) return 1;

      return 0;
    });
  }

  // Initialize with mock data (deprecated - use fetchAllMatches instead)
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
