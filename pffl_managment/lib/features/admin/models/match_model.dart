import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';
import 'package:pffl_managment/core/utils/team_utils.dart';

enum MatchStatus { upcoming, live, completed, cancelled }

class MatchModel {
  final String? id;
  final String leagueName;
  final String _homeTeam;
  final String homeTeamLogo;
  final String _awayTeam;
  final String awayTeamLogo;

  String get homeTeam => getTeamAbbreviation(_homeTeam);
  String get awayTeam => getTeamAbbreviation(_awayTeam);
  String get fullHomeTeam => _homeTeam;
  String get fullAwayTeam => _awayTeam;
  final String date;
  final String time;
  final MatchStatus? status;
  final DateTime? matchDateTime;
  final String? format;

  // Optional admin fields
  final String? venue;
  final String? refereeId;
  final String? statKeeperId;
  final int? homeScore;
  final int? awayScore;
  final String? roundName;
  final String? gameNumber;
  final TeamStatModel? homeTeamStats;
  final TeamStatModel? awayTeamStats;

  // Tournament fields
  final String? matchType; // "league", "semi-final-1", "semi-final-2", "final"
  final int? tournamentRound; // 1 for league, 2 for semi-finals, 3 for final
  final bool? isKnockout;
  final String? winner;
  final List<Map<String, dynamic>> actions;
  final String? tossWinnerId;
  final String? tossChoice;

  // Filtering fields
  final String? leagueId;
  final String? homeTeamId;
  final String? awayTeamId;

  MatchModel({
    this.id,
    required this.leagueName,
    required String homeTeam,
    required this.homeTeamLogo,
    required String awayTeam,
    required this.awayTeamLogo,
    required this.date,
    required this.time,
    this.status,
    this.matchDateTime,
    this.venue,
    this.refereeId,
    this.statKeeperId,
    this.homeScore,
    this.awayScore,
    this.roundName,
    this.gameNumber,
    this.leagueId,
    this.homeTeamId,
    this.awayTeamId,
    this.format,
    this.homeTeamStats,
    this.awayTeamStats,
    this.actions = const [],
    this.tossWinnerId,
    this.tossChoice,
    this.matchType,
    this.tournamentRound,
    this.isKnockout,
    this.winner,
  }) : _homeTeam = homeTeam,
       _awayTeam = awayTeam;

  MatchModel copyWith({
    String? id,
    String? leagueName,
    String? homeTeam,
    String? homeTeamLogo,
    String? awayTeam,
    String? awayTeamLogo,
    String? date,
    String? time,
    MatchStatus? status,
    DateTime? matchDateTime,
    String? venue,
    String? refereeId,
    String? statKeeperId,
    int? homeScore,
    int? awayScore,
    String? roundName,
    String? gameNumber,
    String? leagueId,
    String? homeTeamId,
    String? awayTeamId,
    String? format,
    TeamStatModel? homeTeamStats,
    TeamStatModel? awayTeamStats,
    List<Map<String, dynamic>>? actions,
    String? tossWinnerId,
    String? tossChoice,
    String? matchType,
    int? tournamentRound,
    bool? isKnockout,
    String? winner,
  }) {
    return MatchModel(
      id: id ?? this.id,
      leagueName: leagueName ?? this.leagueName,
      homeTeam: homeTeam ?? _homeTeam,
      homeTeamLogo: homeTeamLogo ?? this.homeTeamLogo,
      awayTeam: awayTeam ?? _awayTeam,
      awayTeamLogo: awayTeamLogo ?? this.awayTeamLogo,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      matchDateTime: matchDateTime ?? this.matchDateTime,
      venue: venue ?? this.venue,
      refereeId: refereeId ?? this.refereeId,
      statKeeperId: statKeeperId ?? this.statKeeperId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      roundName: roundName ?? this.roundName,
      gameNumber: gameNumber ?? this.gameNumber,
      leagueId: leagueId ?? this.leagueId,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      format: format ?? this.format,
      homeTeamStats: homeTeamStats ?? this.homeTeamStats,
      awayTeamStats: awayTeamStats ?? this.awayTeamStats,
      actions: actions ?? this.actions,
      tossWinnerId: tossWinnerId ?? this.tossWinnerId,
      tossChoice: tossChoice ?? this.tossChoice,
      matchType: matchType ?? this.matchType,
      tournamentRound: tournamentRound ?? this.tournamentRound,
      isKnockout: isKnockout ?? this.isKnockout,
      winner: winner ?? this.winner,
    );
  }

  /// Extract sequence number from gameNumber string like "Game 8 of 12"
  /// Returns the sequence number (8 in the example)
  int? getSequenceNumber() {
    if (gameNumber == null || gameNumber!.isEmpty) return null;
    try {
      final parts = gameNumber!.split(' ');
      if (parts.length >= 2) {
        return int.parse(parts[1]);
      }
    } catch (e) {
      // If parsing fails, return null
    }
    return null;
  }

  /// Extract total games from gameNumber string like "Game 8 of 12"
  /// Returns the total number (12 in the example)
  int? getTotalGames() {
    if (gameNumber == null || gameNumber!.isEmpty) return null;
    try {
      final parts = gameNumber!.split(' of ');
      if (parts.length == 2) {
        return int.parse(parts[1]);
      }
    } catch (e) {
      // If parsing fails, return null
    }
    return null;
  }
}
