part of 'referee_game_detail_provider.dart';

extension RefereeGameDetailHelpersExtension on RefereeGameDetailProvider {
  void _resetScoreTracking() {
    _playerScoreEntries.clear();
    _homeScore = 0;
    _awayScore = 0;
  }

  void _resetAttendanceAndSelection() {
    _selectedAttendanceTeamId = null;
    _playerAttendance.clear();
    _isAttendanceLocked = false;
    _playerTeamMap.clear();
    _selectedPlayersTeamId = null;
    _selectedPlayersByTeam.clear();
    _isPlayersLocked = false;
  }

  int _requiredPlayersPerTeam() {
    final format = _match?.format?.toLowerCase();
    if (format == '5v5') return 5;
    if (format == '7v7') return 7;
    return 0;
  }

  int _countPresentPlayersForTeam(String teamId) {
    int count = 0;
    _playerAttendance.forEach((playerId, isPresent) {
      if (isPresent && _playerTeamMap[playerId] == teamId) {
        count++;
      }
    });
    return count;
  }

  void _syncScoresFromMatch(MatchModel? match) {
    if (match == null) return;
    if (match.homeScore != null) {
      _homeScore = match.homeScore!;
    }
    if (match.awayScore != null) {
      _awayScore = match.awayScore!;
    }
  }

  int _getPointsForAction(String actionType) {
    switch (actionType) {
      case 'Touchdown':
        return 6;
      case 'Extra Point from 5-yard line':
        return 1;
      case 'Extra Point from 12-yard line':
        return 2;
      case 'Extra Point from 20-yard line':
        return 3;
      default:
        return 0;
    }
  }

  void _applyTeamScoreUpdate({
    required MatchModel updatedMatch,
    required String teamId,
    required int fallbackPoints,
  }) {
    final hadBackendScores =
        (updatedMatch.homeScore != null || updatedMatch.awayScore != null);
    _syncScoresFromMatch(updatedMatch);
    if (hadBackendScores || fallbackPoints == 0) {
      return;
    }

    if (_isHomeTeam(teamId)) {
      _homeScore += fallbackPoints;
    } else {
      _awayScore += fallbackPoints;
    }
  }

  void _recordPlayerScore({
    required String playerId,
    required String teamId,
    required int points,
  }) {
    if (points == 0) return;
    final existing = _playerScoreEntries[playerId];
    final playerName = existing?.playerName ?? _getPlayerDisplayName(playerId);

    if (existing == null) {
      _playerScoreEntries[playerId] = RefereePlayerScoreEntry(
        playerId: playerId,
        playerName: playerName,
        teamId: teamId,
        points: points,
      );
    } else {
      _playerScoreEntries[playerId] = existing.copyWith(
        points: existing.points + points,
        teamId: teamId,
        playerName: playerName,
      );
    }
  }

  String getTeamLabel(String teamId) => _getTeamDisplayName(teamId);

  String _getTeamDisplayName(String teamId) {
    if (_match == null) return 'Team';
    if (_match!.homeTeamId == teamId) {
      return _match!.homeTeam;
    }
    if (_match!.awayTeamId == teamId) {
      return _match!.awayTeam;
    }
    return 'Team';
  }

  String _getPlayerDisplayName(String playerId) {
    final player = _findPlayerById(playerId);
    if (player != null) {
      if (player.number.isNotEmpty && player.number != '00') {
        return '#${player.number} ${player.name}';
      }
      return player.name;
    }
    if (playerId.length <= 4) return 'Player $playerId';
    return 'Player ${playerId.substring(playerId.length - 4)}';
  }

  PlayerModel? _findPlayerById(String playerId) {
    for (final players in _teamPlayers.values) {
      for (final player in players) {
        if (player.id == playerId) {
          return player;
        }
      }
    }
    return null;
  }

  bool _isHomeTeam(String teamId) {
    final homeTeamId = _match?.homeTeamId;
    if (homeTeamId != null && homeTeamId.isNotEmpty) {
      return homeTeamId == teamId;
    }
    return false;
  }

  List<GameTimelineEntry> _buildTimelineEntries() {
    final entries = <GameTimelineEntry>[
      const GameTimelineEntry.milestone(
        label: 'Over Time',
        showAddBadge: false,
      ),
      const GameTimelineEntry.milestone(label: 'Full Time'),
      const GameTimelineEntry.milestone(label: 'Half Time'),
    ];

    for (final action in _gameActions) {
      final type = action['type'] as GameTimelineEntryType?;
      if (type == GameTimelineEntryType.player) {
        entries.add(
          GameTimelineEntry.player(
            playerName:
                action['playerName'] as String? ?? action['title'] as String? ?? '',
            position:
                action['position'] as String? ?? action['description'] as String? ?? '',
            icon: action['icon'] as IconData? ?? Icons.sports_football,
            iconColor: action['iconColor'] as Color? ?? const Color(0xFF1E293B),
            isLeft: action['isLeft'] as bool? ?? true,
          ),
        );
      } else {
        entries.add(
          GameTimelineEntry.milestone(
            label: action['title'] as String? ?? '',
            icon: action['icon'] as IconData? ?? Icons.circle,
            iconColor: action['iconColor'] as Color? ?? const Color(0xFF1E293B),
            showAddBadge: action['showAddBadge'] as bool? ?? false,
            isStart: action['isStart'] as bool? ?? false,
          ),
        );
      }
    }

    entries.add(
      const GameTimelineEntry.milestone(
        label: 'Start',
        icon: Icons.play_circle,
        isStart: true,
      ),
    );

    return entries;
  }

  IconData _getIconForAction(String actionType) {
    switch (actionType) {
      case 'Touchdown':
        return Icons.sports_football;
      case 'Extra Point from 5-yard line':
      case 'Extra Point from 12-yard line':
      case 'Extra Point from 20-yard line':
        return Icons.sports;
      default:
        return Icons.flag;
    }
  }

  Color _getColorForAction(String actionType) {
    switch (actionType) {
      case 'Touchdown':
        return const Color(0xFF1E293B);
      case 'Extra Point from 5-yard line':
      case 'Extra Point from 12-yard line':
      case 'Extra Point from 20-yard line':
        return const Color(0xFF1E293B);
      default:
        return const Color(0xFFFBBF24);
    }
  }

  String _getPlayerPosition(String playerId) {
    final player = _findPlayerById(playerId);
    return player?.position ?? 'Player';
  }
}
