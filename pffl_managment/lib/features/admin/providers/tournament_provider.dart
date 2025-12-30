import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/tournament_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

/// Tournament stage enum
enum TournamentStage {
  league,
  semiFinals,
  final_,
  completed
}

/// Provider for managing tournament knockout stages
class TournamentProvider extends ChangeNotifier {
  TournamentProvider({
    required this.leagueId,
    TournamentService? tournamentService,
  }) : _tournamentService = tournamentService ?? const TournamentService();

  final String leagueId;
  final TournamentService _tournamentService;

  // Tournament state
  TournamentStage _tournamentStage = TournamentStage.league;
  bool _isLoading = false;
  String? _errorMessage;

  // Tournament data
  List<TopTeam> _topTeams = [];
  List<MatchModel> _semiFinalMatches = [];
  MatchModel? _finalMatch;
  String? _championTeamId;
  String? _championTeamName;

  // Getters
  TournamentStage get tournamentStage => _tournamentStage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TopTeam> get topTeams => _topTeams;
  List<MatchModel> get semiFinalMatches => _semiFinalMatches;
  MatchModel? get finalMatch => _finalMatch;
  String? get championTeamId => _championTeamId;
  String? get championTeamName => _championTeamName;

  bool get canCreateSemiFinals =>
      _tournamentStage == TournamentStage.league &&
      _topTeams.length >= 4;

  bool get canCreateFinal =>
      _tournamentStage == TournamentStage.semiFinals &&
      _semiFinalMatches.length == 2 &&
      _semiFinalMatches.every((match) => match.status?.name == 'completed');

  bool get canCompleteTournament =>
      _tournamentStage == TournamentStage.final_ &&
      _finalMatch?.status?.name == 'completed' &&
      _finalMatch?.winner != null;

  /// Initialize tournament data for a league
  Future<void> initializeTournament() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load tournament bracket data
      final bracketResponse = await _tournamentService.getTournamentBracket(leagueId);

