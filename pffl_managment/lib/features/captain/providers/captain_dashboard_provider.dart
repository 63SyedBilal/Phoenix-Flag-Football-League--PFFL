import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

class CaptainDashboardProvider extends ChangeNotifier {
  // User information
  String _userName = 'John';
  bool _hasNotification = true;

  // Payment information
  bool _isPaymentCardExpanded = false;
  final String _paymentAmount = '\$250';
  final String _paymentSubtitle = 'League Fee Due';
  final String _leagueTitle = 'Champions Cup 2025';
  final String _leagueFormat = '5v5';
  final String _leagueStartDate = '10 December 2025';
  final String _leagueEndDate = '25 February 2026';

  // Next game
  GameModel? _nextGame;

  // Upcoming games
  List<GameModel> _upcomingGames = [];

  // Getters
  String get userName => _userName;
  bool get hasNotification => _hasNotification;
  bool get isPaymentCardExpanded => _isPaymentCardExpanded;
  String get paymentAmount => _paymentAmount;
  String get paymentSubtitle => _paymentSubtitle;
  String get leagueTitle => _leagueTitle;
  String get leagueFormat => _leagueFormat;
  String get leagueStartDate => _leagueStartDate;
  String get leagueEndDate => _leagueEndDate;
  GameModel? get nextGame => _nextGame;
  List<GameModel> get upcomingGames => _upcomingGames;

  CaptainDashboardProvider() {
    _initializeData();
  }

  /// Initialize data by fetching real upcoming games from backend
  Future<void> _initializeData() async {
    await fetchUpcomingGames();
  }

  /// Fetch real upcoming games from backend API
  /// Filters to show only future matches
  /// Sorts by nearest date/time first
  Future<void> fetchUpcomingGames() async {
    try {
      debugPrint('🎮 Fetching upcoming games from backend...');
      
      // Fetch all matches from backend
      final allMatches = await MatchService.getAllMatches();
      debugPrint('📊 Total matches fetched: ${allMatches.length}');

      // Filter and sort upcoming games
      final upcomingMatches = _filterUpcomingGames(allMatches);
      debugPrint('📊 Upcoming games after filter: ${upcomingMatches.length}');

      // Convert MatchModel to GameModel for UI
      _upcomingGames = upcomingMatches.map(_convertToGameModel).toList();

      // Set next game (first game where isMyGame is true, or first game if none)
      _nextGame = _upcomingGames.firstWhere(
        (game) => game.isMyGame,
        orElse: () => _upcomingGames.isNotEmpty ? _upcomingGames.first : GameModel(
          id: '',
          leagueName: '',
          team1Name: '',
          team1Logo: '',
          team2Name: '',
          team2Logo: '',
          date: DateTime.now(),
          time: '',
          isFeePaid: false,
          isMyGame: false,
        ),
      );

      // If we got a default empty GameModel, set nextGame to null
      if (_nextGame != null && _nextGame!.id.isEmpty) {
        _nextGame = null;
      }

      debugPrint('✅ Upcoming games loaded: ${_upcomingGames.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching upcoming games: $e');
      _upcomingGames = [];
      _nextGame = null;
      notifyListeners();
    }
  }

  /// Filter matches to show only upcoming games
  /// - Future matches only (scheduled to happen in the future)
  /// Sorted by nearest date/time first
  List<MatchModel> _filterUpcomingGames(List<MatchModel> allMatches) {
    final now = DateTime.now();

    // Filter for upcoming games only (future matches)
    final upcomingMatches = allMatches.where((match) {
      // Skip if no match date
      if (match.matchDateTime == null) return false;

      // Skip if match is completed or cancelled
      if (match.status == MatchStatus.completed ||
          match.status == MatchStatus.cancelled) {
        return false;
      }

      // Include only if match is in the future
      return match.matchDateTime!.isAfter(now);
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
    // Parse date from matchDateTime
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

    // Determine if this is "my game" - check if match involves captain's team
    // For now, we'll set it to false (can be enhanced to check against captain's team)
    final isMyGame = false;

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
      isFeePaid: true, // Default for captain view
      isMyGame: isMyGame,
    );
  }

  /// Refresh upcoming games data
  Future<void> refreshData() async {
    await fetchUpcomingGames();
  }

  void togglePaymentCardExpansion() {
    _isPaymentCardExpanded = !_isPaymentCardExpanded;
    notifyListeners();
  }

  void handlePayNow() {
    // Handle payment logic here
    notifyListeners();
  }

  void clearNotification() {
    _hasNotification = false;
    notifyListeners();
  }
}