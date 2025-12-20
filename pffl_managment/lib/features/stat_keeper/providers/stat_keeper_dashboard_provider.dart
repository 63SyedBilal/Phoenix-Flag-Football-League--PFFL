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
      
      // Fetch all matches from backend
      final allMatches = await MatchService.getAllMatches();
      
      // Filter to only matches assigned to this stat keeper
      final assignedMatches = allMatches.where((match) {
        return match.statKeeperId != null && 
               match.statKeeperId!.isNotEmpty &&
               match.statKeeperId == currentUserId;
      }).toList();
      
      debugPrint('✅ Found ${assignedMatches.length} matches assigned to stat keeper');
      
      // Filter to only upcoming matches
      final upcomingMatches = assignedMatches.where(
        (match) => match.status == MatchStatus.upcoming && match.matchDateTime != null,
      ).toList();
      
      // Sort by date (earliest first)
      upcomingMatches.sort((a, b) {
        if (a.matchDateTime == null || b.matchDateTime == null) return 0;
        return a.matchDateTime!.compareTo(b.matchDateTime!);
      });
      
      // Convert MatchModel to GameModel
      _upcomingGames = upcomingMatches.map((match) => _convertToGameModel(match, currentUserId)).toList();
      
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
    final isAssigned = match.statKeeperId != null && 
                       match.statKeeperId!.isNotEmpty &&
                       match.statKeeperId == currentUserId;
    
    return GameModel(
      id: match.id ?? '',
      leagueName: match.leagueName,
      team1Name: match.homeTeam,
      team1Logo: match.homeTeamLogo.isNotEmpty 
          ? match.homeTeamLogo 
          : '',
      team2Name: match.awayTeam,
      team2Logo: match.awayTeamLogo.isNotEmpty 
          ? match.awayTeamLogo 
          : '',
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