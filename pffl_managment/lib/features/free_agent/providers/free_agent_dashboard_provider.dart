import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

/// Provider for Free Agent Dashboard
/// Fetches real upcoming games from backend API
class FreeAgentDashboardProvider extends ChangeNotifier {
  // User information
  String _userName = 'Free Agent';
  bool _hasNotification = true;

  // Upcoming games
  List<GameModel> _upcomingGames = [];

  // Loading and error state
  bool _isLoading = false;
  String? _error;

  // Getters
  String get userName => _userName;
  bool get hasNotification => _hasNotification;
  List<GameModel> get upcomingGames => _upcomingGames;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FreeAgentDashboardProvider() {
    _initializeData();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Initialize data by fetching real upcoming games
  Future<void> _initializeData() async {
    await fetchUpcomingGames();
  }

  /// Fetch real upcoming games from backend API
  /// Filters to show only today, tomorrow, and future games
  /// Sorts by nearest date/time first
  Future<void> fetchUpcomingGames() async {
    _setLoading(true);
    _error = null;

    try {
      
      // Fetch all matches from backend
      final allMatches = await MatchService.getAllMatches();

      // Filter and sort upcoming games
      final upcomingMatches = _filterUpcomingGames(allMatches);

      // Convert MatchModel to GameModel for UI
      _upcomingGames = upcomingMatches.map(_convertToGameModel).toList();
    } catch (e) {
      _error = 'Failed to load upcoming games';
      _upcomingGames = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Filter matches to show only upcoming games
  /// - Today's games
  /// - Tomorrow's games
  /// - Any future scheduled games
  /// Sorted by nearest date/time first
  List<MatchModel> _filterUpcomingGames(List<MatchModel> allMatches) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter for upcoming games only (today and future)
    final upcomingMatches = allMatches.where((match) {
      // Skip if no match date
      if (match.matchDateTime == null) return false;

      // Skip if match is completed or cancelled
      if (match.status == MatchStatus.completed ||
          match.status == MatchStatus.cancelled) {
        return false;
      }

      // Get match date (without time for date comparison)
      final matchDate = DateTime(
        match.matchDateTime!.year,
        match.matchDateTime!.month,
        match.matchDateTime!.day,
      );

      // Include if match is today or in the future
      return !matchDate.isBefore(today);
    }).toList();

    // Sort by nearest date/time first
    upcomingMatches.sort((a, b) {
      final dateA = a.matchDateTime ?? DateTime(2099);
      final dateB = b.matchDateTime ?? DateTime(2099);
      return dateA.compareTo(dateB);
    });

    return upcomingMatches;
  }

  /// Convert MatchModel to GameModel for UI compatibility
  GameModel _convertToGameModel(MatchModel match) {
    // Parse date from matchDateTime or fallback to date string
    DateTime gameDate;
    if (match.matchDateTime != null) {
      gameDate = match.matchDateTime!;
    } else {
      // Try to parse from date string (dd/MM format)
      try {
        final parts = match.date.split('/');
        if (parts.length == 2) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          gameDate = DateTime(DateTime.now().year, month, day);
        } else {
          gameDate = DateTime.now();
        }
      } catch (e) {
        gameDate = DateTime.now();
      }
    }

    // Format time for display
    String displayTime = match.time;
    if (displayTime.isEmpty && match.matchDateTime != null) {
      final hour = match.matchDateTime!.hour;
      final minute = match.matchDateTime!.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      displayTime = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }

    return GameModel(
      id: match.id ?? '',
      leagueName: match.leagueName,
      team1Name: match.homeTeam,
      team1Logo: match.homeTeamLogo.isNotEmpty 
          ? match.homeTeamLogo 
          : 'assets/images/default_team.png',
      team2Name: match.awayTeam,
      team2Logo: match.awayTeamLogo.isNotEmpty 
          ? match.awayTeamLogo 
          : 'assets/images/default_team.png',
      date: gameDate,
      time: displayTime,
      isFeePaid: true, // Default for free agent view
      isMyGame: false, // Free agents don't have "my game" status
    );
  }

  /// Refresh upcoming games data
  Future<void> refreshData() async {
    await fetchUpcomingGames();
  }

  /// Clear notification flag
  void clearNotification() {
    _hasNotification = false;
    notifyListeners();
  }
}

