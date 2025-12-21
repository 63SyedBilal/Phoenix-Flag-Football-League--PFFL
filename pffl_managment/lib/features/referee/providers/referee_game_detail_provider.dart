import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/features/captain/model/player_model.dart';
import 'package:pffl_managment/features/referee/models/game_timeline_entry.dart';
import 'package:pffl_managment/features/referee/models/referee_game_action.dart';
import 'package:pffl_managment/features/referee/models/referee_player_score_entry.dart';
import 'package:pffl_managment/features/referee/services/referee_game_detail_service.dart';

part 'referee_game_detail_actions_mixin.dart';
part 'referee_game_detail_attendance_extension.dart';
part 'referee_game_detail_players_extension.dart';
part 'referee_game_detail_helpers_extension.dart';

/// Provider for Referee Game Detail screen
class RefereeGameDetailProvider extends ChangeNotifier {
  RefereeGameDetailProvider({
    RefereeGameDetailService refereeGameDetailService =
        const RefereeGameDetailService(),
  }) : _refereeGameDetailService = refereeGameDetailService;

  // Current match data
  MatchModel? _match;
  
  // Team scores for live updates
  int _homeScore = 0;
  int _awayScore = 0;

  // Player score board
  final Map<String, RefereePlayerScoreEntry> _playerScoreEntries = {};
  
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
  
  final RefereeGameDetailService _refereeGameDetailService;

  // Getters
  MatchModel? get match => _match;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isTossCompleted => _isTossCompleted;
  bool get isHalfTimeDone => _isHalfTimeDone;
  bool get isFullTimeDone => _isFullTimeDone;
  bool get isOverTime => _isOverTime;
  bool get isGameComplete => _isGameComplete;
  List<Map<String, dynamic>> get gameActions => List.unmodifiable(_gameActions);
  List<GameTimelineEntry> get timelineEntries => _buildTimelineEntries();
  bool get isFabExpanded => _isFabExpanded;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  List<RefereePlayerScoreEntry> get playerScoreBoard {
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Emits a change notification for state updates performed in extensions.
  void _emitStateChange() {
    notifyListeners();
  }

  /// Delegates to the actions extension to execute a high-level game event.
  Future<void> executeAction(RefereeGameAction action) {
    return RefereeGameDetailActionsExtension(this).executeAction(action);
  }

  /// Delegates to the actions extension to record toss completion.
  Future<void> completeToss(String winnerTeamId, String winnerSide) {
    return RefereeGameDetailActionsExtension(this)
        .completeToss(winnerTeamId, winnerSide);
  }

  /// Delegates to the actions extension to add a specific game action entry.
  Future<void> addGameAction({
    required String teamId,
    required String playerId,
    required String actionType,
  }) {
    return RefereeGameDetailActionsExtension(this).addGameAction(
      teamId: teamId,
      playerId: playerId,
      actionType: actionType,
    );
  }

  /// Delegates to the actions extension to forfeit the current game.
  Future<bool> forfeitGame() {
    return RefereeGameDetailActionsExtension(this).forfeitGame();
  }

  /// Delegates to the actions extension to insert a custom timeline entry.
  void addCustomAction(String title, String description) {
    RefereeGameDetailActionsExtension(this).addCustomAction(title, description);
  }
}
