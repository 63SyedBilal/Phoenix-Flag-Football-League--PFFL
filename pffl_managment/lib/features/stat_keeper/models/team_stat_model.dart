enum StatStatus { draft, approved, all }

class TeamStatModel {
  final String teamName;
  final String teamLogo;
  final int catches;
  final int catchesYards;
  final int rushes;
  final int rushesYards;
  final int passAttempts;
  final int passYards;
  final int completions;
  final int tds;
  final int flagPull;
  final int sack;
  final int interceptions;
  final int safety;
  final int conversionPoints;

  TeamStatModel({
    required this.teamName,
    required this.teamLogo,
    this.catches = 0,
    this.catchesYards = 0,
    this.rushes = 0,
    this.rushesYards = 0,
    this.passAttempts = 0,
    this.passYards = 0,
    this.completions = 0,
    this.tds = 0,
    this.flagPull = 0,
    this.sack = 0,
    this.interceptions = 0,
    this.safety = 0,
    this.conversionPoints = 0,
  });

  TeamStatModel copyWith({
    String? teamName,
    String? teamLogo,
    int? catches,
    int? catchesYards,
    int? rushes,
    int? rushesYards,
    int? passAttempts,
    int? passYards,
    int? completions,
    int? tds,
    int? flagPull,
    int? sack,
    int? interceptions,
    int? safety,
    int? conversionPoints,
  }) {
    return TeamStatModel(
      teamName: teamName ?? this.teamName,
      teamLogo: teamLogo ?? this.teamLogo,
      catches: catches ?? this.catches,
      catchesYards: catchesYards ?? this.catchesYards,
      rushes: rushes ?? this.rushes,
      rushesYards: rushesYards ?? this.rushesYards,
      passAttempts: passAttempts ?? this.passAttempts,
      passYards: passYards ?? this.passYards,
      completions: completions ?? this.completions,
      tds: tds ?? this.tds,
      flagPull: flagPull ?? this.flagPull,
      sack: sack ?? this.sack,
      interceptions: interceptions ?? this.interceptions,
      safety: safety ?? this.safety,
      conversionPoints: conversionPoints ?? this.conversionPoints,
    );
  }
}
