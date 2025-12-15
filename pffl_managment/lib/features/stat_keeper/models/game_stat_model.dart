import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';

class GameStatModel {
  final String id;
  final String leagueName;
  final String team1Name;
  final String team1Logo;
  final String team2Name;
  final String team2Logo;
  final DateTime date;
  final String time;
  final StatStatus status;
  final TeamStatModel team1Stats;
  final TeamStatModel team2Stats;
  final bool isAssignedToMe;
  final bool isCompleted;

  GameStatModel({
    required this.id,
    required this.leagueName,
    required this.team1Name,
    required this.team1Logo,
    required this.team2Name,
    required this.team2Logo,
    required this.date,
    required this.time,
    required this.status,
    required this.team1Stats,
    required this.team2Stats,
    this.isAssignedToMe = false,
    this.isCompleted = false,
  });

  GameStatModel copyWith({
    String? id,
    String? leagueName,
    String? team1Name,
    String? team1Logo,
    String? team2Name,
    String? team2Logo,
    DateTime? date,
    String? time,
    StatStatus? status,
    TeamStatModel? team1Stats,
    TeamStatModel? team2Stats,
    bool? isAssignedToMe,
    bool? isCompleted,
  }) {
    return GameStatModel(
      id: id ?? this.id,
      leagueName: leagueName ?? this.leagueName,
      team1Name: team1Name ?? this.team1Name,
      team1Logo: team1Logo ?? this.team1Logo,
      team2Name: team2Name ?? this.team2Name,
      team2Logo: team2Logo ?? this.team2Logo,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      team1Stats: team1Stats ?? this.team1Stats,
      team2Stats: team2Stats ?? this.team2Stats,
      isAssignedToMe: isAssignedToMe ?? this.isAssignedToMe,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
