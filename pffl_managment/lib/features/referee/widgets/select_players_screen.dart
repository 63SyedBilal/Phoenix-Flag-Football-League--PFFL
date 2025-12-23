import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/referee/providers/referee_game_detail_provider.dart';
import 'package:pffl_managment/features/captain/model/player_model.dart';

/// Select Players screen for referees
/// Allows selecting which present players will play in the match
class SelectPlayersScreen extends StatefulWidget {
  final MatchModel match;

  const SelectPlayersScreen({super.key, required this.match});

  @override
  State<SelectPlayersScreen> createState() => _SelectPlayersScreenState();
}

class _SelectPlayersScreenState extends State<SelectPlayersScreen> {
  @override
  void initState() {
    super.initState();

    // Set default team selection after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RefereeGameDetailProvider>(
        context,
        listen: false,
      );

      // Select first team (home team) by default if not already selected
      if (provider.selectedPlayersTeamId == null) {
        final defaultTeamId = _extractTeamId(widget.match.homeTeamId);
        if (defaultTeamId.isNotEmpty) {
          provider.setPlayersTeam(defaultTeamId);
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
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                children: [
                  // Select Team heading
                  const Text(
                    'Select Team',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                              provider.selectedPlayersTeamId ==
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
                              provider.selectedPlayersTeamId ==
                              _extractTeamId(widget.match.awayTeamId),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  if (provider.selectedPlayersTeamId != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Players',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${provider.selectedPlayerIds.length}/5',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: _buildPresentPlayersList(context, provider),
                    ),
                  ] else
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
                              'Select a team to choose players',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Confirm button - always shown, enabled when requirements met
            _buildConfirmButton(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) {
    // Determine required players per team based on match format
    // For now, assume 5v5 format. You can add format detection logic later.
    final int requiredPlayersPerTeam = 5;

    // Get player counts for both teams
    final homeTeamId = _extractTeamId(widget.match.homeTeamId);
    final awayTeamId = _extractTeamId(widget.match.awayTeamId);

    final homeTeamCount = provider.getSelectedPlayerCount(homeTeamId);
    final awayTeamCount = provider.getSelectedPlayerCount(awayTeamId);

    // Check if requirements are met
    final bool requirementsMet =
        homeTeamCount == requiredPlayersPerTeam &&
        awayTeamCount == requiredPlayersPerTeam;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (provider.isLoading || !requirementsMet)
              ? null
              : () => _confirmSelection(context, provider),
          style: ElevatedButton.styleFrom(
            backgroundColor: requirementsMet
                ? const Color(0xFF1E3A5F) // Dark blue when enabled
                : Colors.grey[300], // Light grey when disabled
            foregroundColor: requirementsMet ? Colors.white : Colors.grey[500],
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  "Confirm Selection",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
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
    return GestureDetector(
      onTap: () async {
        await provider.setPlayersTeam(teamId);
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

            // Team name
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
        // Remove # if present
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

  Widget _buildPresentPlayersList(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) {
    final selectedTeamId = provider.selectedPlayersTeamId;

    if (selectedTeamId == null) {
      return const SizedBox.shrink();
    }
    if (provider.isLoadingPlayers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    final List<PlayerModel> allPlayers = provider.getTeamPlayers(
      selectedTeamId,
    );
    final presentPlayers = allPlayers.where((player) {
      final playerId = player.id;
      return provider.isPlayerPresent(playerId);
    }).toList();

    if (presentPlayers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 40, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'No players marked as present',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Please mark attendance first',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: presentPlayers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final player = presentPlayers[index];
        final playerId = player.id;
        final isSelected = provider.isPlayerSelected(playerId);

        return GestureDetector(
          onTap: () => provider.togglePlayerSelection(playerId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: player.imageUrl != null && player.imageUrl!.isNotEmpty
                      ? Image.network(
                          player.imageUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar(32);
                          },
                        )
                      : _buildDefaultAvatar(32),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${player.number} ${player.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isSelected
                              ? const Color(0xFF1E3A5F)
                              : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        player.position,
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Selection checkbox - smaller
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFE5E7EB),
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF1E3A5F)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar([double size = 40]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(Icons.person, color: Colors.grey, size: size * 0.6),
    );
  }

  Future<void> _confirmSelection(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) async {
    final success = await provider.confirmPlayerSelection();

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Players selected successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to confirm players'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
