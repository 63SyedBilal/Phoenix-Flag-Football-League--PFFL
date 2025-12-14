enum MatchStatus { upcoming, live, completed, cancelled }

class MatchModel {
  final String? id;
  final String leagueName;
  final String homeTeam;
  final String homeTeamLogo;
  final String awayTeam;
  final String awayTeamLogo;
  final String date;
  final String time;
  final MatchStatus? status;
  final DateTime? matchDateTime;

  // Optional admin fields
  final String? venue;
  final String? refereeId;
  final String? statKeeperId;
  final int? homeScore;
  final int? awayScore;
  final String? roundName;
  final String? gameNumber;

  // Filtering fields
  final String? leagueId;
  final String? homeTeamId;
  final String? awayTeamId;

  MatchModel({
    this.id,
    required this.leagueName,
    required this.homeTeam,
    required this.homeTeamLogo,
    required this.awayTeam,
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
  });

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
