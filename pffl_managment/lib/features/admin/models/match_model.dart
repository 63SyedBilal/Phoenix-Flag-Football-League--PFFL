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
  });
}
