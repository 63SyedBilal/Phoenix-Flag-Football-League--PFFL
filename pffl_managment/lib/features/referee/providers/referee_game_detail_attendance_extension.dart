part of 'referee_game_detail_provider.dart';

extension RefereeGameDetailAttendanceExtension on RefereeGameDetailProvider {
  Future<void> setAttendanceTeam(String? teamId) async {
    _selectedAttendanceTeamId = teamId;
    _emitStateChange();

    if (teamId != null && teamId.isNotEmpty) {
      await fetchTeamPlayers(teamId);
      _emitStateChange();
    }
  }

  void markAttendance(String playerId, bool isPresent) {
    if (_isAttendanceLocked) {
      return;
    }
    _playerAttendance[playerId] = isPresent;

    if (!isPresent) {
      _selectedPlayersByTeam.forEach((teamId, players) {
        players.remove(playerId);
      });
    }

    _emitStateChange();
  }

  void toggleAttendance(String playerId) {
    if (_isAttendanceLocked) {
      return;
    }
    final currentStatus = _playerAttendance[playerId] ?? false;
    markAttendance(playerId, !currentStatus);
  }

  void clearAttendance() {
    if (_isAttendanceLocked) {
      return;
    }
    _playerAttendance.clear();
    _emitStateChange();
  }

  Future<bool> confirmAttendance() async {
    if (_isAttendanceLocked) {
      return true;
    }

    final presentCount = _playerAttendance.values.where((v) => v == true).length;
    if (presentCount == 0) {
      _error = 'Please mark at least one player as present';
      _emitStateChange();
      return false;
    }

    final requiredPlayers = _requiredPlayersPerTeam();
    final homeTeamId = _match?.homeTeamId;
    final awayTeamId = _match?.awayTeamId;
    if (requiredPlayers > 0 &&
        homeTeamId != null &&
        homeTeamId.isNotEmpty &&
        awayTeamId != null &&
        awayTeamId.isNotEmpty) {
      final homePresent = _countPresentPlayersForTeam(homeTeamId);
      final awayPresent = _countPresentPlayersForTeam(awayTeamId);
      if (homePresent < requiredPlayers || awayPresent < requiredPlayers) {
        _error =
            'Format ${_match?.format ?? ''} requires $requiredPlayers players per team. '
            '${_match?.homeTeam ?? 'Home'}: $homePresent/$requiredPlayers, '
            '${_match?.awayTeam ?? 'Away'}: $awayPresent/$requiredPlayers.';
        _emitStateChange();
        return false;
      }
    }

    _isAttendanceLocked = true;
    _addAction(
      'Attendance Locked',
      '$presentCount player(s) marked present',
      type: GameTimelineEntryType.milestone,
      icon: Icons.lock,
      iconColor: const Color(0xFF1E293B),
    );
    _emitStateChange();
    return true;
  }
}
