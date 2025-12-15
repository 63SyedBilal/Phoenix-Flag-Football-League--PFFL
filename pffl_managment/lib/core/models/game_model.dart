class GameModel {
  final String id;
  final String leagueName;
  final String team1Name;
  final String team1Logo; // Path or URL
  final String team2Name;
  final String team2Logo; // Path or URL
  final DateTime date;
  final String time;
  final bool isFeePaid;
  final bool isMyGame;

  GameModel({
    required this.id,
    required this.leagueName,
    required this.team1Name,
    required this.team1Logo,
    required this.team2Name,
    required this.team2Logo,
    required this.date,
    required this.time,
    required this.isFeePaid,
    this.isMyGame = false,
  });
}