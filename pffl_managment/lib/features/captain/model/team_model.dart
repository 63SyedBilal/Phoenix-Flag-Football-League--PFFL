import 'player_model.dart';

class TeamModel {
  final String id;
  final String name;
  final String logoUrl;
  final String format;
  final List<PlayerModel> players;
  final int maxPlayers;

  TeamModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.format,
    required this.players,
    required this.maxPlayers,
  });
}
