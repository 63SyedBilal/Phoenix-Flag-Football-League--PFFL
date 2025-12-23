import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

class StatKeeperDashboardProvider extends ChangeNotifier {
  // User information
  String _userName = 'Stat Keeper';
  bool _hasNotification = true;

  // Upcoming games
  List<GameModel> _upcomingGames = [];

  // Loading state
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get userName => _userName;
  bool get hasNotification => _hasNotification;
  List<GameModel> get upcomingGames => _upcomingGames;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StatKeeperDashboardProvider() {
    _initializeData();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _initializeData() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId') ?? '';

      if (currentUserId.isEmpty) {
        debugPrint('⚠️ No userId found in SharedPreferences');
        _errorMessage = 'User ID not found. Please login again.';
        _upcomingGames = [];
        _setLoading(false);
        return;
      }

      debugPrint('🔄 Fetching matches assigned to stat keeper: $currentUserId');

      // Use Repository to get assigned matches (it handles filtering securely)
      // This includes all assigned matches regardless of status (Upcoming, Live, Completed)
      // We want to show them all in the "Assigned Games" section usually,
      // or at least Upcoming + Live.

      // We'll fetch ALL matches to populate both lists if needed,
      // but Repository is best for "Assigned" specifically.
      // However, the UI expects a single list `_upcomingGames` and filters `isMyGame`.
      // So fetch all from MatchService to get the big list, but ensure parsing is robust.

      final allMatches = await MatchService.getAllMatches();

      // Filter for display
      final relevantMatches = allMatches.where((match) {
        // Show if assigned to me AND status is COMPLETED (as per requirement)
        final isAssigned = match.statKeeperId == currentUserId;
        final isCompleted = match.status == MatchStatus.completed;

        // Also show upcoming/live games generally if they aren't assigned,
        // BUT the requirement says: "Statkeeper sees ONLY completed games assigned to them".
        // It also says "Do NOT show Upcoming games".
        // HOWEVER, the dashboard usually has two sections: "Assigned" and "Upcoming".
        // If "Assigned Messages" means the "Assigned Games For You" section, we should filter that list.
        // But here `_upcomingGames` feeds the entire screen.
        // The HomeScreen filters `isMyGame` for the top section.

        // Let's adhere strictly to the "Statkeeper assigned games" requirement for the assigned list.
        // If the user wants to see *General* upcoming games (unassigned), the requirement says:
        // "Do NOT show: Upcoming games" (under Statkeeper assigned games section).

        // Interpretation:
        // 1. Assigned list must contain ONLY (Assigned + Completed).
        // 2. The variable `_upcomingGames` currently holds everything.
        // 3. I will make `_upcomingGames` hold robust data, but ensure `isMyGame` is only true if Completed.

        if (isAssigned) {
          return isCompleted;
        }

        // For general list (bottom section), usually we show upcoming matches.
        // The requirement "Do NOT show: Upcoming games" is under the "STATKEEPER ASSIGNED GAMES" header.
        // So unassigned upcoming games are likely still fine for the general list.
        return match.status == MatchStatus.upcoming ||
            match.status == MatchStatus.live;
      }).toList();

      // Sort by date (earliest first)
      relevantMatches.sort((a, b) {
        if (a.matchDateTime == null || b.matchDateTime == null) return 0;
        return a.matchDateTime!.compareTo(b.matchDateTime!);
      });

      // Convert MatchModel to GameModel
      _upcomingGames = relevantMatches
          .map((match) => _convertToGameModel(match, currentUserId))
          .toList();

      debugPrint('✅ Dashboard loaded with ${_upcomingGames.length} games');

      _errorMessage = null;
    } catch (e) {
      debugPrint('❌ Error fetching stat keeper matches: $e');
      _errorMessage = 'Failed to load assigned games: ${e.toString()}';
      _upcomingGames = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Convert MatchModel to GameModel for UI compatibility
  GameModel _convertToGameModel(MatchModel match, String currentUserId) {
    // Parse date from matchDateTime or from date string
    DateTime gameDate;
    if (match.matchDateTime != null) {
      gameDate = match.matchDateTime!;
    } else {
      // Try to parse date string (format: dd/MM)
      try {
        final parts = match.date.split('/');
        if (parts.length == 2) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final now = DateTime.now();
          gameDate = DateTime(now.year, month, day);
          // If date has passed this year, assume next year
          if (gameDate.isBefore(DateTime.now())) {
            gameDate = DateTime(now.year + 1, month, day);
          }
        } else {
          gameDate = DateTime.now();
        }
      } catch (e) {
        gameDate = DateTime.now();
      }
    }

    // Set isMyGame = true if statKeeperId matches current user ID
    final isAssigned =
        match.statKeeperId != null &&
        match.statKeeperId!.isNotEmpty &&
        match.statKeeperId == currentUserId;

    return GameModel(
      id: match.id ?? '',
      leagueName: match.leagueName,
      team1Name: match.homeTeam,
      team1Logo: match.homeTeamLogo.isNotEmpty ? match.homeTeamLogo : '',
      team2Name: match.awayTeam,
      team2Logo: match.awayTeamLogo.isNotEmpty ? match.awayTeamLogo : '',
      date: gameDate,
      time: match.time,
      isFeePaid: true, // Assume paid for now
      isMyGame: isAssigned, // Set based on statKeeperId matching current user
    );
  }

  /// Refresh data from backend
  Future<void> refreshData() async {
    await _initializeData();
  }

  void clearNotification() {
    _hasNotification = false;
    notifyListeners();
  }
}
