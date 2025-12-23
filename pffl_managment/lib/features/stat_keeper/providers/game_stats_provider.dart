import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/repositories/stat_keeper_repository.dart';

class GameStatsProvider extends ChangeNotifier {
  final String? matchId;

  GameStatsProvider({this.matchId}) {
    if (matchId != null) {
      loadStats();
    }
  }

  bool _isLoading = false;
  GameStatModel? _gameStats;
  bool _isTeamASelected = true;

  bool get isLoading => _isLoading;
  GameStatModel? get gameStats => _gameStats;
  bool get isTeamASelected => _isTeamASelected;

  // Derived getters for easier UI consumption
  String get currentTeamName => _isTeamASelected
      ? (_gameStats?.team1Name ?? 'Team A')
      : (_gameStats?.team2Name ?? 'Team B');

  Future<void> loadStats() async {
    if (matchId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _gameStats = await StatKeeperRepository.getMatchStats(matchId!);
    } catch (e) {
      debugPrint('Error loading game stats: $e');
      _gameStats = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTeamSelection(bool isTeamA) {
    if (_isTeamASelected != isTeamA) {
      _isTeamASelected = isTeamA;
      notifyListeners();
    }
  }

  // Refresh stats (e.g., after navigating back from adding stats)
  Future<void> refreshStats() => loadStats();
}
