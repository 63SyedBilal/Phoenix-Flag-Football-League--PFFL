/// Model representing an individual player's scoring summary for the referee flow.
class RefereePlayerScoreEntry {
  const RefereePlayerScoreEntry({
    required this.playerId,
    required this.playerName,
    required this.teamId,
    required this.points,
  });

  final String playerId;
  final String playerName;
  final String teamId;
  final int points;

  RefereePlayerScoreEntry copyWith({
    String? playerName,
    String? teamId,
    int? points,
  }) {
    return RefereePlayerScoreEntry(
      playerId: playerId,
      playerName: playerName ?? this.playerName,
      teamId: teamId ?? this.teamId,
      points: points ?? this.points,
    );
  }
}
