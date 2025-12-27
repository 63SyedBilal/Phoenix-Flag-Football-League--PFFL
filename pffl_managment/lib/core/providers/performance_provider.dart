import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/performance_service.dart';

class PlayerPerformance {
  final String playerId;
  final String playerName;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int touchdowns;
  final int catches;
  final int rushes;
  final int flagPulls;
  final double yardsGained;
  final double yardsLost;
  final int completions;
  final int passAttempts;
  final double completionPercentage;
  final int safety;
  final int conversionPoints;
  final double averagePointsPerGame;
  final String bestPosition;
  final int ranking;

  PlayerPerformance({
    required this.playerId,
    required this.playerName,
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.touchdowns,
    required this.catches,
    required this.rushes,
    required this.flagPulls,
    required this.yardsGained,
    required this.yardsLost,
    required this.completions,
    required this.passAttempts,
    required this.completionPercentage,
    required this.safety,
    required this.conversionPoints,
    required this.averagePointsPerGame,
    required this.bestPosition,
    required this.ranking,
  });

  factory PlayerPerformance.fromJson(Map<String, dynamic> json) {
    return PlayerPerformance(
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      gamesPlayed: json['gamesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      touchdowns: json['touchdowns'] ?? 0,
      catches: json['catches'] ?? 0,
      rushes: json['rushes'] ?? 0,
      flagPulls: json['flagPulls'] ?? 0,
      yardsGained: (json['yardsGained'] ?? 0).toDouble(),
      yardsLost: (json['yardsLost'] ?? 0).toDouble(),
      completions: json['completions'] ?? 0,
      passAttempts: json['passAttempts'] ?? 0,
      completionPercentage: (json['completionPercentage'] ?? 0).toDouble(),
      safety: json['safety'] ?? 0,
      conversionPoints: json['conversionPoints'] ?? 0,
      averagePointsPerGame: (json['averagePointsPerGame'] ?? 0).toDouble(),
      bestPosition: json['bestPosition'] ?? 'Unknown',
      ranking: json['ranking'] ?? 0,
    );
  }
}

class PerformanceProvider extends ChangeNotifier {
  PlayerPerformance? _performance;
  bool _isLoading = false;
  String? _errorMessage;

  PlayerPerformance? get performance => _performance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  Future<void> loadPerformance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch real performance data from API
      _performance = await PerformanceService.getMyPerformance();

      if (_performance == null) {
        _errorMessage = 'No performance data available';
      } else {
        debugPrint('✅ Performance data loaded successfully');
      }
    } catch (e) {
      _errorMessage = 'Failed to load performance data: ${e.toString()}';
      debugPrint('❌ Error loading performance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate win percentage
  double get winPercentage {
    if (_performance == null || _performance!.gamesPlayed == 0) return 0.0;
    return (_performance!.wins / _performance!.gamesPlayed) * 100;
  }

  // Get performance grade based on stats
  String get performanceGrade {
    if (_performance == null) return 'N/A';

    final avgPoints = _performance!.averagePointsPerGame;
    if (avgPoints >= 8.0) return 'A+';
    if (avgPoints >= 6.5) return 'A';
    if (avgPoints >= 5.0) return 'B+';
    if (avgPoints >= 3.5) return 'B';
    if (avgPoints >= 2.0) return 'C+';
    if (avgPoints >= 1.0) return 'C';
    return 'D';
  }

  // Get grade color
  Color get gradeColor {
    switch (performanceGrade) {
      case 'A+':
        return const Color(0xFF10B981); // Green
      case 'A':
        return const Color(0xFF059669); // Green
      case 'B+':
        return const Color(0xFF3B82F6); // Blue
      case 'B':
        return const Color(0xFF6366F1); // Indigo
      case 'C+':
        return const Color(0xFFF59E0B); // Yellow
      case 'C':
        return const Color(0xFFF97316); // Orange
      default:
        return const Color(0xFFEF4444); // Red
    }
  }
}