      if (bracketResponse['success'] == true) {
        final bracketData = bracketResponse['data'];

        // Update tournament stage
        _tournamentStage = _parseTournamentStage(bracketData['tournamentStage']);

        // Update top teams
        _topTeams = (bracketData['topTeams'] as List<dynamic>? ?? [])
            .map((team) => TopTeam.fromJson(team))
            .toList();

        // Update semi-final matches
        _semiFinalMatches = (bracketData['semiFinals'] as List<dynamic>? ?? [])
            .map((match) => _createMatchModelFromJson(match))
            .toList();

        // Update final match
        if (bracketData['final'] != null) {
          _finalMatch = _createMatchModelFromJson(bracketData['final']);
        }

        // Update champion
        if (bracketData['champion'] != null) {
          final champion = bracketData['champion'];
          _championTeamId = champion['_id'] ?? champion['id'];
          _championTeamName = champion['teamName'];
        }
      } else {
        _errorMessage = bracketResponse['message'] ?? 'Failed to load tournament data';
      }
    } catch (e) {
      _errorMessage = 'Error initializing tournament: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get top 4 teams from leaderboard
  Future<List<TopTeam>> getTopTeams() async {
    try {
      final response = await _tournamentService.getTopTeams(leagueId);

      if (response['success'] == true) {
        final teamsData = response['data'] as List<dynamic>;
        _topTeams = teamsData.map((team) => TopTeam.fromJson(team)).toList();
        notifyListeners();
        return _topTeams;
      } else {
        throw Exception(response['message'] ?? 'Failed to get top teams');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create semi-final matches
  Future<void> createSemiFinals({
    required DateTime matchDate,
    required String venue,
    List<String>? refereeIds,
    List<String>? statKeeperIds,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tournamentService.createSemiFinals(
        leagueId: leagueId,
        matchDate: matchDate,
        venue: venue,
        refereeIds: refereeIds,
        statKeeperIds: statKeeperIds,
      );

      if (response['success'] == true) {
        _tournamentStage = TournamentStage.semiFinals;

        // Update semi-final matches
        final matchesData = response['data']['matches'] as List<dynamic>;
        _semiFinalMatches = matchesData.map((match) => _createMatchModelFromJson(match)).toList();
      } else {
        _errorMessage = response['message'] ?? 'Failed to create semi-finals';
      }
    } catch (e) {
      _errorMessage = 'Error creating semi-finals: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create final match
  Future<void> createFinal({
    required DateTime matchDate,
    required String venue,
    required String refereeId,
    required String statKeeperId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tournamentService.createFinal(
        leagueId: leagueId,
        matchDate: matchDate,
        venue: venue,
        refereeId: refereeId,
        statKeeperId: statKeeperId,
      );

      if (response['success'] == true) {
        _tournamentStage = TournamentStage.final_;

        // Update final match
        final matchData = response['data']['match'];
        _finalMatch = _createMatchModelFromJson(matchData);
      } else {
        _errorMessage = response['message'] ?? 'Failed to create final';
      }
    } catch (e) {
      _errorMessage = 'Error creating final: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Complete tournament
  Future<void> completeTournament() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tournamentService.completeTournament(leagueId);

      if (response['success'] == true) {
        _tournamentStage = TournamentStage.completed;

        // Update champion
        final championData = response['data'];
        _championTeamId = championData['champion'];
        _championTeamName = 'Champion Team'; // Would be populated from API
      } else {
        _errorMessage = response['message'] ?? 'Failed to complete tournament';
      }
    } catch (e) {
      _errorMessage = 'Error completing tournament: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set match winner (for knockout advancement)
  Future<void> setMatchWinner({
    required String matchId,
    required String winnerId,
    bool tiebreakerUsed = false,
    String? tiebreakerType,
  }) async {
    try {
      final response = await _tournamentService.setMatchWinner(
        matchId: matchId,
        winnerId: winnerId,
        tiebreakerUsed: tiebreakerUsed,
        tiebreakerType: tiebreakerType,
      );

      if (response['success'] == true) {
        // Update local match data
        final matchIndex = _semiFinalMatches.indexWhere((m) => m.id == matchId);
        if (matchIndex != -1) {
          _semiFinalMatches[matchIndex] = _semiFinalMatches[matchIndex].copyWith(
            winner: winnerId,
            status: MatchStatus.completed,
          );
        } else if (_finalMatch?.id == matchId) {
          _finalMatch = _finalMatch!.copyWith(
            winner: winnerId,
            status: MatchStatus.completed,
          );
          _championTeamId = winnerId;
        }

        // Check if we can advance tournament stage
        await _checkTournamentProgression();

        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to set match winner');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Check if tournament can progress to next stage
  Future<void> _checkTournamentProgression() async {
    // Check if all league matches are complete (would trigger semi-finals)
    // This would be called when league matches are completed

    // Check if semi-finals are complete and can create final
    if (_tournamentStage == TournamentStage.semiFinals &&
        _semiFinalMatches.length == 2 &&
        _semiFinalMatches.every((match) => match.status?.name == 'completed')) {
      // Semi-finals complete, can create final
    }

    // Check if final is complete and can complete tournament
    if (_tournamentStage == TournamentStage.final_ &&
        _finalMatch?.status?.name == 'completed' &&
        _finalMatch?.winner != null) {
      // Tournament complete
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Parse tournament stage from string
  TournamentStage _parseTournamentStage(String? stage) {
    switch (stage) {
      case 'semi-finals':
        return TournamentStage.semiFinals;
      case 'final':
        return TournamentStage.final_;
      case 'completed':
        return TournamentStage.completed;
      case 'league':
      default:
        return TournamentStage.league;
    }
  }

  /// Get stage display name
  String getStageDisplayName() {
    switch (_tournamentStage) {
      case TournamentStage.league:
        return 'League Phase';
      case TournamentStage.semiFinals:
        return 'Semi-Finals';
      case TournamentStage.final_:
        return 'Final';
      case TournamentStage.completed:
        return 'Tournament Completed';
    }
  }

  /// Check if tournament is in knockout phase
  bool get isInKnockoutPhase =>
      _tournamentStage == TournamentStage.semiFinals ||
      _tournamentStage == TournamentStage.final_;

  /// Get all knockout matches
  List<MatchModel> get knockoutMatches {
    final matches = <MatchModel>[];
    matches.addAll(_semiFinalMatches);
    if (_finalMatch != null) {
      matches.add(_finalMatch!);
    }
    return matches;
  }

  /// Helper method to create MatchModel from JSON
  MatchModel _createMatchModelFromJson(Map<String, dynamic> json) {
    MatchStatus status = MatchStatus.upcoming;
    if (json['status'] == 'completed') {
      status = MatchStatus.completed;
    } else if (json['status'] == 'live') {
      status = MatchStatus.live;
    }

    return MatchModel(
      id: json['_id'] ?? json['id'],
      leagueName: json['leagueId']?['leagueName'] ?? 'Unknown League',
      homeTeam: json['teamA']?['teamName'] ?? 'Team A',
      homeTeamLogo: json['teamA']?['logo'] ?? '',
      awayTeam: json['teamB']?['teamName'] ?? 'Team B',
      awayTeamLogo: json['teamB']?['logo'] ?? '',
      date: json['gameDate'] != null
          ? DateTime.parse(json['gameDate']).toString().split(' ')[0]
          : DateTime.now().toString().split(' ')[0],
      time: json['gameTime'] ?? 'TBD',
      status: status,
      venue: json['venue'],
      refereeId: json['refereeId'],
      statKeeperId: json['statKeeperId'],
      homeScore: json['teamA']?['score'],
      awayScore: json['teamB']?['score'],
      roundName: json['roundName'],
      gameNumber: json['gameNumber'],
      leagueId: json['leagueId']?['_id'] ?? json['leagueId'],
      homeTeamId: json['teamA']?['_id'] ?? json['teamA'],
      awayTeamId: json['teamB']?['_id'] ?? json['teamB'],
      matchType: json['matchType'],
      tournamentRound: json['tournamentRound'],
      isKnockout: json['isKnockout'] ?? false,
      winner: json['winner'],
      actions: (json['actions'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
    );
  }
}

/// Model for top team in tournament
class TopTeam {
  final String teamId;
  final String teamName;
  final String? logo;
  final int position;
  final Map<String, dynamic> stats;

  TopTeam({
    required this.teamId,
    required this.teamName,
    this.logo,
    required this.position,
    required this.stats,
  });

  factory TopTeam.fromJson(Map<String, dynamic> json) {
    return TopTeam(
      teamId: json['teamId'] ?? '',
      teamName: json['teamName'] ?? 'Unknown Team',
      logo: json['logo'],
      position: json['position'] ?? 0,
      stats: json['stats'] ?? {},
    );
  }
}

