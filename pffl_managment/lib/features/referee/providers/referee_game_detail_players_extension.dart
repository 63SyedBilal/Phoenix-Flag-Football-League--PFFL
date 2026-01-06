part of 'referee_game_detail_provider.dart';

extension RefereeGameDetailPlayersExtension on RefereeGameDetailProvider {
  Future<void> fetchTeamPlayers(String teamId) async {
    if (_teamPlayers.containsKey(teamId) && _teamPlayers[teamId]!.isNotEmpty) {
      debugPrint(
        '✅ Players already loaded for team: $teamId (${_teamPlayers[teamId]!.length} players)',
      );
      return;
    }
    _isLoadingPlayers = true;
    _emitStateChange();

    try {
      final teamData = await TeamService.getTeamById(teamId);

      if (teamData == null) {
        _teamPlayers[teamId] = [];
        return;
      }

      final List<PlayerModel> players = [];

      final squad5v5 = teamData['squad5v5'] as List? ?? [];
      for (final playerData in squad5v5) {
        if (playerData is Map<String, dynamic>) {
          final player = _parsePlayerFromTeamData(playerData);
          if (player != null) players.add(player);
        }
      }

      final squad7v7 = teamData['squad7v7'] as List? ?? [];
      for (final playerData in squad7v7) {
        if (playerData is Map<String, dynamic>) {
          final player = _parsePlayerFromTeamData(playerData);
          if (player != null && !players.any((p) => p.id == player.id)) {
            players.add(player);
          }
        }
      }

      _teamPlayers[teamId] = players;
      for (final player in players) {
        _playerTeamMap[player.id] = teamId;
      }
    } catch (e) {
      _teamPlayers[teamId] = [];
      _error = 'Failed to fetch team players: ${e.toString()}';
    } finally {
      _isLoadingPlayers = false;
      _emitStateChange();
    }
  }

