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
  Map<String, bool> _playerPaymentStatuses = {}; // playerId -> isPaid

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
      // Fetch team data from API (backend already populates profile data)
      final teamData = await TeamService.getTeamByCaptain();

      if (teamData == null) {
        _errorMessage = 'No team found. Please create a team first.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Log squad data for debugging
      final squad5v5Raw = teamData['squad5v5'] as List? ?? [];
      final squad7v7Raw = teamData['squad7v7'] as List? ?? [];

      // Backend already populates profileImage, jerseyNumber, position
      // So we can directly use TeamModel.fromJson without additional enrichment

      final team5v5 = TeamModel.fromJson(teamData, '5v5');
      final team7v7 = TeamModel.fromJson(teamData, '7v7');

      // Log the team data to verify profile images are present
      for (var player in team5v5.players) {
        print(
          '  - ${player.name}: image="${player.imageUrl}", jersey="${player.number}", position="${player.position}"',
        );
      }
      for (var player in team7v7.players) {
        print(
          '  - ${player.name}: image="${player.imageUrl}", jersey="${player.number}", position="${player.position}"',
        );
      }

      _teams = {'5v5': team5v5, '7v7': team7v7};

      // Load payment statuses after team data is loaded
      await loadPlayerPaymentStatuses();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load team data: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Refresh team data
  Future<void> refresh() async {
    await loadTeamData();
  }

  /// Load player payment statuses for the current team
  Future<void> loadPlayerPaymentStatuses() async {
    final currentTeam = team;
    if (currentTeam == null) {
      return;
    }

    try {
      final response = await TeamService.getTeamPlayerPayments(currentTeam.id);

      if (response['success'] == true && response['data'] != null) {
        final paymentStatuses = response['data']['paymentStatuses'] as Map<String, dynamic>? ?? {};
        _playerPaymentStatuses = paymentStatuses.map((key, value) => MapEntry(key, value == true));
        notifyListeners();
      } else {
      }
    } catch (e) {
    }
  }

  /// Get payment status for a specific player
  bool getPlayerPaymentStatus(String playerId) {
    return _playerPaymentStatuses[playerId] ?? false;
  }

  /// Check if payment statuses are loaded
  bool get hasPaymentStatuses => _playerPaymentStatuses.isNotEmpty;

  /// Transfer leadership to another player
  /// Calls API, updates local state, and sends notification to new captain
  Future<void> transferLeadership(BuildContext context, String newCaptainId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentTeam = team;
      if (currentTeam == null || currentTeam.id.isEmpty) {
        throw Exception('No team found. Cannot transfer leadership.');
      }

      // 1. Validate that newCaptainId is a player in the current team
      final newCaptainPlayer = currentTeam.players.firstWhere(
        (player) => player.id == newCaptainId,
        orElse: () => throw Exception('Selected player is not a member of your team.'),
      );

      // Confirmation dialog (UI will handle this, but provider prepares data)
      // The UI will call this method after user confirms in a dialog.

      // 2. Call API to transfer leadership
      final success = await TeamService.transferLeadership(
        teamId: currentTeam.id,
        newCaptainId: newCaptainId,
      );

      if (!success) {
        throw Exception('Backend failed to transfer leadership.');
      }

      // 3. On success, update the local TeamModel
      await _updateLocalTeamAfterLeadershipTransfer(newCaptainId);

      // 4. Send notification to new captain (and email if implemented)
      await _sendLeadershipConfirmation(
          newCaptainId, newCaptainPlayer.name);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to transfer leadership: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
      rethrow; // Re-throw to show error in UI
    }
  }

  /// Updates the local TeamModel after a successful leadership transfer API call.
  Future<void> _updateLocalTeamAfterLeadershipTransfer(String newCaptainId) async {
    final currentTeam = team;
    if (currentTeam == null) return;

    // Fetch the profile of the new captain to get their full name if needed
    // (CaptainTeamProvider now has PlayerModel for full name)
    final newCaptainPlayer = currentTeam.players.firstWhere(
      (player) => player.id == newCaptainId,
      orElse: () => throw Exception('New captain not found in local team roster.'),
    );

    final newCaptainName = newCaptainPlayer.name;

    // Create a new list of players with updated isCaptain status
    final updatedPlayers = currentTeam.players.map((player) {
      if (player.id == newCaptainId) {
        return player.copyWith(isCaptain: true); // New captain
      } else if (player.isCaptain) {
        return player.copyWith(isCaptain: false); // Old captain becomes regular player
      }
      return player;
    }).toList();

    // Create a new TeamModel with the updated captain information
    final updatedTeam = currentTeam.copyWith(
      players: updatedPlayers,
      captainId: newCaptainId,
      captainName: newCaptainName,
    );

    // Update the _teams map for the current format
    _teams[_selectedFormat] = updatedTeam;
  }

  // Renamed and modified from _sendLeadershipInvitation
  /// Send leadership confirmation notification to the new captain
  Future<void> _sendLeadershipConfirmation(String newCaptainId, String newCaptainName) async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId');

      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('Current user ID not available');
      }

      final message = 'You are now the captain of team "${team?.name ?? 'your team'}".';

      final success = await NotificationService.sendNotification(
        receiverId: newCaptainId,
        type: 'LEADERSHIP_TRANSFER_CONFIRMATION', // New notification type
        message: message,
        teamId: team?.id,
        senderId: currentUserId, // Old captain as sender
      );

      if (success) {
      } else {
      }
    } catch (e) {
      // Don't re-throw, as the leadership transfer itself was successful
    }
  }

  /// Remove a player from the team
  /// Calls API, updates local state, and sends notification to the removed player
  Future<void> removePlayer(BuildContext context, String playerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentTeam = team;
      if (currentTeam == null || currentTeam.id.isEmpty) {
        throw Exception('No team found. Cannot remove player.');
      }

      // 1. Call API to remove player from team
      final success = await TeamService.removePlayerFromTeam(
        teamId: currentTeam.id,
        playerId: playerId,
      );

      if (!success) {
        throw Exception('Backend failed to remove player.');
      }

      // 2. On success, update the local TeamModel
      _updateLocalTeamAfterPlayerRemoval(playerId);

      // 3. Send notification to the removed player
      await _sendRemovalNotification(playerId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to remove player: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
      rethrow; // Re-throw to show error in UI
    }
  }

  /// Updates the local TeamModel after a successful player removal API call.
  void _updateLocalTeamAfterPlayerRemoval(String playerId) {
    final currentTeam = team;
    if (currentTeam == null) return;

    // Create a new list of players by filtering out the removed player
    final updatedPlayers = currentTeam.players.where((player) => player.id != playerId).toList();

    // Create a new TeamModel with the updated player list
    final updatedTeam = currentTeam.copyWith(
      players: updatedPlayers,
    );

    // Update the _teams map for the current format
    _teams[_selectedFormat] = updatedTeam;
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

      // Use existing NotificationService to send notification
      final success = await NotificationService.sendNotification(
        receiverId: playerId,
        type: 'TEAM_REMOVAL',
        message: 'You have been removed from team "${team?.name ?? 'a team'}".',
        teamId: team?.id, // Include team ID if available
        senderId: currentUserId, // Include sender ID (captain)
      );

      if (success) {
      } else {
      }
    } catch (e) {
      // Don't throw error for notification failure - removal should still proceed
    }
  }
}

