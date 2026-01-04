import 'package:pffl_managment/core/utils/team_utils.dart';
import 'player_model.dart';

class TeamModel {
  final String id;
  final String _name;
  final String? logoUrl; // Can be null if no image uploaded
  final String format; // '5v5' or '7v7'
  final List<PlayerModel> players;
  final int maxPlayers; // 8 for 5v5, 12 for 7v7
  final String? captainId; // New field for easier access
  final String? captainName; // New field for easier access

  String get name => getTeamAbbreviation(_name);
  String get fullName => _name;

  TeamModel({
    required this.id,
    required String name,
    this.logoUrl,
    required this.format,
    required this.players,
    required this.maxPlayers,
    this.captainId, // Include in constructor
    this.captainName, // Include in constructor
  }) : _name = name;

  // Add a copyWith method for immutability
  TeamModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? format,
    List<PlayerModel>? players,
    int? maxPlayers,
    String? captainId,
    String? captainName,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? _name,
      logoUrl: logoUrl ?? this.logoUrl,
      format: format ?? this.format,
      players: players ?? this.players,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      captainId: captainId ?? this.captainId,
      captainName: captainName ?? this.captainName,
    );
  }

  factory TeamModel.fromJson(Map<String, dynamic> json, String format) {
    final teamId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final teamName = json['teamName'] ?? json['name'] ?? '';
    final image = json['image'] as String?;

    // Get squad based on format
    final squadField = format == '5v5' ? 'squad5v5' : 'squad7v7';
    final squad = json[squadField] as List<dynamic>? ?? [];

    // Get captain
    final captain = json['captain'] as Map<String, dynamic>?;

    String? parsedCaptainId;
    String? parsedCaptainName;

    // Map players from squad
    final players = <PlayerModel>[];

    // Add captain first if exists
    if (captain != null) {
      parsedCaptainId =
          captain['_id']?.toString() ?? captain['id']?.toString() ?? '';
      final captainFirstName = captain['firstName'] ?? '';
      final captainLastName = captain['lastName'] ?? '';
      parsedCaptainName = '$captainFirstName $captainLastName'.trim();
      final captainEmail = captain['email'] ?? '';
      final captainProfileImage = captain['profileImage'] ?? '';
      final captainJerseyNumber = captain['jerseyNumber']?.toString() ?? '';
      final captainPosition = captain['position'] ?? '';

      // Parse position string (can be comma-separated)
      final positionList = <String>[];
      if (captainPosition.isNotEmpty) {
        final splitPositions = captainPosition.split(',');
        for (final pos in splitPositions) {
          final trimmedPos = pos.trim();
          if (trimmedPos.isNotEmpty) {
            positionList.add(trimmedPos);
          }
        }
      }
      final primaryPosition = positionList.isNotEmpty ? positionList[0] : '';
      final additionalPositionsCount = positionList.length > 1
          ? positionList.length - 1
          : 0;

      players.add(
        PlayerModel(
          id: parsedCaptainId,
          name: parsedCaptainName.isEmpty
              ? 'Captain $parsedCaptainId'
              : parsedCaptainName,
          number: captainJerseyNumber,
          email: captainEmail,
          position: primaryPosition,
          isCaptain: true,
          imageUrl: captainProfileImage.isNotEmpty ? captainProfileImage : null,
          additionalPositionsCount: additionalPositionsCount,
          isPaid: false, // Payment status not available in team data
          isVerified: false, // Verification status not available in team data
          hasAlert: false, // Alert status not available in team data
        ),
      );
    }

    // Add squad players
    // Handle both populated objects and ObjectId strings
    for (var playerData in squad) {
      if (playerData is Map<String, dynamic>) {
        final playerId =
            playerData['_id']?.toString() ??
            playerData['id']?.toString() ??
            playerData.toString();
        // Exclude captain if already added
        if (parsedCaptainId != null && playerId == parsedCaptainId) {
          continue;
        }

        final firstName = playerData['firstName'] ?? '';
        final lastName = playerData['lastName'] ?? '';
        final email = playerData['email'] ?? '';
        final profileImage = playerData['profileImage'] ?? '';
        final jerseyNumber = playerData['jerseyNumber']?.toString() ?? '';
        final position = playerData['position'] ?? '';

        // Parse position string (can be comma-separated)
        final positionList = <String>[];
        if (position.isNotEmpty) {
          final splitPositions = position.split(',');
          for (final pos in splitPositions) {
            final trimmedPos = pos.trim();
            if (trimmedPos.isNotEmpty) {
              positionList.add(trimmedPos);
            }
          }
        }
        final primaryPosition = positionList.isNotEmpty ? positionList[0] : '';
        final additionalPositionsCount = positionList.length > 1
            ? positionList.length - 1
            : 0;

        // Only add if we have a valid player ID
        if (playerId.isNotEmpty && playerId != 'null') {
          players.add(
            PlayerModel(
              id: playerId,
              name: '$firstName $lastName'.trim().isEmpty
                  ? 'Player $playerId'
                  : '$firstName $lastName'.trim(),
              number: jerseyNumber,
              email: email,
              position: primaryPosition,
              isCaptain: false,
              imageUrl: profileImage.isNotEmpty ? profileImage : null,
              additionalPositionsCount: additionalPositionsCount,
              isPaid: false, // Payment status not available in team data
              isVerified:
                  false, // Verification status not available in team data
              hasAlert: false, // Alert status not available in team data
            ),
          );
        }
      } else if (playerData != null) {
        // Handle case where playerData is an ObjectId string
        final playerId = playerData.toString();
        // Exclude captain if already added
        if (parsedCaptainId != null && playerId == parsedCaptainId) {
          continue;
        }
        if (playerId.isNotEmpty && playerId != 'null') {
          players.add(
            PlayerModel(
              id: playerId,
              name:
                  'Player $playerId', // Temporary name, will be enriched from profile
              number: '',
              email: '',
              position: '',
              isCaptain: false,
              isPaid: false, // Payment status not available in team data
              isVerified:
                  false, // Verification status not available in team data
              hasAlert: false, // Alert status not available in team data
            ),
          );
        }
      }
    }

    final maxPlayers = format == '5v5' ? 8 : 12;

    return TeamModel(
      id: teamId,
      name: teamName,
      logoUrl: image?.isNotEmpty == true ? image : null,
      format: format,
      players: players,
      maxPlayers: maxPlayers,
      captainId: parsedCaptainId, // Assign parsed captain ID
      captainName: parsedCaptainName, // Assign parsed captain name
    );
  }
}
