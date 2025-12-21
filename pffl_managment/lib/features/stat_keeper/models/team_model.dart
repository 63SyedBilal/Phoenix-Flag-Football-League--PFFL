import 'player_model.dart';

class StatKeeperTeamModel {
  final String id;
  final String name;
  final String? logoUrl;
  final List<StatKeeperPlayerModel> players;

  StatKeeperTeamModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.players,
  });

  factory StatKeeperTeamModel.fromJson(Map<String, dynamic> json) {
    final teamId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final teamName = json['teamName'] ?? json['name'] ?? '';
    final image = json['image'] as String?;

    // Get all players from both squad5v5 and squad7v7 (since stat keeper works with matches)
    final squad5v5 = json['squad5v5'] as List<dynamic>? ?? [];
    final squad7v7 = json['squad7v7'] as List<dynamic>? ?? [];
    final allSquadPlayers = [...squad5v5, ...squad7v7];

    // Get captain
    final captain = json['captain'] as Map<String, dynamic>?;

    // Map players
    final players = <StatKeeperPlayerModel>[];

    // Add captain first if exists
    if (captain != null) {
      final captainId = captain['_id']?.toString() ?? captain['id']?.toString() ?? '';
      final captainFirstName = captain['firstName'] ?? '';
      final captainLastName = captain['lastName'] ?? '';
      final captainEmail = captain['email'] ?? '';

      players.add(StatKeeperPlayerModel(
        id: captainId,
        name: '$captainFirstName $captainLastName'.trim(),
        number: '',
        email: captainEmail,
        position: '',
        isCaptain: true,
      ));
    }

    // Add squad players
    for (var playerData in allSquadPlayers) {
      if (playerData is Map<String, dynamic>) {
        final playerId = playerData['_id']?.toString() ??
                         playerData['id']?.toString() ??
                         playerData.toString();
        final firstName = playerData['firstName'] ?? '';
        final lastName = playerData['lastName'] ?? '';
        final email = playerData['email'] ?? '';

        if (playerId.isNotEmpty && playerId != 'null') {
          players.add(StatKeeperPlayerModel(
            id: playerId,
            name: '$firstName $lastName'.trim().isEmpty ? 'Player $playerId' : '$firstName $lastName'.trim(),
            number: '',
            email: email,
            position: '',
            isCaptain: false,
          ));
        }
      } else if (playerData != null) {
        final playerId = playerData.toString();
        if (playerId.isNotEmpty && playerId != 'null') {
          players.add(StatKeeperPlayerModel(
            id: playerId,
            name: 'Player $playerId',
            number: '',
            email: '',
            position: '',
            isCaptain: false,
          ));
        }
      }
    }

    return StatKeeperTeamModel(
      id: teamId,
      name: teamName,
      logoUrl: image?.isNotEmpty == true ? image : null,
      players: players,
    );
  }

  // Create a copy with updated player stats
  StatKeeperTeamModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    List<StatKeeperPlayerModel>? players,
  }) {
    return StatKeeperTeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      players: players ?? this.players,
    );
  }
}
