class GameModel {
  final String id;
  final String? leagueId;
  final String leagueName;
  final String _team1Name;
  final String team1Logo; // Path or URL
  final String _team2Name;
  final String team2Logo; // Path or URL
  final DateTime date;
  final String time;
  final bool isFeePaid;
  final bool isMyGame;

  String get team1Name => _team1Name;
  String get team2Name => _team2Name;
  String get fullTeam1Name => _team1Name;
  String get fullTeam2Name => _team2Name;

  GameModel({
    required this.id,
    this.leagueId,
    required this.leagueName,
    required String team1Name,
    required this.team1Logo,
    required String team2Name,
    required this.team2Logo,
    required this.date,
    required this.time,
    required this.isFeePaid,
    this.isMyGame = false,
  }) : _team1Name = team1Name,
       _team2Name = team2Name;
}
