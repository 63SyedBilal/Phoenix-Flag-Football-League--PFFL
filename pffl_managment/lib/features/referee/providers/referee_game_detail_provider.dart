import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';

/// Game action types for referee
enum GameAction {
  toss,
  halfTimeDone,
  fullTimeDone,
  overTime,
  gameComplete,
}

/// Provider for Referee Game Detail screen
class RefereeGameDetailProvider extends ChangeNotifier {
  // Current match data
  MatchModel? _match;
  
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
  
  /// Initialize with match data
  void initializeWithMatch(MatchModel match) {
    _match = match;
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
          _isHalfTimeDone = true;
          _addAction('Half Time', 'Half time completed');
          break;
        case GameAction.fullTimeDone:
          // Call API to switch to full time
          final updatedMatch = await MatchService.switchFullTime(_match!.id!);
          _match = updatedMatch;
          _isFullTimeDone = true;
          _addAction('Full Time', 'Full time completed');
          break;
        case GameAction.overTime:
          // Call API to switch to overtime
          final updatedMatch = await MatchService.switchOvertime(_match!.id!);
          _match = updatedMatch;
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
      // Call API to add game action
      final updatedMatch = await MatchService.addGameAction(
        matchId: _match!.id!,
        teamId: teamId,
        playerId: playerId,
        actionType: actionType,
      );
      
      _match = updatedMatch;
      
      // Add to action history
      _addAction(
        actionType,
        'Action added for player',
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
}