  PlayerModel? _parsePlayerFromTeamData(Map<String, dynamic> data) {
    try {
      final playerId = data['_id'] ?? data['id'];
      if (playerId == null) return null;

      final String? name = data['name'];
      final String? firstName = data['firstName'];
      final String? lastName = data['lastName'];
      final String? email = data['email'];

      String displayName = 'Unknown';
      if (name != null && name.isNotEmpty) {
        displayName = name;
      } else if (firstName != null || lastName != null) {
        displayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        if (displayName.isEmpty) displayName = 'Unknown';
      } else if (email != null && email.isNotEmpty) {
        displayName = email;
      }

      // Proceed only if we have some identifying info
      if (displayName != 'Unknown' || (email != null && email.isNotEmpty)) {
        // Prioritize jerseyNumber from schema
        String displayNumber = '00';
        if (data['jerseyNumber'] != null) {
          displayNumber = data['jerseyNumber'].toString();
        } else if (data['number'] != null) {
          displayNumber = data['number'].toString();
        }

        return PlayerModel(
          id: playerId.toString(),
          name: displayName,
          number: displayNumber,
          email: data['email'] ?? '',
          position: data['position'] ?? 'Unknown',
          imageUrl:
              data['profilePictureUrl'] ??
              data['avatar'] ??
              data['image'] ??
              data['profileImage'],
          isCaptain: data['isCaptain'] ?? false,
          isVerified: data['isVerified'] ?? false,
          isPaid: data['isPaid'] ?? false,
        );
      }

      final idStr = playerId.toString();
      final suffix = idStr.length >= 4
          ? idStr.substring(idStr.length - 4)
          : idStr;

      return PlayerModel(
        id: idStr,
        name: 'Player $suffix',
        number: '00',
        email: '',
        position: 'Unknown',
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> setPlayersTeam(String? teamId) async {
    _selectedPlayersTeamId = teamId;
    _emitStateChange();

    if (teamId != null && teamId.isNotEmpty) {
      await fetchTeamPlayers(teamId);
      _emitStateChange();
    }
  }

  void selectPlayer(String playerId) {
    if (_isPlayersLocked || _selectedPlayersTeamId == null) {
      return;
    }

    if (isPlayerPresent(playerId)) {
      _selectedPlayersByTeam[_selectedPlayersTeamId!] ??= {};
      _selectedPlayersByTeam[_selectedPlayersTeamId!]!.add(playerId);
      _emitStateChange();
    }
  }

  void deselectPlayer(String playerId) {
    if (_isPlayersLocked || _selectedPlayersTeamId == null) {
      return;
    }

    _selectedPlayersByTeam[_selectedPlayersTeamId]?.remove(playerId);
    _emitStateChange();
  }

  void togglePlayerSelection(String playerId) {
    if (_isPlayersLocked || _selectedPlayersTeamId == null) {
      return;
    }

    _selectedPlayersByTeam[_selectedPlayersTeamId!] ??= {};
    final isSelected = _selectedPlayersByTeam[_selectedPlayersTeamId!]!
        .contains(playerId);

    if (isSelected) {
      deselectPlayer(playerId);
    } else {
      selectPlayer(playerId);
    }
  }

  void clearPlayerSelection() {
    if (_isPlayersLocked) {
      return;
    }
    _selectedPlayersByTeam.clear();
    _emitStateChange();
  }

  Future<bool> confirmPlayerSelection() async {
    int totalSelected = 0;
    _selectedPlayersByTeam.forEach((_, players) {
      totalSelected += players.length;
    });

    if (totalSelected == 0) {
      _error = 'No players selected';
      _emitStateChange();
      return false;
    }

    // Validation: Check format limits (5v5 or 7v7)
    final format = _match?.format ?? '5v5';
    final maxPlayers = (format == '7v7') ? 7 : 5;

    // Check limit for each team
    String? limitError;
    _selectedPlayersByTeam.forEach((teamId, selectedIds) {
      if (selectedIds.length != maxPlayers) {
        limitError =
            'Selected players: ${selectedIds.length}/$maxPlayers. You must select exactly $maxPlayers players for $format format.';
      }
    });

    if (limitError != null) {
      _error = limitError;
      _emitStateChange();
      return false;
    }

    _isLoading = true;
    _emitStateChange();

    try {
      // 1. Prepare data for update
      final homeId = _RefHelper.extractId(_match?.homeTeamId);
      final awayId = _RefHelper.extractId(_match?.awayTeamId);

      final Map<String, dynamic> playersUpdate = {};

      // Build payload containing ALL present players, marking selected ones as active
      List<Map<String, dynamic>> buildRoster(String teamId) {
        final presentIds = _playerAttendance.entries
            .where((e) => e.value == true)
            .map((e) => e.key)
            .toSet();

        final selectedIds = _selectedPlayersByTeam[teamId] ?? {};
        final teamPlayers = _teamPlayers[teamId] ?? [];

        // Filter only present players (superset)
        return teamPlayers
            .where((p) => presentIds.contains(p.id))
            .map(
              (p) => {
                'playerId': p.id,
                'isActive': selectedIds.contains(
                  p.id,
                ), // True if selected, False if just present
              },
            )
            .toList();
      }

      if (homeId != null) {
        playersUpdate['teamA'] = {
          'teamId': homeId,
          'players': buildRoster(homeId),
        };
      }

      if (awayId != null) {
        playersUpdate['teamB'] = {
          'teamId': awayId,
          'players': buildRoster(awayId),
        };
      }

      if (playersUpdate.isNotEmpty) {
        await _refereeGameDetailService.updateMatch(_match!.id!, playersUpdate);
      }

      _addAction(
        'Players Selected',
        '$totalSelected players confirmed & saved',
        type: GameTimelineEntryType.milestone,
        icon: Icons.group,
        iconColor: const Color(0xFF1E293B),
      );
      _isPlayersLocked = true;
      return true;
    } catch (e) {
      _error = 'Failed to confirm players: $e';
      return false;
    } finally {
      _isLoading = false;
      _emitStateChange();
    }
  }
}

// Helper class for this extension to avoid polluting the main namespace
class _RefHelper {
  static String? extractId(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) return data['_id']?.toString() ?? data['id']?.toString();
    return null;
  }
}
