class LeagueModel {
  final String id;
  final String name;

  LeagueModel({required this.id, required this.name});
}

class LeagueMatchModel {
  final String matchType;
  final String date;
  final TeamModel homeTeam;
  final TeamModel awayTeam;

  LeagueMatchModel({
    required this.matchType,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
  });
}

class TeamModel {
  final String name;
  final String flagUrl;
  final int score;
  final bool isWinner;

  TeamModel({
    required this.name,
    required this.flagUrl,
    required this.score,
    required this.isWinner,
  });
}
