enum StatStatus { draft, approved, all }

class PlayerStatModel {
  final String playerId;
  final String playerName;
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
  final String image;

  PlayerStatModel({
    required this.playerId,
    required this.playerName,
    this.image = '',
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

  PlayerStatModel copyWith({
    String? playerId,
    String? playerName,
    String? image,
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
    return PlayerStatModel(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      image: image ?? this.image,
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

  // Add stats from another PlayerStatModel
  PlayerStatModel addStats(PlayerStatModel other) {
    return PlayerStatModel(
      playerId: playerId,
      playerName: playerName,
      image: image,
      catches: catches + other.catches,
      catchesYards: catchesYards + other.catchesYards,
      rushes: rushes + other.rushes,
      rushesYards: rushesYards + other.rushesYards,
      passAttempts: passAttempts + other.passAttempts,
      passYards: passYards + other.passYards,
      completions: completions + other.completions,
      tds: tds + other.tds,
      flagPull: flagPull + other.flagPull,
      sack: sack + other.sack,
      interceptions: interceptions + other.interceptions,
      safety: safety + other.safety,
      conversionPoints: conversionPoints + other.conversionPoints,
    );
  }

  // Factory to create from stats input
  factory PlayerStatModel.fromStatsInput({
    required String playerId,
    required String playerName,
    required String image,
    required int catches,
    required int catchesYards,
    required int rushes,
    required int rushesYards,
    required int passAttempts,
    required int passYards,
    required int completions,
    required int tds,
    required int flagPull,
    required int sack,
    required int interceptions,
    required int safety,
    required int conversionPoints,
  }) {
    return PlayerStatModel(
      playerId: playerId,
      playerName: playerName,
      image: image,
      catches: catches,
      catchesYards: catchesYards,
      rushes: rushes,
      rushesYards: rushesYards,
      passAttempts: passAttempts,
      passYards: passYards,
      completions: completions,
      tds: tds,
      flagPull: flagPull,
      sack: sack,
      interceptions: interceptions,
      safety: safety,
      conversionPoints: conversionPoints,
    );
  }
}

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
  final List<PlayerStatModel> playerStats;

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
    this.playerStats = const [],
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
    List<PlayerStatModel>? playerStats,
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
      playerStats: playerStats ?? this.playerStats,
    );
  }

  // Add player stats and update team totals
  TeamStatModel addPlayerStats(PlayerStatModel playerStat) {
    // Check if player already exists, if so update their stats
    final existingIndex = playerStats.indexWhere(
      (p) => p.playerId == playerStat.playerId,
    );

    final updatedPlayerStats = List<PlayerStatModel>.from(playerStats);
    if (existingIndex >= 0) {
      // Update existing player stats
      updatedPlayerStats[existingIndex] = updatedPlayerStats[existingIndex]
          .addStats(playerStat);
    } else {
      // Add new player stats
      updatedPlayerStats.add(playerStat);
    }

    // Calculate new team totals
    final totalCatches = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.catches,
    );
    final totalCatchesYards = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.catchesYards,
    );
    final totalRushes = updatedPlayerStats.fold(0, (sum, p) => sum + p.rushes);
    final totalRushesYards = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.rushesYards,
    );
    final totalPassAttempts = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.passAttempts,
    );
    final totalPassYards = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.passYards,
    );
    final totalCompletions = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.completions,
    );
    final totalTds = updatedPlayerStats.fold(0, (sum, p) => sum + p.tds);
    final totalFlagPull = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.flagPull,
    );
    final totalSack = updatedPlayerStats.fold(0, (sum, p) => sum + p.sack);
    final totalInterceptions = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.interceptions,
    );
    final totalSafety = updatedPlayerStats.fold(0, (sum, p) => sum + p.safety);
    final totalConversionPoints = updatedPlayerStats.fold(
      0,
      (sum, p) => sum + p.conversionPoints,
    );

    return TeamStatModel(
      teamName: teamName,
      teamLogo: teamLogo,
      catches: totalCatches,
      catchesYards: totalCatchesYards,
      rushes: totalRushes,
      rushesYards: totalRushesYards,
      passAttempts: totalPassAttempts,
      passYards: totalPassYards,
      completions: totalCompletions,
      tds: totalTds,
      flagPull: totalFlagPull,
      sack: totalSack,
      interceptions: totalInterceptions,
      safety: totalSafety,
      conversionPoints: totalConversionPoints,
      playerStats: updatedPlayerStats,
    );
  }
}
