import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/referee/providers/referee_game_detail_provider.dart';
import 'package:pffl_managment/features/captain/model/player_model.dart';

/// Mark Attendance screen for referees
/// Allows marking which players are present for the match
class MarkAttendanceScreen extends StatefulWidget {
  final MatchModel match;

  const MarkAttendanceScreen({super.key, required this.match});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  @override
  void initState() {
    super.initState();

    // Set default team selection after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RefereeGameDetailProvider>(
        context,
        listen: false,
      );
      if (provider.selectedAttendanceTeamId == null) {
        final defaultTeamId = _extractTeamId(widget.match.homeTeamId);
        if (defaultTeamId.isNotEmpty) {
          provider.setAttendanceTeam(defaultTeamId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefereeGameDetailProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                children: [
                  const Text(
                    'Select Team',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTeamButton(
                          context,
                          provider,
                          teamId: _extractTeamId(widget.match.homeTeamId),
                          teamName: widget.match.homeTeam,
                          teamLogo: widget.match.homeTeamLogo,
                          teamColor: null,
                          isSelected:
                              provider.selectedAttendanceTeamId ==
                              _extractTeamId(widget.match.homeTeamId),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTeamButton(
                          context,
                          provider,
                          teamId: _extractTeamId(widget.match.awayTeamId),
                          teamName: widget.match.awayTeam,
                          teamLogo: widget.match.awayTeamLogo,
                          teamColor: null,
                          isSelected:
                              provider.selectedAttendanceTeamId ==
                              _extractTeamId(widget.match.awayTeamId),
                        ),
                      ),
                    ],
                  ),
                  if (provider.selectedAttendanceTeamId != null)
                    _buildPlayerList(context, provider)
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select a team to mark attendance',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading || provider.isAttendanceLocked
                      ? null
                      : () => _confirmAttendance(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          provider.isAttendanceLocked
                              ? 'Attendance Locked'
                              : 'Confirm Attendance',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAttendance(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) async {
    final success = await provider.confirmAttendance();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance locked for this game'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildTeamButton(
    BuildContext context,
    RefereeGameDetailProvider provider, {
    required String teamId,
    required String teamName,
    String? teamLogo,
    String? teamColor,
    required bool isSelected,
  }) {
    final bool isLocked = provider.isAttendanceLocked;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () async {
              await provider.setAttendanceTeam(teamId);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E3A5F)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (teamLogo != null && teamLogo.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  teamLogo,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildColorIndicator(teamColor, isSelected);
                  },
                ),
              )
            else
              _buildColorIndicator(teamColor, isSelected),

            const SizedBox(width: 8),
            Flexible(
              child: Text(
                teamName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorIndicator(String? teamColor, bool isSelected) {
    Color color;
    try {
      if (teamColor != null && teamColor.isNotEmpty) {
        final colorHex = teamColor.replaceAll('#', '');
        color = Color(int.parse('FF$colorHex', radix: 16));
      } else {
        color = isSelected ? Colors.white : Colors.grey;
      }
    } catch (e) {
      color = isSelected ? Colors.white : Colors.grey;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.grey[300]!,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildPlayerList(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) {
    final selectedTeamId = provider.selectedAttendanceTeamId;

    if (selectedTeamId == null) {
      return const SizedBox.shrink();
    }
    if (provider.isLoadingPlayers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    final List<PlayerModel> players = provider.getTeamPlayers(selectedTeamId);

    if (players.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'No players found for this team',
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header row with title and add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mark Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: provider.isAttendanceLocked
                  ? null
                  : () {
                      for (final player in players) {
                        provider.markAttendance(player.id, true);
                      }
                    },
              tooltip: 'Mark all as present',
              icon: const Icon(Icons.done_all),
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...players.map((player) {
          final playerId = player.id;
          final isPresent = provider.isPlayerPresent(playerId);

          return Opacity(
            opacity: provider.isAttendanceLocked ? 0.6 : 1,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:
                        player.imageUrl != null && player.imageUrl!.isNotEmpty
                        ? Image.network(
                            player.imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${player.number} ${player.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Position: ${player.position}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: provider.isAttendanceLocked
                            ? null
                            : () => provider.markAttendance(playerId, false),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: !isPresent ? Colors.red : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close,
                            color: !isPresent ? Colors.white : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: provider.isAttendanceLocked
                            ? null
                            : () => provider.markAttendance(playerId, true),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isPresent
                                ? AppColors.primaryColor
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.check,
                            color: isPresent ? Colors.white : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.person, color: Colors.grey, size: 24),
    );
  }

  /// Extract team ID from team object or string
  String _extractTeamId(dynamic teamData) {
    if (teamData == null) return '';

    // If it's already a string, return it
    if (teamData is String) return teamData;

    // If it's a Map (team object), extract _id
    if (teamData is Map) {
      return teamData['_id']?.toString() ?? teamData['id']?.toString() ?? '';
    }

    // Fallback: convert to string
    return teamData.toString();
  }
}
