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

    final presentCount = _playerAttendance.values
        .where((v) => v == true)
        .length;
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

    // Verify team ID mapping availability
    if (homeTeamId != null &&
        _AttendanceRefHelper.extractId(homeTeamId) != null) {
      if (!_AttendanceRefHelper.hasTeamId(homeTeamId)) {
        // Fallback or skip
      }
    }

    try {
      _isLoading = true;
      _emitStateChange();

      final homeId = _AttendanceRefHelper.extractId(_match?.homeTeamId);
      final awayId = _AttendanceRefHelper.extractId(_match?.awayTeamId);

      final Map<String, dynamic> attendanceUpdate = {};

      // Helper to build player list with isActive: false
      List<Map<String, dynamic>> buildAttendanceList(String teamId) {
        final presentIds = _playerAttendance.entries
            .where((e) => e.value == true)
            .map((e) => e.key)
            .toSet();

        final teamPlayers = _teamPlayers[teamId] ?? [];

        // Filter only present players
        return teamPlayers
            .where((p) => presentIds.contains(p.id))
            .map(
              (p) => {
                'playerId': p.id, // Correct key for backend schema
                'isActive': false, // Default to false for attendance only
              },
            )
            .toList();
      }

      if (homeId != null) {
        attendanceUpdate['teamA'] = {
          'teamId': homeId,
          'players': buildAttendanceList(homeId),
        };
      }

      if (awayId != null) {
        attendanceUpdate['teamB'] = {
          'teamId': awayId,
          'players': buildAttendanceList(awayId),
        };
      }

      if (attendanceUpdate.isNotEmpty && _match?.id != null) {
        await _refereeGameDetailService.updateMatch(
          _match!.id!,
          attendanceUpdate,
        );
      }

      _isAttendanceLocked = true;
      _addAction(
        'Attendance Locked',
        '$presentCount player(s) marked present & saved',
        type: GameTimelineEntryType.milestone,
        icon: Icons.lock,
        iconColor: const Color(0xFF1E293B),
      );
      return true;
    } catch (e) {
      _error = 'Failed to save attendance: $e';
      debugPrint('❌ Error saving attendance: $e');
      return false;
    } finally {
      _isLoading = false;
      _emitStateChange();
    }
  }
}

// Helper class for safe ID extraction (duplicated to avoid dependency issues if not shared)
class _AttendanceRefHelper {
  static String? extractId(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) return data['_id']?.toString() ?? data['id']?.toString();
    return null;
  }

  static bool hasTeamId(dynamic data) {
    return extractId(data) != null;
  }
}
