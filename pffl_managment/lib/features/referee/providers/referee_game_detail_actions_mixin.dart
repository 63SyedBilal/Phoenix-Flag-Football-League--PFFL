part of 'referee_game_detail_provider.dart';

extension RefereeGameDetailActionsExtension on RefereeGameDetailProvider {
  Future<void> executeAction(RefereeGameAction action) async {
    if (_match == null || _match!.id == null) {
      _error = 'Match not initialized';
      _emitStateChange();
      return;
    }

    if (action == RefereeGameAction.toss) {
      return;
    }

    switch (action) {
      case RefereeGameAction.halfTimeDone:
        break;
      case RefereeGameAction.fullTimeDone:
        break;
      case RefereeGameAction.overTime:
        break;
      case RefereeGameAction.gameComplete:
        break;
      default:
    }

    _isLoading = true;
    _error = null;
    _emitStateChange();

    try {
      switch (action) {
        case RefereeGameAction.halfTimeDone:
          final updatedMatch = await _refereeGameDetailService.switchHalfTime(
            _match!.id!,
          );
          _match = updatedMatch;
          _syncScoresFromMatch(updatedMatch);
          _isHalfTimeDone = true;
          _addAction(
            'Half Time',
            'Half time completed',
            type: GameTimelineEntryType.milestone,
            icon: Icons.circle,
            iconColor: const Color(0xFF1E293B),
          );
          break;
        case RefereeGameAction.fullTimeDone:
          final updatedMatch = await _refereeGameDetailService.switchFullTime(
            _match!.id!,
          );
          _match = updatedMatch;
          _syncScoresFromMatch(updatedMatch);
          _isFullTimeDone = true;
          _addAction(
            'Full Time',
            'Full time completed',
            type: GameTimelineEntryType.milestone,
            icon: Icons.circle,
            iconColor: const Color(0xFF1E293B),
          );
          break;
        case RefereeGameAction.overTime:
          final updatedMatch = await _refereeGameDetailService.switchOvertime(
            _match!.id!,
          );
          _match = updatedMatch;
          _syncScoresFromMatch(updatedMatch);
          _isOverTime = true;
          _addAction(
            'Over Time',
            'Over time started',
            type: GameTimelineEntryType.milestone,
            icon: Icons.circle,
            iconColor: const Color(0xFF1E293B),
            showAddBadge: false,
          );
          break;
        case RefereeGameAction.gameComplete:
          final updatedMatch = await _refereeGameDetailService.updateMatch(
            _match!.id!,
            {'status': 'completed'},
          );
          _match = updatedMatch;
          _isGameComplete = true;
          _addAction(
            'Game Complete',
            'Game has been completed',
            type: GameTimelineEntryType.milestone,
            icon: Icons.circle,
            iconColor: const Color(0xFF1E293B),
          );
          break;
        case RefereeGameAction.toss:
          break;
      }

      _isFabExpanded = false;
    } catch (e) {
      _error = 'Failed to execute action: ${e.toString()}';
    } finally {
      _isLoading = false;
      _emitStateChange();
    }
  }

  Future<void> completeToss(String winnerTeamId, String winnerSide) async {
    if (_match == null || _match!.id == null) {
      _error = 'Match not initialized';
      _emitStateChange();
      throw Exception('Match not initialized');
    }

    _isLoading = true;
    _error = null;
    _emitStateChange();

    try {
      final updatedMatch = await _refereeGameDetailService.completeToss(
        matchId: _match!.id!,
        winnerTeamId: winnerTeamId,
        winnerSide: winnerSide,
      );

      _match = updatedMatch;
      _syncScoresFromMatch(updatedMatch);
      _isTossCompleted = true;
      _addAction(
        'Toss',
        'Toss completed - ${winnerSide == 'offense' ? 'Offensive' : 'Defensive'} selected',
        type: GameTimelineEntryType.milestone,
        icon: Icons.circle,
        iconColor: const Color(0xFF1E293B),
      );
    } catch (e) {
      _error = 'Failed to complete toss: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      _emitStateChange();
    }
  }

  Future<void> addGameAction({
    required String teamId,
    required String playerId,
    required String actionType,
  }) async {
    if (_match == null || _match!.id == null) {
      _error = 'Match not initialized';
      _emitStateChange();
      throw Exception('Match not initialized');
    }

    if (_isGameComplete) {
      _error = 'Game is already completed';
      _emitStateChange();
      throw Exception('Game is already completed');
    }

    _isLoading = true;
    _error = null;
    _emitStateChange();

    try {
      final pointsEarned = _getPointsForAction(actionType);
      final updatedMatch = await _refereeGameDetailService.addGameAction(
        matchId: _match!.id!,
        teamId: teamId,
        playerId: playerId,
        actionType: actionType,
      );

      _match = updatedMatch;
      _applyTeamScoreUpdate(
        updatedMatch: updatedMatch,
        teamId: teamId,
        fallbackPoints: pointsEarned,
      );
      _recordPlayerScore(
        playerId: playerId,
        teamId: teamId,
        points: pointsEarned,
      );

      final teamLabel = _getTeamDisplayName(teamId);
      final playerName = _getPlayerDisplayName(playerId);
      final description = pointsEarned > 0
          ? '$playerName scored +$pointsEarned pts'
          : '$playerName recorded $actionType';

      _addAction(
        '$actionType · $teamLabel',
        description,
        type: GameTimelineEntryType.player,
        playerName: playerName,
        position: _getPlayerPosition(playerId),
        icon: _getIconForAction(actionType),
        iconColor: _getColorForAction(actionType),
        isLeft: _isHomeTeam(teamId),
      );
    } catch (e) {
      _error = 'Failed to add game action: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      _emitStateChange();
    }
  }

  Future<bool> forfeitGame() async {
    if (_isPlayersLocked) {
      return true;
    }

    _isLoading = true;
    _emitStateChange();

    try {
      _isGameComplete = true;
      _addAction('Game Forfeited', 'Game has been forfeited');
      return true;
    } catch (e) {
      _error = 'Failed to forfeit game: $e';
      return false;
    } finally {
      _isLoading = false;
      _emitStateChange();
    }
  }

  void addCustomAction(String title, String description) {
    _addAction(title, description);
    _emitStateChange();
  }

  void _addAction(
    String title,
    String description, {
    GameTimelineEntryType type = GameTimelineEntryType.milestone,
    bool isStart = false,
    bool showAddBadge = false,
    IconData? icon,
    Color? iconColor,
    String? playerName,
    String? position,
    bool isLeft = true,
  }) {
    _gameActions.insert(0, {
      'title': title,
      'description': description,
      'timestamp': DateTime.now(),
      'type': type,
      'isStart': isStart,
      'showAddBadge': showAddBadge,
      'icon': icon,
      'iconColor': iconColor,
      'playerName': playerName,
      'position': position,
      'isLeft': isLeft,
    });
  }
}
