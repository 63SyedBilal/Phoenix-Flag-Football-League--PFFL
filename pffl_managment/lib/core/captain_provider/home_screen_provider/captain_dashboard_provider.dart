import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/api_service.dart';
import '../../../features/captain/model/game_model.dart';

class CaptainDashboardProvider extends ChangeNotifier {
  // User information
  String _userName = 'John';
  bool _hasNotification = true;

  // Payment information
  bool _isPaymentCardExpanded = false;
  final String _paymentAmount = '\$250';
  final String _paymentSubtitle = 'League Fee Due';
  final String _leagueTitle = 'Champions Cup 2025';
  final String _leagueFormat = '5v5';
  final String _leagueStartDate = '10 December 2025';
  final String _leagueEndDate = '25 February 2026';

  // Next game
  GameModel? _nextGame;

  // Upcoming games
  List<GameModel> _upcomingGames = [];

  // Loading state
  bool _isLoading = false;

  // Getters
  String get userName => _userName;
  bool get hasNotification => _hasNotification;
  bool get isPaymentCardExpanded => _isPaymentCardExpanded;
  String get paymentAmount => _paymentAmount;
  String get paymentSubtitle => _paymentSubtitle;
  String get leagueTitle => _leagueTitle;
  String get leagueFormat => _leagueFormat;
  String get leagueStartDate => _leagueStartDate;
  String get leagueEndDate => _leagueEndDate;
  GameModel? get nextGame => _nextGame;
  List<GameModel> get upcomingGames => _upcomingGames;
  bool get isLoading => _isLoading;

  CaptainDashboardProvider() {
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
      _upcomingGames = await apiService.getUpcomingMatches('captain_1', 'captain');
      
      // Set next game (first game where isMyGame is true)
      _nextGame = _upcomingGames.firstWhere(
        (game) => game.isMyGame, 
        orElse: () => _upcomingGames.isNotEmpty ? _upcomingGames.first : GameModel(
          id: '',
          leagueName: '',
          team1Name: '',
          team1Logo: '',
          team2Name: '',
          team2Logo: '',
          date: DateTime.now(),
          time: '',
          isFeePaid: false,
          isMyGame: false,
        ),
      );
      
      // If we got a default empty GameModel, set nextGame to null
      if (_nextGame != null && _nextGame!.id.isEmpty) {
        _nextGame = null;
      }
    } catch (e) {
      // Fallback to mock data if API fails
      _initializeMockData();
    } finally {
      _setLoading(false);
    }
  }

  void _initializeMockData() {
    // Initialize next game
    _nextGame = GameModel(
      id: '1',
      leagueName: 'The Rugby Championship',
      team1Name: 'RC',
      team1Logo: 'assets/images/image 12.png',
      team2Name: 'STA',
      team2Logo: 'assets/images/image 14.png',
      date: DateTime(2025, 8, 11),
      time: '01:05 AM PKT',
      isFeePaid: true,
      isMyGame: true,
    );

    // Initialize upcoming games (all same as shown in image)
    _upcomingGames = [
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
      GameModel(
        id: '4',
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
      _upcomingGames = await apiService.refreshMatches('captain_1', 'captain');
      
      // Set next game (first game where isMyGame is true)
      _nextGame = _upcomingGames.firstWhere(
        (game) => game.isMyGame, 
        orElse: () => _upcomingGames.isNotEmpty ? _upcomingGames.first : GameModel(
          id: '',
          leagueName: '',
          team1Name: '',
          team1Logo: '',
          team2Name: '',
          team2Logo: '',
          date: DateTime.now(),
          time: '',
          isFeePaid: false,
          isMyGame: false,
        ),
      );
      
      // If we got a default empty GameModel, set nextGame to null
      if (_nextGame != null && _nextGame!.id.isEmpty) {
        _nextGame = null;
      }
    } catch (e) {
      // Keep existing data if refresh fails
    } finally {
      _setLoading(false);
    }
  }

  void togglePaymentCardExpansion() {
    _isPaymentCardExpanded = !_isPaymentCardExpanded;
    notifyListeners();
  }

  void handlePayNow() {
    // Handle payment logic here
    notifyListeners();
  }

  void clearNotification() {
    _hasNotification = false;
    notifyListeners();
  }
}
