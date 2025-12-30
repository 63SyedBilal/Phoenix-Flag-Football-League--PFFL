import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/features/referee/repositories/referee_dashboard_repository.dart';

class RefereeDashboardProvider extends ChangeNotifier {
  // User information
  String _userName = 'Referee';
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

  final RefereeDashboardRepository _repository;

  RefereeDashboardProvider({
    RefereeDashboardRepository repository = const RefereeDashboardRepository(),
  }) : _repository = repository {
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
        _errorMessage = 'User ID not found. Please login again.';
        _upcomingGames = [];
        _setLoading(false);
        return;
      }
      
      // Fetch assigned games via repository
      _upcomingGames = await _repository.fetchAssignedGames(currentUserId);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load assigned games: ${e.toString()}';

      _upcomingGames = [];
    } finally {
      _setLoading(false);
    }
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

