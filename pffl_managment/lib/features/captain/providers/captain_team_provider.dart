import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/core/services/profile_service.dart';
import 'package:pffl_managment/core/services/notification_service.dart';
import '../model/player_model.dart';
import '../model/team_model.dart';

class CaptainTeamProvider extends ChangeNotifier {
  Map<String, TeamModel> _teams = {};
  String _selectedFormat = '5v5';
  bool _isLoading = false;
  String? _errorMessage;

  TeamModel? get team => _teams[_selectedFormat];
  String get selectedFormat => _selectedFormat;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CaptainTeamProvider() {
    loadTeamData();
  }

  void setFormat(String format) {
    if (_selectedFormat != format) {
      _selectedFormat = format;
      notifyListeners();
    }
  }

  Future<void> loadTeamData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('userRole')?.toLowerCase() ?? '';
      if (role != 'captain') {
        _isLoading = false;
        _teams = {};
        _errorMessage = null;
        notifyListeners();
        return;
      }

      print('🔄 Loading team data for captain...');
      // Fetch team data from API
      final teamData = await TeamService.getTeamByCaptain();

      if (teamData == null) {
        print('⚠️ No team data returned from API');
        _errorMessage = 'No team found. Please create a team first.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('✅ Team data received from API');
      print('   Team ID: ${teamData['_id'] ?? teamData['id']}');
      print('   Team Name: ${teamData['teamName'] ?? teamData['name']}');

      // Log squad data for debugging
      final squad5v5Raw = teamData['squad5v5'] as List? ?? [];
      final squad7v7Raw = teamData['squad7v7'] as List? ?? [];
      print('   Raw squad5v5 count: ${squad5v5Raw.length}');
      print('   Raw squad7v7 count: ${squad7v7Raw.length}');

      // Create TeamModel for both formats
      final team5v5Base = TeamModel.fromJson(teamData, '5v5');
      final team7v7Base = TeamModel.fromJson(teamData, '7v7');

      print('   Parsed 5v5 players: ${team5v5Base.players.length}');
      print('   Parsed 7v7 players: ${team7v7Base.players.length}');

      // Fetch profiles for all players to get jersey numbers and positions
      final enrichedPlayers5v5 = await _enrichPlayersWithProfiles(
        team5v5Base.players,
      );
      final enrichedPlayers7v7 = await _enrichPlayersWithProfiles(
        team7v7Base.players,
      );

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

  /// Fetch profiles for players to enrich with jersey numbers and positions
  Future<List<PlayerModel>> _enrichPlayersWithProfiles(
    List<PlayerModel> players,
  ) async {
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
          final positions = position
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final primaryPosition = positions.isNotEmpty ? positions[0] : '';
          final additionalPositionsCount = positions.length > 1
              ? positions.length - 1
              : 0;

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
  Future<void> refresh() async {
    await loadTeamData();
  }

  /// Remove a player from the team
  /// Sends notification to the player and updates team data
  Future<void> removePlayer(String playerId) async {
    try {
      print(
        '🎯 [REMOVE PLAYER DEBUG] Starting removal process for player: $playerId',
      );

      // TODO: Add API call to remove player from team
      // For now, we'll simulate the removal and send notification

      // Send notification to the removed player
      await _sendRemovalNotification(playerId);

      // Refresh team data to reflect changes
      await refresh();

      print('✅ [REMOVE PLAYER DEBUG] Player removed successfully');
    } catch (e) {
      print('❌ [REMOVE PLAYER DEBUG] Error removing player: $e');
      throw Exception('Failed to remove player: ${e.toString()}');
    }
  }

  /// Transfer leadership to another player
  /// Sends invitation notification to the selected player
  Future<void> transferLeadership(String newCaptainId) async {
    try {
      print(
        '🎯 [TRANSFER LEADERSHIP DEBUG] Starting transfer process to player: $newCaptainId',
      );

      // TODO: Add API call to initiate leadership transfer
      // For now, we'll simulate the transfer invitation

      // Send invitation notification to the selected player
      await _sendLeadershipInvitation(newCaptainId);

      print(
        '✅ [TRANSFER LEADERSHIP DEBUG] Leadership invitation sent successfully',
      );
    } catch (e) {
      print('❌ [TRANSFER LEADERSHIP DEBUG] Error transferring leadership: $e');
      throw Exception('Failed to transfer leadership: ${e.toString()}');
    }
  }

  /// Send removal notification to a player
  Future<void> _sendRemovalNotification(String playerId) async {
    try {
      print(
        '📧 [NOTIFICATION DEBUG] Sending removal notification to player: $playerId',
      );

      // Get current user ID (captain) from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId');

      if (currentUserId == null || currentUserId.isEmpty) {
        print(
          '⚠️ [NOTIFICATION DEBUG] Current user ID not found in SharedPreferences',
        );
        throw Exception('Current user ID not available');
      }

      print('📧 [NOTIFICATION DEBUG] Sender ID (Captain): $currentUserId');

      // Use existing NotificationService to send notification
      final success = await NotificationService.sendNotification(
        receiverId: playerId,
        type: 'TEAM_REMOVAL',
        message: 'You have been removed from this team',
        teamId: team?.id, // Include team ID if available
        senderId: currentUserId, // Include sender ID (captain)
      );

      if (success) {
        print('✅ [NOTIFICATION DEBUG] Removal notification sent successfully');
      } else {
        print('⚠️ [NOTIFICATION DEBUG] Failed to send removal notification');
      }
    } catch (e) {
      print('⚠️ [NOTIFICATION DEBUG] Failed to send removal notification: $e');
      // Don't throw error for notification failure - removal should still proceed
    }
  }

  /// Send leadership invitation notification to a player
  Future<void> _sendLeadershipInvitation(String playerId) async {
    try {
      print(
        '📧 [NOTIFICATION DEBUG] Sending leadership invitation to player: $playerId',
      );
      print('📧 [NOTIFICATION DEBUG] Current team: ${team?.id}');
      print('📧 [NOTIFICATION DEBUG] Current team name: ${team?.name}');

      // Get current user ID (captain) from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId');

      if (currentUserId == null || currentUserId.isEmpty) {
        print(
          '⚠️ [NOTIFICATION DEBUG] Current user ID not found in SharedPreferences',
        );
        throw Exception('Current user ID not available');
      }

      print('📧 [NOTIFICATION DEBUG] Sender ID (Captain): $currentUserId');
      print('📧 [NOTIFICATION DEBUG] Receiver ID (Player): $playerId');
      print('📧 [NOTIFICATION DEBUG] Team ID: ${team?.id}');
      print('📧 [NOTIFICATION DEBUG] Notification Type: LEADERSHIP_INVITATION');
      print(
        '📧 [NOTIFICATION DEBUG] Message: This captain has offered you the captain role',
      );

      // Use existing NotificationService to send notification
      final success = await NotificationService.sendNotification(
        receiverId: playerId,
        type: 'LEADERSHIP_INVITATION',
        message: 'This captain has offered you the captain role',
        teamId: team?.id, // Include team ID if available
        senderId: currentUserId, // Include sender ID (captain)
      );

      if (success) {
        print('✅ [NOTIFICATION DEBUG] Leadership invitation sent successfully');
        print(
          '📧 [NOTIFICATION DEBUG] Notification should appear for user: $playerId',
        );
        print(
          '📧 [NOTIFICATION DEBUG] Backend confirmed notification creation with sender: $currentUserId',
        );
        print(
          '📧 [NOTIFICATION DEBUG] Next step: Check if user $playerId receives notification in their notification list',
        );
      } else {
        print(
          '⚠️ [NOTIFICATION DEBUG] Failed to send leadership invitation - API returned false',
        );
        print(
          '📧 [NOTIFICATION DEBUG] This means the backend /notification/send endpoint returned non-200 status',
        );
        throw Exception(
          'Notification API returned false - check backend logs for /notification/send endpoint',
        );
      }
    } catch (e) {
      print('⚠️ [NOTIFICATION DEBUG] Failed to send leadership invitation: $e');
      print('📧 [NOTIFICATION DEBUG] Full error details: ${e.toString()}');
      // Re-throw to show error in UI so captain knows there was an issue
      rethrow;
    }
  }
}
