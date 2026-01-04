import 'package:pffl_managment/core/utils/team_utils.dart';

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
  final String _name;
  final String flagUrl;
  final int score;
  final bool isWinner;

  String get name => getTeamAbbreviation(_name);
  String get fullName => _name;

  TeamModel({
    required String name,
    required this.flagUrl,
    required this.score,
    required this.isWinner,
  }) : _name = name;
}
