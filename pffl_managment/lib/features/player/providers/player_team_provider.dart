import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/features/captain/model/team_model.dart';

/// Provider for managing player's team state
/// Fetches team where player is a member (in squad5v5 or squad7v7)
class PlayerTeamProvider extends ChangeNotifier {
  Map<String, TeamModel> _teams = {};
  String _selectedFormat = '5v5';
  bool _isLoading = false;
  String? _errorMessage;

  TeamModel? get team => _teams[_selectedFormat];
  String get selectedFormat => _selectedFormat;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PlayerTeamProvider() {
    // Don't auto-load - wait for userId to be provided
  }

  void setFormat(String format) {
    if (_selectedFormat != format) {
      _selectedFormat = format;
      notifyListeners();
    }
  }

  /// Load team data for the current player
  /// Requires AuthProvider context to get userId
  Future<void> loadTeamData({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // If userId not provided, we need to get it from context
      // This method should be called with userId from AuthProvider
      if (userId == null) {
        _errorMessage = 'User ID not available';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch team data from API
      final teamData = await TeamService.getTeamByPlayer(userId);

      if (teamData == null) {
        // No team found - this is a valid empty state, not an error
        _teams = {};
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Create TeamModel for both formats
      // The team API returns players with profileImage, jerseyNumber, position populated
      print('🔍 [TEAM DEBUG] Raw team data: $teamData');

      final team5v5 = TeamModel.fromJson(teamData, '5v5');
      final team7v7 = TeamModel.fromJson(teamData, '7v7');

      // Log the team data to verify profile images are present
      print('🔍 [TEAM DEBUG] Team 5v5 players (${team5v5.players.length}):');
      for (var player in team5v5.players) {
        print(
          '  - ${player.name}: image="${player.imageUrl}", jersey="${player.number}", position="${player.position}"',
        );
      }

      print('🔍 [TEAM DEBUG] Team 7v7 players (${team7v7.players.length}):');
      for (var player in team7v7.players) {
        print(
          '  - ${player.name}: image="${player.imageUrl}", jersey="${player.number}", position="${player.position}"',
        );
      }

      _teams = {'5v5': team5v5, '7v7': team7v7};

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load team data: ${e.toString()}';
      print('❌ Error loading team data: $e');
      notifyListeners();
    }
  }

  /// Refresh team data
  Future<void> refresh({String? userId}) async {
    await loadTeamData(userId: userId);
  }
}
