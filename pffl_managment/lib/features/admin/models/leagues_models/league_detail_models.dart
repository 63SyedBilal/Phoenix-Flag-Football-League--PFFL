import 'package:flutter/material.dart';

class LeagueGameModel {
  final String id;
  final String team1Name;
  final String team1Logo;
  final String team2Name;
  final String team2Logo;
  final DateTime gameDateTime;

  LeagueGameModel({
    required this.id,
    required this.team1Name,
    required this.team1Logo,
    required this.team2Name,
    required this.team2Logo,
    required this.gameDateTime,
  });

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
  final String teamName;
  final String teamLogo;
  final int wins;
  final int draws;
  final int losses;

  LeagueTeamStandingModel({
    required this.rank,
    required this.teamName,
    required this.teamLogo,
    required this.wins,
    required this.draws,
    required this.losses,
  });

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
  final String teamName;
  final String teamLogo;
  final String statValue;
  final String statLabel;
  final Color backgroundColor;

  LeagueTeamStatModel({
    required this.teamName,
    required this.teamLogo,
    required this.statValue,
    required this.statLabel,
    this.backgroundColor = const Color(0xFF1E293B),
  });
}
