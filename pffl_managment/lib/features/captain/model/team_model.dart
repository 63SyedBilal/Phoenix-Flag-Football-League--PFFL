import 'package:flutter/foundation.dart';
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
    final rawTeamName =
        json['teamName']?.toString() ?? json['name']?.toString() ?? '';
    final teamName = (rawTeamName == 'null' || rawTeamName.isEmpty)
        ? ''
        : rawTeamName;
    final rawTeamImg = json['image']?.toString();
    final image =
        (rawTeamImg == null || rawTeamImg == 'null' || rawTeamImg.isEmpty)
        ? null
        : rawTeamImg;

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

      final fName = captain['firstName']?.toString() ?? '';
      final lName = captain['lastName']?.toString() ?? '';
      final captainFirstName = (fName == 'null') ? '' : fName;
      final captainLastName = (lName == 'null') ? '' : lName;

      parsedCaptainName = '$captainFirstName $captainLastName'.trim();
      final captainEmail = captain['email']?.toString() ?? '';
      debugPrint('📦 [TEAM MODEL] Raw Captain Data: $captain');

      Map<String, dynamic>? profile =
          captain['profile'] as Map<String, dynamic>?;
      Map<String, dynamic>? userNested =
          captain['user'] as Map<String, dynamic>?;

      debugPrint(
        '🔍 [TEAM MODEL] Parsing captain: ${captain["_id"] ?? captain["id"]}',
      );
      debugPrint('🔍 [TEAM MODEL] Captain keys: ${captain.keys}');

      // Multi-key check for image
      String? rawImg =
          captain['profileImage']?.toString() ??
          captain['avatar']?.toString() ??
          captain['image']?.toString() ??
          captain['userImage']?.toString() ??
          captain['profile_image']?.toString() ??
          profile?['profileImage']?.toString() ??
          profile?['avatar']?.toString() ??
          profile?['image']?.toString() ??
          userNested?['profileImage']?.toString() ??
          userNested?['image']?.toString();

      final captainProfileImage =
          (rawImg == null || rawImg == 'null' || rawImg.isEmpty)
          ? null
          : rawImg;

      // Multi-key check for jersey number
      final captainJerseyNumber =
          captain['jerseyNumber']?.toString() ??
          captain['jersey_number']?.toString() ??
          captain['number']?.toString() ??
          captain['jersey_num']?.toString() ??
          profile?['jerseyNumber']?.toString() ??
          profile?['jersey_number']?.toString() ??
          profile?['number']?.toString() ??
          userNested?['jerseyNumber']?.toString() ??
          '';

      // IMPROVED: Handle position as List or String
      final positionList = <String>[];
      final rawPosition =
          captain['position'] ??
          profile?['position'] ??
          userNested?['position'];

      if (rawPosition is List) {
        for (var pos in rawPosition) {
          final p = pos?.toString().trim() ?? '';
          if (p.isNotEmpty && p != 'null') positionList.add(p);
        }
      } else if (rawPosition != null) {
        final posStr = rawPosition.toString();
        if (posStr.isNotEmpty && posStr != 'null') {
          final splitPositions = posStr.split(',');
          for (final pos in splitPositions) {
            final trimmedPos = pos.trim();
            if (trimmedPos.isNotEmpty && trimmedPos != 'null') {
              positionList.add(trimmedPos);
            }
          }
        }
      }

      final fullPosition = positionList.join(', ');
      final additionalCount = positionList.length > 1
          ? positionList.length - 1
          : 0;

      debugPrint(
        '🎨 [TEAM MODEL] Resolved Captain: name=$parsedCaptainName, image=$captainProfileImage, jersey=$captainJerseyNumber, pos=$fullPosition',
      );

      players.add(
        PlayerModel(
          id: parsedCaptainId,
          name: parsedCaptainName.isEmpty
              ? 'Captain $parsedCaptainId'
              : parsedCaptainName,
          number: captainJerseyNumber == 'null' ? '' : captainJerseyNumber,
          email: captainEmail == 'null' ? '' : captainEmail,
          position: fullPosition,
          isCaptain: true,
          imageUrl: captainProfileImage,
          additionalPositionsCount: additionalCount,
          isPaid: false,
          isVerified: false,
          hasAlert: false,
        ),
      );
    }

    // Add squad players
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

        final fName = playerData['firstName']?.toString() ?? '';
        final lName = playerData['lastName']?.toString() ?? '';
        final firstName = (fName == 'null') ? '' : fName;
        final lastName = (lName == 'null') ? '' : lName;

        final email = playerData['email']?.toString() ?? '';

        Map<String, dynamic>? profile =
            playerData['profile'] as Map<String, dynamic>?;
        Map<String, dynamic>? userNested =
            playerData['user'] as Map<String, dynamic>?;

        debugPrint('🔍 [TEAM MODEL] Parsing squad player: $playerId');
        debugPrint('📦 [TEAM MODEL] Raw Player Data: $playerData');

        // Multi-key check for image
        String? rawImg =
            playerData['profileImage']?.toString() ??
            playerData['avatar']?.toString() ??
            playerData['image']?.toString() ??
            playerData['userImage']?.toString() ??
            playerData['profile_image']?.toString() ??
            profile?['profileImage']?.toString() ??
            profile?['avatar']?.toString() ??
            profile?['image']?.toString() ??
            userNested?['profileImage']?.toString() ??
            userNested?['image']?.toString();

        final profileImage =
            (rawImg == null || rawImg == 'null' || rawImg.isEmpty)
            ? null
            : rawImg;

        // Multi-key check for jersey number
        final jerseyNumber =
            playerData['jerseyNumber']?.toString() ??
            playerData['jersey_number']?.toString() ??
            playerData['number']?.toString() ??
            playerData['jersey_num']?.toString() ??
            profile?['jerseyNumber']?.toString() ??
            profile?['jersey_number']?.toString() ??
            profile?['number']?.toString() ??
            userNested?['jerseyNumber']?.toString() ??
            '';

        // IMPROVED: Handle position as List or String
        final positionList = <String>[];
        final rawPos =
            playerData['position'] ??
            profile?['position'] ??
            userNested?['position'];

        if (rawPos is List) {
          for (var pos in rawPos) {
            final p = pos?.toString().trim() ?? '';
            if (p.isNotEmpty && p != 'null') positionList.add(p);
          }
        } else if (rawPos != null) {
          final posStr = rawPos.toString();
          if (posStr.isNotEmpty && posStr != 'null') {
            final splitPositions = posStr.split(',');
            for (final pos in splitPositions) {
              final trimmedPos = pos.trim();
              if (trimmedPos.isNotEmpty && trimmedPos != 'null') {
                positionList.add(trimmedPos);
              }
            }
          }
        }

        final fullPosition = positionList.join(', ');
        final additionalCount = positionList.length > 1
            ? positionList.length - 1
            : 0;

        if (playerId.isNotEmpty && playerId != 'null') {
          players.add(
            PlayerModel(
              id: playerId,
              name: '$firstName $lastName'.trim().isEmpty
                  ? 'Player $playerId'
                  : '$firstName $lastName'.trim(),
              number: jerseyNumber == 'null' ? '' : jerseyNumber,
              email: email == 'null' ? '' : email,
              position: fullPosition,
              isCaptain: false,
              imageUrl: profileImage,
              additionalPositionsCount: additionalCount,
              isPaid: false,
              isVerified: false,
              hasAlert: false,
            ),
          );
        }
      } else if (playerData != null) {
        final playerId = playerData.toString();
        if (parsedCaptainId != null && playerId == parsedCaptainId) {
          continue;
        }
        if (playerId.isNotEmpty && playerId != 'null') {
          players.add(
            PlayerModel(
              id: playerId,
              name: 'Player $playerId',
              number: '',
              email: '',
              position: '',
              isCaptain: false,
              isPaid: false,
              isVerified: false,
              hasAlert: false,
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
      captainId: parsedCaptainId,
      captainName: parsedCaptainName,
    );
  }
}
