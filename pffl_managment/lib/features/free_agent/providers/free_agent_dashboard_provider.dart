import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/api_service.dart';
import 'package:pffl_managment/core/models/game_model.dart';

class FreeAgentDashboardProvider extends ChangeNotifier {
  // User information
  String _userName = 'Free Agent';
  bool _hasNotification = true;

  // Upcoming games
  List<GameModel> _upcomingGames = [];

  // Loading state
  bool _isLoading = false;

  // Getters
  String get userName => _userName;
  bool get hasNotification => _hasNotification;
  List<GameModel> get upcomingGames => _upcomingGames;
  bool get isLoading => _isLoading;

  FreeAgentDashboardProvider() {
    _initializeData();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _initializeData() async {
    _setLoading(true);
    try {
      // Fetch data from fake API
      final apiService = ApiService();
      _upcomingGames = await apiService.getUpcomingMatches('freeagent_1', 'freeagent');
    } catch (e) {
      // Fallback to mock data if API fails
      _initializeMockData();
    } finally {
      _setLoading(false);
    }
  }

  void _initializeMockData() {
    // Initialize upcoming games
    _upcomingGames = [
      GameModel(
        id: '1',
        leagueName: 'The Rugby Championship',
        team1Name: 'RC',
        team1Logo: 'assets/images/image 12.png',
        team2Name: 'STA',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime(2025, 8, 11),
        time: '01:05 AM PKT',
        isFeePaid: true,
        isMyGame: false,
      ),
      GameModel(
        id: '2',
        leagueName: 'The Rugby Championship',
        team1Name: 'RC',
        team1Logo: 'assets/images/image 12.png',
        team2Name: 'STA',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime(2025, 8, 11),
        time: '01:05 AM PKT',
        isFeePaid: true,
        isMyGame: false,
      ),
      GameModel(
        id: '3',
        leagueName: 'The Rugby Championship',
        team1Name: 'RC',
        team1Logo: 'assets/images/image 12.png',
        team2Name: 'STA',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime(2025, 8, 11),
        time: '01:05 AM PKT',
        isFeePaid: true,
        isMyGame: false,
      ),
    ];
  }

  Future<void> refreshData() async {
    _setLoading(true);
    try {
      final apiService = ApiService();
      _upcomingGames = await apiService.refreshMatches('freeagent_1', 'freeagent');
    } catch (e) {
      // Keep existing data if refresh fails
    } finally {
      _setLoading(false);
    }
  }

  void clearNotification() {
    _hasNotification = false;
    notifyListeners();
  }
}