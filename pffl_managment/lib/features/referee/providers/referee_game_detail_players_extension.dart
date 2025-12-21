part of 'referee_game_detail_provider.dart';

extension RefereeGameDetailPlayersExtension on RefereeGameDetailProvider {
  Future<void> fetchTeamPlayers(String teamId) async {
    if (_teamPlayers.containsKey(teamId) && _teamPlayers[teamId]!.isNotEmpty) {
      debugPrint(
        '✅ Players already loaded for team: $teamId (${_teamPlayers[teamId]!.length} players)',
      );
      return;
    }

    debugPrint('📡 Starting to fetch players for team: $teamId');
    _isLoadingPlayers = true;
    _emitStateChange();

    try {
      final teamData = await TeamService.getTeamById(teamId);

      if (teamData == null) {
        debugPrint('⚠️ No team data found for teamId: $teamId');
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
      debugPrint('✅ Loaded ${players.length} players for team: $teamId');
    } catch (e) {
      debugPrint('❌ Error fetching team players: $e');
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

      if (data['name'] != null || data['email'] != null) {
        return PlayerModel(
          id: playerId.toString(),
          name: data['name'] ?? 'Unknown',
          number: data['number']?.toString() ??
              data['jerseyNumber']?.toString() ??
              '00',
          email: data['email'] ?? '',
          position: data['position'] ?? 'Unknown',
          imageUrl: data['profilePictureUrl'] ?? data['avatar'],
          isCaptain: data['isCaptain'] ?? false,
          isVerified: data['isVerified'] ?? false,
          isPaid: data['isPaid'] ?? false,
        );
      }

      final idStr = playerId.toString();
      final suffix = idStr.length >= 4 ? idStr.substring(idStr.length - 4) : idStr;

      return PlayerModel(
        id: idStr,
        name: 'Player $suffix',
        number: '00',
        email: '',
        position: 'Unknown',
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing player data: $e');
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
    final isSelected =
        _selectedPlayersByTeam[_selectedPlayersTeamId!]!.contains(playerId);

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

    _isLoading = true;
    _emitStateChange();

    try {
      _addAction(
        'Players Selected',
        '$totalSelected players confirmed',
        type: GameTimelineEntryType.milestone,
        icon: Icons.group,
        iconColor: const Color(0xFF1E293B),
      );
      _isPlayersLocked = true;
      return true;
    } catch (e) {
      _error = 'Failed to confirm players: $e';
      debugPrint('❌ Error confirming players: $e');
      return false;
    } finally {
      _isLoading = false;
      _emitStateChange();
    }
  }
}
