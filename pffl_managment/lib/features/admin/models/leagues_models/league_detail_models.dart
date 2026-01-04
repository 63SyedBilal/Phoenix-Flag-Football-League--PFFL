import 'package:flutter/material.dart';
import 'package:pffl_managment/core/utils/team_utils.dart';

class LeagueGameModel {
  final String id;
  final String _team1Name;
  final String team1Logo;
  final String _team2Name;
  final String team2Logo;
  final DateTime gameDateTime;

  String get team1Name => getTeamAbbreviation(_team1Name);
  String get team2Name => getTeamAbbreviation(_team2Name);
  String get fullTeam1Name => _team1Name;
  String get fullTeam2Name => _team2Name;

  LeagueGameModel({
    required this.id,
    required String team1Name,
    required this.team1Logo,
    required String team2Name,
    required this.team2Logo,
    required this.gameDateTime,
  }) : _team1Name = team1Name,
       _team2Name = team2Name;

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[gameDateTime.month - 1]} ${gameDateTime.day}';
  }

  String get formattedTime {
    final hour = gameDateTime.hour > 12
        ? gameDateTime.hour - 12
        : gameDateTime.hour;
    final period = gameDateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = gameDateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

class LeagueTeamStandingModel {
  final int rank;
  final String _teamName;
  final String teamLogo;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int pointsScored;
  final int pointsAgainst;

  String get teamName => getTeamAbbreviation(_teamName);
  String get fullTeamName => _teamName;

  LeagueTeamStandingModel({
    required this.rank,
    required String teamName,
    required this.teamLogo,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.pointsScored,
    required this.pointsAgainst,
  }) : _teamName = teamName;

  int get pointsDifference => pointsScored - pointsAgainst;
  int get points => (wins * 3) + draws;
}

/// Model for key players
class LeagueKeyPlayerModel {
  final String id;
  final String name;
  final String avatarUrl;
  final int statValue;
  final String statLabel;
  final Color gradientStart;
  final Color gradientEnd;

  LeagueKeyPlayerModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.statValue,
    required this.statLabel,
    this.gradientStart = const Color(0xFF0C1232),
    this.gradientEnd = const Color(0xFF3B82F6),
  });
}

/// Model for team statistics
class LeagueTeamStatModel {
  final String _teamName;
  final String teamLogo;
  final String statValue;
  final String statLabel;
  final Color backgroundColor;

  String get teamName => getTeamAbbreviation(_teamName);
  String get fullTeamName => _teamName;

  LeagueTeamStatModel({
    required String teamName,
    required this.teamLogo,
    required this.statValue,
    required this.statLabel,
    this.backgroundColor = const Color(0xFF1E293B),
  }) : _teamName = teamName;
}
