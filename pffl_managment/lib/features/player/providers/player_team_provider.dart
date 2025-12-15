import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/profile_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/features/captain/model/player_model.dart';
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
      final team5v5Base = TeamModel.fromJson(teamData, '5v5');
      final team7v7Base = TeamModel.fromJson(teamData, '7v7');

      // Fetch profiles for all players to get jersey numbers and positions
      final enrichedPlayers5v5 = await _enrichPlayersWithProfiles(team5v5Base.players);
      final enrichedPlayers7v7 = await _enrichPlayersWithProfiles(team7v7Base.players);

      // Create updated team models with enriched players
      final team5v5 = TeamModel(
        id: team5v5Base.id,
        name: team5v5Base.name,
        logoUrl: team5v5Base.logoUrl,
        format: '5v5',
        players: enrichedPlayers5v5,
        maxPlayers: 8,
      );

      final team7v7 = TeamModel(
        id: team7v7Base.id,
        name: team7v7Base.name,
        logoUrl: team7v7Base.logoUrl,
        format: '7v7',
        players: enrichedPlayers7v7,
        maxPlayers: 12,
      );

      _teams = {
        '5v5': team5v5,
        '7v7': team7v7,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load team data: ${e.toString()}';
      print('❌ Error loading team data: $e');
      notifyListeners();
    }
  }

  /// Fetch profiles for players to enrich with jersey numbers and positions
  Future<List<PlayerModel>> _enrichPlayersWithProfiles(List<PlayerModel> players) async {
    final enrichedPlayers = <PlayerModel>[];
    
    for (var player in players) {
      try {
        final profile = await ProfileService.getProfile(player.id);
        if (profile != null) {
          // Update player with profile data
          final jerseyNumber = profile['jerseyNumber']?.toString() ?? '';
          final position = profile['position']?.toString() ?? '';
          final image = profile['image']?.toString();
          
          // Parse position string (can be comma-separated)
          final positions = position.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          final primaryPosition = positions.isNotEmpty ? positions[0] : '';
          final additionalPositionsCount = positions.length > 1 ? positions.length - 1 : 0;
          
          // Create updated player model
          final updatedPlayer = PlayerModel(
            id: player.id,
            name: player.name,
            number: jerseyNumber,
            email: player.email,
            position: primaryPosition,
            isCaptain: player.isCaptain,
            imageUrl: image,
            isVerified: player.isVerified,
            hasAlert: player.hasAlert,
            isPaid: player.isPaid,
            additionalPositionsCount: additionalPositionsCount,
          );
          
          enrichedPlayers.add(updatedPlayer);
        } else {
          // No profile found, use original player data
          enrichedPlayers.add(player);
        }
      } catch (e) {
        print('⚠️ Error fetching profile for ${player.id}: $e');
        // Continue with original player data if profile fetch fails
        enrichedPlayers.add(player);
      }
    }
    
    return enrichedPlayers;
  }

  /// Refresh team data
  Future<void> refresh({String? userId}) async {
    await loadTeamData(userId: userId);
  }
}

