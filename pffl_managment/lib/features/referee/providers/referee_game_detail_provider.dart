import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

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
    _isLoading = true;
    notifyListeners();
    
    try {
      switch (action) {
        case GameAction.toss:
          _isTossCompleted = true;
          _addAction('Toss', 'Toss completed');
          break;
        case GameAction.halfTimeDone:
          _isHalfTimeDone = true;
          _addAction('Half Time', 'Half time completed');
          break;
        case GameAction.fullTimeDone:
          _isFullTimeDone = true;
          _addAction('Full Time', 'Full time completed');
          break;
        case GameAction.overTime:
          _isOverTime = true;
          _addAction('Over Time', 'Over time started');
          break;
        case GameAction.gameComplete:
          _isGameComplete = true;
          _addAction('Game Complete', 'Game has been completed');
          break;
      }
      
      _isFabExpanded = false;
    } catch (e) {
      _error = 'Failed to execute action: $e';
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
}

