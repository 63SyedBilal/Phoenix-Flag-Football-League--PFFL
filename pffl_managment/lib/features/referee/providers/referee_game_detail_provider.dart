import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/features/captain/model/player_model.dart';

/// Game action types for referee
enum GameAction {
  toss,
  halfTimeDone,
  fullTimeDone,
  overTime,
  gameComplete,
}

/// Local representation of a player's scoring summary during the game.
class PlayerScoreEntry {
  const PlayerScoreEntry({
    required this.playerId,
    required this.playerName,
    required this.teamId,
    required this.points,
  });

  final String playerId;
  final String playerName;
  final String teamId;
  final int points;

  PlayerScoreEntry copyWith({
    String? playerName,
    String? teamId,
    int? points,
  }) {
    return PlayerScoreEntry(
      playerId: playerId,
      playerName: playerName ?? this.playerName,
      teamId: teamId ?? this.teamId,
      points: points ?? this.points,
    );
  }
}

/// Provider for Referee Game Detail screen
class RefereeGameDetailProvider extends ChangeNotifier {
  // Current match data
  MatchModel? _match;
  
  // Team scores for live updates
  int _homeScore = 0;
  int _awayScore = 0;

  // Player score board
  final Map<String, PlayerScoreEntry> _playerScoreEntries = {};
  
  // Selected tab index (0: Game actions, 1: Mark Attendance, 2: Select Players)
  int _selectedTabIndex = 0;
  
  // Game state
  bool _isTossCompleted = false;
  bool _isHalfTimeDone = false;
  bool _isFullTimeDone = false;
  bool _isOverTime = false;
  bool _isGameComplete = false;
  
  // Actions list for the game
  final List<Map<String, dynamic>> _gameActions = [];
  
  // FAB expanded state
  bool _isFabExpanded = false;
  
  // Loading state
  bool _isLoading = false;
  String? _error;
  
  // Attendance tracking
  String? _selectedAttendanceTeamId;
  final Map<String, bool> _playerAttendance = {}; // playerId -> isPresent
  bool _isAttendanceLocked = false;
  final Map<String, String> _playerTeamMap = {}; // playerId -> teamId

  // Player selection tracking
  String? _selectedPlayersTeamId;
  final Map<String, Set<String>> _selectedPlayersByTeam = {}; // teamId -> Set<playerId>
  bool _isPlayersLocked = false;
  
  // Team players data
  final Map<String, List<PlayerModel>> _teamPlayers = {}; // teamId -> List<PlayerModel>
  bool _isLoadingPlayers = false;
  
  // Getters
  MatchModel? get match => _match;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isTossCompleted => _isTossCompleted;
  bool get isHalfTimeDone => _isHalfTimeDone;
  bool get isFullTimeDone => _isFullTimeDone;
  bool get isOverTime => _isOverTime;
  bool get isGameComplete => _isGameComplete;
  List<Map<String, dynamic>> get gameActions => List.unmodifiable(_gameActions);
  bool get isFabExpanded => _isFabExpanded;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  List<PlayerScoreEntry> get playerScoreBoard {
    final entries = _playerScoreEntries.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    return entries;
  }
  
  // Attendance getters
  String? get selectedAttendanceTeamId => _selectedAttendanceTeamId;
  Map<String, bool> get playerAttendance => Map.unmodifiable(_playerAttendance);
  bool get isAttendanceLocked => _isAttendanceLocked;
  
  // Player selection getters
  String? get selectedPlayersTeamId => _selectedPlayersTeamId;
  Set<String> get selectedPlayerIds => _selectedPlayersByTeam[_selectedPlayersTeamId] ?? {};
  Map<String, Set<String>> get selectedPlayersByTeam => Map.unmodifiable(_selectedPlayersByTeam);
  bool get isLoadingPlayers => _isLoadingPlayers;
  bool get isPlayersLocked => _isPlayersLocked;
  
  /// Get selected player count for a specific team
  int getSelectedPlayerCount(String teamId) {
    return _selectedPlayersByTeam[teamId]?.length ?? 0;
  }
  
