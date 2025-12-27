import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/core/services/notification_service.dart';
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
      // Fetch team data from API (backend already populates profile data)
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

      // Backend already populates profileImage, jerseyNumber, position
      // So we can directly use TeamModel.fromJson without additional enrichment
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
