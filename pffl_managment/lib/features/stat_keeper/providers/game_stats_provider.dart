import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/repositories/stat_keeper_repository_fixed.dart';

class GameStatsProvider extends ChangeNotifier {
  final String? matchId;
  bool _disposed = false;

  GameStatsProvider({this.matchId}) {
    if (matchId != null) {
      loadStats();
    }
  }

  bool _isLoading = false;
  GameStatModel? _gameStats;
  bool _isTeamASelected = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  GameStatModel? get gameStats => _gameStats;
  bool get isTeamASelected => _isTeamASelected;
  String? get errorMessage => _errorMessage;

  // Derived getters for easier UI consumption
  String get currentTeamName => _isTeamASelected
      ? (_gameStats?.team1Name ?? 'Team A')
      : (_gameStats?.team2Name ?? 'Team B');

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    if (matchId == null || _disposed) return;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      _gameStats = await StatKeeperRepositoryFixed.getMatchStats(matchId!);
      _errorMessage = null;
    } catch (e) {
      _gameStats = null;
      _errorMessage = e.toString();
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  void toggleTeamSelection(bool isTeamA) {
    if (_disposed) return;

    if (_isTeamASelected != isTeamA) {
      _isTeamASelected = isTeamA;
      _safeNotifyListeners();
    }
  }

  // Refresh stats (e.g., after navigating back from adding stats)
  Future<void> refreshStats() => loadStats();
}