  /// Get players for a specific team
  List<PlayerModel> getTeamPlayers(String teamId) {
    return _teamPlayers[teamId] ?? [];
  }
  
  /// Get selected players for a specific team (for Add Game Action)
  /// Returns only players that were selected in Select Players screen
  List<PlayerModel> getSelectedPlayersForTeam(String teamId) {
    final selectedPlayerIds = _selectedPlayersByTeam[teamId] ?? {};
    final allTeamPlayers = _teamPlayers[teamId] ?? [];
    
    // Filter to only include selected players
    return allTeamPlayers.where((player) => selectedPlayerIds.contains(player.id)).toList();
  }
  
  /// Get present players for a specific team
  List<String> getPresentPlayerIds(String teamId) {
    return _playerAttendance.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Check if player is present
  bool isPlayerPresent(String playerId) {
    return _playerAttendance[playerId] ?? false;
  }
  
  /// Check if player is selected
  bool isPlayerSelected(String playerId) {
    return _selectedPlayersByTeam[_selectedPlayersTeamId]?.contains(playerId) ?? false;
  }
  
  /// Initialize with match data
  void initializeWithMatch(MatchModel match) {
    _match = match;
    _resetScoreTracking();
    _resetAttendanceAndSelection();
    _homeScore = match.homeScore ?? 0;
    _awayScore = match.awayScore ?? 0;
    
    // Set toss completion status based on match status
    if (match.status == MatchStatus.live || match.status == MatchStatus.completed) {
      _isTossCompleted = true;
    }
    
    notifyListeners();
  }
  
  /// Set selected tab
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
  
  /// Toggle FAB expanded state
  void toggleFab() {
    _isFabExpanded = !_isFabExpanded;
    notifyListeners();
  }
  
  /// Close FAB menu
  void closeFab() {
    _isFabExpanded = false;
    notifyListeners();
  }
  
  /// Execute game action
  Future<void> executeAction(GameAction action) async {
    if (_match == null || _match!.id == null) {
      _error = 'Match not initialized';
      notifyListeners();
      return;
    }

    // Toss is handled via a separate dialog, so we don't execute it here
    if (action == GameAction.toss) {
      return; // Toss dialog will be shown from the UI
    }

    // Convert GameAction to actionType string
    String actionType = '';
    switch (action) {
      case GameAction.halfTimeDone:
        actionType = 'Half Time Done';
        break;
      case GameAction.fullTimeDone:
        actionType = 'Full Time Done';
        break;
      case GameAction.overTime:
        actionType = 'Over Time';
        break;
      case GameAction.gameComplete:
        actionType = 'Game Complete';
        break;
      default:
        actionType = 'Unknown Action';
    }
    
    final pointsEarned = _getPointsForAction(actionType);
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      switch (action) {
        case GameAction.toss:
          // Toss is handled via a separate dialog, should not reach here
          // This case is included for exhaustiveness
          return;
        case GameAction.halfTimeDone:
          // Call API to switch to half time
          final updatedMatch = await MatchService.switchHalfTime(_match!.id!);
          _match = updatedMatch;
          _syncScoresFromMatch(updatedMatch);
          _isHalfTimeDone = true;
          _addAction('Half Time', 'Half time completed');
          break;
        case GameAction.fullTimeDone:
          // Call API to switch to full time
          final updatedMatch = await MatchService.switchFullTime(_match!.id!);
          _match = updatedMatch;
          _syncScoresFromMatch(updatedMatch);
          _isFullTimeDone = true;
          _addAction('Full Time', 'Full time completed');
          break;
        case GameAction.overTime:
          // Call API to switch to overtime
          final updatedMatch = await MatchService.switchOvertime(_match!.id!);
          _match = updatedMatch;
          _syncScoresFromMatch(updatedMatch);
          _isOverTime = true;
          _addAction('Over Time', 'Over time started');
          break;
        case GameAction.gameComplete:
          // Update match status to completed
          final updatedMatch = await MatchService.updateMatch(
            _match!.id!,
            {'status': 'completed'},
          );
          _match = updatedMatch;
          _isGameComplete = true;
          _addAction('Game Complete', 'Game has been completed');
          break;
      }
      
      _isFabExpanded = false;
    } catch (e) {
      _error = 'Failed to execute action: ${e.toString()}';
      debugPrint('❌ Error executing action: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Add action to history
  void _addAction(String title, String description) {
    _gameActions.insert(0, {
      'title': title,
      'description': description,
      'timestamp': DateTime.now(),
    });
  }
  
  /// Add custom action
  void addCustomAction(String title, String description) {
    _addAction(title, description);
    notifyListeners();
  }
  
  /// Forfeit game
  Future<bool> forfeitGame() async {
    if (_isPlayersLocked) {
      return true;
    }

    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: Call API to forfeit game
      _isGameComplete = true;
      _addAction('Game Forfeited', 'Game has been forfeited');
      return true;
    } catch (e) {
      _error = 'Failed to forfeit game: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Complete toss - called from toss dialog
  Future<void> completeToss(String winnerTeamId, String winnerSide) async {
    if (_match == null || _match!.id == null) {
      _error = 'Match not initialized';
      notifyListeners();
      throw Exception('Match not initialized');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call API to complete toss
      final updatedMatch = await MatchService.completeToss(
        matchId: _match!.id!,
        winnerTeamId: winnerTeamId,
        winnerSide: winnerSide,
      );
      
      _match = updatedMatch;
      _syncScoresFromMatch(updatedMatch);
      _isTossCompleted = true;
      _addAction('Toss', 'Toss completed - ${winnerSide == 'offense' ? 'Offensive' : 'Defensive'} selected');
    } catch (e) {
      _error = 'Failed to complete toss: ${e.toString()}';
      debugPrint('❌ Error completing toss: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add game action (Touchdown, Extra Point, etc.)
  Future<void> addGameAction({
    required String teamId,
    required String playerId,
    required String actionType,
  }) async {
    if (_match == null || _match!.id == null) {
      _error = 'Match not initialized';
      notifyListeners();
      throw Exception('Match not initialized');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate points earned for this action
      final pointsEarned = _getPointsForAction(actionType);
      
      // Call API to add game action
      final updatedMatch = await MatchService.addGameAction(
        matchId: _match!.id!,
        teamId: teamId,
        playerId: playerId,
        actionType: actionType,
      );
      
      _match = updatedMatch;
      _applyTeamScoreUpdate(
        updatedMatch: updatedMatch,
        teamId: teamId,
        fallbackPoints: pointsEarned,
      );
      _recordPlayerScore(
        playerId: playerId,
        teamId: teamId,
        points: pointsEarned,
      );
      
      final teamLabel = _getTeamDisplayName(teamId);
      final playerName = _getPlayerDisplayName(playerId);
      final description = pointsEarned > 0
          ? '$playerName scored +$pointsEarned pts'
          : '$playerName recorded $actionType';
      
      _addAction(
        '$actionType · $teamLabel',
        description,
      );
      
      debugPrint('✅ Game action added successfully');
    } catch (e) {
      _error = 'Failed to add game action: ${e.toString()}';
      debugPrint('❌ Error adding game action: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ============== Team Players Methods ==============
  
  /// Fetch players for a specific team
  Future<void> fetchTeamPlayers(String teamId) async {
    // Return if players already loaded for this team
    if (_teamPlayers.containsKey(teamId) && _teamPlayers[teamId]!.isNotEmpty) {
      debugPrint('✅ Players already loaded for team: $teamId (${_teamPlayers[teamId]!.length} players)');
      return;
    }
    
    debugPrint('📡 Starting to fetch players for team: $teamId');
    _isLoadingPlayers = true;
    notifyListeners();
    
    try {
      debugPrint('📡 Fetching players for team: $teamId');
      final teamData = await TeamService.getTeamById(teamId);
      
      if (teamData == null) {
        debugPrint('⚠️ No team data found for teamId: $teamId');
        _teamPlayers[teamId] = [];
        return;
      }
      
      // Parse players from squad5v5 and squad7v7
      final List<PlayerModel> players = [];
      
      // Parse squad5v5
      final squad5v5 = teamData['squad5v5'] as List? ?? [];
      for (var playerData in squad5v5) {
        if (playerData is Map<String, dynamic>) {
          try {
            final player = _parsePlayerFromTeamData(playerData);
            if (player != null) players.add(player);
          } catch (e) {
            debugPrint('⚠️ Error parsing player: $e');
          }
        }
      }
      
      // Parse squad7v7
      final squad7v7 = teamData['squad7v7'] as List? ?? [];
      for (var playerData in squad7v7) {
        if (playerData is Map<String, dynamic>) {
          try {
            final player = _parsePlayerFromTeamData(playerData);
            // Avoid duplicates
            if (player != null && !players.any((p) => p.id == player.id)) {
              players.add(player);
            }
          } catch (e) {
            debugPrint('⚠️ Error parsing player: $e');
          }
        }
      }
      
      _teamPlayers[teamId] = players;
      for (final player in players) {
        _playerTeamMap[player.id] = teamId;
      }
      debugPrint('✅ Loaded ${players.length} players for team: $teamId');
      
      // Log player details for debugging
      for (var player in players) {
        debugPrint('   - Player: ${player.name} (#${player.number}) - ${player.position}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching team players: $e');
      _teamPlayers[teamId] = [];
      _error = 'Failed to fetch team players: ${e.toString()}';
    } finally {
      _isLoadingPlayers = false;
      debugPrint('🔔 Calling notifyListeners from fetchTeamPlayers');
      notifyListeners();
    }
  }
  
  /// Parse player from team data
  PlayerModel? _parsePlayerFromTeamData(Map<String, dynamic> data) {
    try {
      // Handle both populated player objects and bare ObjectIds
      final playerId = data['_id'] ?? data['id'];
      if (playerId == null) return null;
      
      // If player data is populated
      if (data['name'] != null || data['email'] != null) {
        return PlayerModel(
          id: playerId.toString(),
          name: data['name'] ?? 'Unknown',
          number: data['number']?.toString() ?? data['jerseyNumber']?.toString() ?? '00',
          email: data['email'] ?? '',
          position: data['position'] ?? 'Unknown',
          imageUrl: data['profilePictureUrl'] ?? data['avatar'],
          isCaptain: data['isCaptain'] ?? false,
          isVerified: data['isVerified'] ?? false,
          isPaid: data['isPaid'] ?? false,
        );
      }
      
      // If only player ID is available (not populated)
      return PlayerModel(
        id: playerId.toString(),
        name: 'Player ${playerId.toString().substring(playerId.toString().length - 4)}',
        number: '00',
        email: '',
        position: 'Unknown',
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing player data: $e');
      return null;
    }
  }
  
  // ============== Attendance Methods ==============
  
  /// Set selected attendance team and fetch players
  Future<void> setAttendanceTeam(String? teamId) async {
    debugPrint('🔄 Setting attendance team to: $teamId');
    _selectedAttendanceTeamId = teamId;
    notifyListeners(); // Update UI to show selected team
    
    // Fetch players for the selected team
    if (teamId != null && teamId.isNotEmpty) {
      await fetchTeamPlayers(teamId);
      debugPrint('✅ Attendance team set to: $teamId, Players loaded: ${_teamPlayers[teamId]?.length ?? 0}');
      notifyListeners(); // Update UI again after players are loaded
    }
  }
  
  /// Mark player attendance
  void markAttendance(String playerId, bool isPresent) {
    if (_isAttendanceLocked) {
      return;
    }
    _playerAttendance[playerId] = isPresent;
    
    // If marking as absent, remove from selected players in all teams
    if (!isPresent) {
      _selectedPlayersByTeam.forEach((teamId, players) {
        players.remove(playerId);
      });
    }
    
    notifyListeners();
  }
  
  /// Toggle player attendance
  void toggleAttendance(String playerId) {
    if (_isAttendanceLocked) {
      return;
    }
    final currentStatus = _playerAttendance[playerId] ?? false;
    markAttendance(playerId, !currentStatus);
  }
  
  /// Clear attendance for all players
  void clearAttendance() {
    if (_isAttendanceLocked) {
      return;
    }
    _playerAttendance.clear();
    notifyListeners();
  }

  /// Confirm attendance and lock further edits
  Future<bool> confirmAttendance() async {
    if (_isAttendanceLocked) {
      return true;
    }

    final presentCount = _playerAttendance.values.where((v) => v == true).length;
    if (presentCount == 0) {
      _error = 'Please mark at least one player as present';
      notifyListeners();
      return false;
    }

    final requiredPlayers = _requiredPlayersPerTeam();
    final homeTeamId = _match?.homeTeamId;
    final awayTeamId = _match?.awayTeamId;
    if (requiredPlayers > 0 &&
        homeTeamId != null &&
        homeTeamId.isNotEmpty &&
        awayTeamId != null &&
        awayTeamId.isNotEmpty) {
      final homePresent = _countPresentPlayersForTeam(homeTeamId);
      final awayPresent = _countPresentPlayersForTeam(awayTeamId);
      if (homePresent < requiredPlayers || awayPresent < requiredPlayers) {
        _error =
            'Format ${_match?.format ?? ''} requires $requiredPlayers players per team. '
            '${_match?.homeTeam ?? 'Home'}: $homePresent/$requiredPlayers, '
            '${_match?.awayTeam ?? 'Away'}: $awayPresent/$requiredPlayers.';
        notifyListeners();
        return false;
      }
    }

    _isAttendanceLocked = true;
    _addAction('Attendance Locked', '$presentCount player(s) marked present');
    notifyListeners();
    return true;
  }
  
  // ============== Player Selection Methods ==============
  
  /// Set selected players team and fetch players
  Future<void> setPlayersTeam(String? teamId) async {
    debugPrint('🔄 Setting players team to: $teamId');
    _selectedPlayersTeamId = teamId;
    notifyListeners(); // Update UI to show selected team
    
    // Fetch players for the selected team
    if (teamId != null && teamId.isNotEmpty) {
      await fetchTeamPlayers(teamId);
      debugPrint('✅ Players team set to: $teamId, Players loaded: ${_teamPlayers[teamId]?.length ?? 0}');
      notifyListeners(); // Update UI again after players are loaded
    }
  }
  
  /// Select player for current team
  void selectPlayer(String playerId) {
    if (_isPlayersLocked) {
      return;
    }
    if (_selectedPlayersTeamId == null) return;
    
    // Only allow selection if player is present
    if (isPlayerPresent(playerId)) {
      _selectedPlayersByTeam[_selectedPlayersTeamId!] ??= {};
      _selectedPlayersByTeam[_selectedPlayersTeamId!]!.add(playerId);
      notifyListeners();
    }
  }
  
  /// Deselect player from current team
  void deselectPlayer(String playerId) {
    if (_isPlayersLocked) {
      return;
    }
    if (_selectedPlayersTeamId == null) return;
    
    _selectedPlayersByTeam[_selectedPlayersTeamId]?.remove(playerId);
    notifyListeners();
  }
  
  /// Toggle player selection
  void togglePlayerSelection(String playerId) {
    if (_isPlayersLocked) {
      return;
    }
    if (_selectedPlayersTeamId == null) return;
    
    _selectedPlayersByTeam[_selectedPlayersTeamId!] ??= {};
    final isSelected = _selectedPlayersByTeam[_selectedPlayersTeamId!]!.contains(playerId);
    
    if (isSelected) {
      deselectPlayer(playerId);
    } else {
      selectPlayer(playerId);
    }
  }
  
  /// Clear all player selections
  void clearPlayerSelection() {
    if (_isPlayersLocked) {
      return;
    }
    _selectedPlayersByTeam.clear();
    notifyListeners();
  }
  
  /// Confirm player selection - save to backend
  Future<bool> confirmPlayerSelection() async {
    // Calculate total selected players
    int totalSelected = 0;
    _selectedPlayersByTeam.forEach((teamId, players) {
      totalSelected += players.length;
    });
    
    if (totalSelected == 0) {
      _error = 'No players selected';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: Call API to save selected players
      debugPrint('✅ Selected players confirmed:');
      _selectedPlayersByTeam.forEach((teamId, players) {
        debugPrint('   Team $teamId: ${players.length} players - $players');
      });
      
      _addAction('Players Selected', '$totalSelected players confirmed');
      _isPlayersLocked = true;
      return true;
    } catch (e) {
      _error = 'Failed to confirm players: $e';
      debugPrint('❌ Error confirming players: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============== Scoreboard Helpers ==============

  void _resetScoreTracking() {
    _playerScoreEntries.clear();
    _homeScore = 0;
    _awayScore = 0;
  }

  void _resetAttendanceAndSelection() {
    _selectedAttendanceTeamId = null;
    _playerAttendance.clear();
    _isAttendanceLocked = false;
    _playerTeamMap.clear();
    _selectedPlayersTeamId = null;
    _selectedPlayersByTeam.clear();
    _isPlayersLocked = false;
  }

  int _requiredPlayersPerTeam() {
    final format = _match?.format?.toLowerCase();
    if (format == '5v5') {
      return 5;
    }
    if (format == '7v7') {
      return 7;
    }
    return 0;
  }

  int _countPresentPlayersForTeam(String teamId) {
    int count = 0;
    _playerAttendance.forEach((playerId, isPresent) {
      if (isPresent && _playerTeamMap[playerId] == teamId) {
        count++;
      }
    });
    return count;
  }

  void _syncScoresFromMatch(MatchModel? match) {
    if (match == null) return;
    if (match.homeScore != null) {
      _homeScore = match.homeScore!;
    }
    if (match.awayScore != null) {
      _awayScore = match.awayScore!;
    }
  }

  int _getPointsForAction(String actionType) {
    switch (actionType) {
      case 'Touchdown':
        return 6;
      case 'Extra Point from 5-yard line':
        return 1;
      case 'Extra Point from 12-yard line':
        return 2;
      case 'Extra Point from 20-yard line':
        return 3;
      default:
        return 0;
    }
  }

  void _applyTeamScoreUpdate({
    required MatchModel updatedMatch,
    required String teamId,
    required int fallbackPoints,
  }) {
    final hadBackendScores =
        (updatedMatch.homeScore != null || updatedMatch.awayScore != null);
    _syncScoresFromMatch(updatedMatch);
    if (hadBackendScores || fallbackPoints == 0) {
      return;
    }

    if (_isHomeTeam(teamId)) {
      _homeScore += fallbackPoints;
    } else {
      _awayScore += fallbackPoints;
    }
  }

  void _recordPlayerScore({
    required String playerId,
    required String teamId,
    required int points,
  }) {
    if (points == 0) return;
    final existing = _playerScoreEntries[playerId];
    final playerName = existing?.playerName ?? _getPlayerDisplayName(playerId);

    if (existing == null) {
      _playerScoreEntries[playerId] = PlayerScoreEntry(
        playerId: playerId,
        playerName: playerName,
        teamId: teamId,
        points: points,
      );
    } else {
      _playerScoreEntries[playerId] = existing.copyWith(
        points: existing.points + points,
        teamId: teamId,
        playerName: playerName,
      );
    }
  }

  String getTeamLabel(String teamId) => _getTeamDisplayName(teamId);

  String _getTeamDisplayName(String teamId) {
    if (_match == null) return 'Team';
    if (_match!.homeTeamId == teamId) {
      return _match!.homeTeam;
    }
    if (_match!.awayTeamId == teamId) {
      return _match!.awayTeam;
    }
    return 'Team';
  }

  String _getPlayerDisplayName(String playerId) {
    final player = _findPlayerById(playerId);
    if (player != null) {
      if (player.number.isNotEmpty && player.number != '00') {
        return '#${player.number} ${player.name}';
      }
      return player.name;
    }
    if (playerId.length <= 4) return 'Player $playerId';
    return 'Player ${playerId.substring(playerId.length - 4)}';
  }

  PlayerModel? _findPlayerById(String playerId) {
    for (final players in _teamPlayers.values) {
      for (final player in players) {
        if (player.id == playerId) {
          return player;
        }
      }
    }
    return null;
  }

  bool _isHomeTeam(String teamId) {
    final homeTeamId = _match?.homeTeamId;
    if (homeTeamId != null && homeTeamId.isNotEmpty) {
      return homeTeamId == teamId;
    }
    return false;
  }
}

