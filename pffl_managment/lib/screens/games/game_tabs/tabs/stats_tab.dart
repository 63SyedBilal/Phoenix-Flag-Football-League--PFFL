import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_tabs_provider.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';
import 'package:pffl_managment/screens/games/player_detail_screen/player_detail_screen.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameTabsProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final homeName = provider.match.homeTeam;
    final awayName = provider.match.awayTeam;

    final homePlayers = _getPlayersWithStats(
      provider.homeTeamDetails,
      provider.match.format,
      provider.match.homeTeamStats,
      homeName,
    );

    final awayPlayers = _getPlayersWithStats(
      provider.awayTeamDetails,
      provider.match.format,
      provider.match.awayTeamStats,
      awayName,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Player Stats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
            ),
            if (homePlayers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  homeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...homePlayers
                  .map(
                    (player) =>
                        _buildPlayerStatsCard(context, player, provider),
                  )
                  .toList(),
              const SizedBox(height: 20),
            ],
            if (awayPlayers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  awayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...awayPlayers
                  .map(
                    (player) =>
                        _buildPlayerStatsCard(context, player, provider),
                  )
                  .toList(),
            ],
            if (homePlayers.isEmpty && awayPlayers.isEmpty)
              const Center(child: Text("No players found.")),
          ],
        ),
      ),
    );
  }

  List<_PlayerStatsData> _getPlayersWithStats(
    Map<String, dynamic>? details,
    String? format,
    TeamStatModel? teamStats,
    String teamName,
  ) {
    if (details == null) return [];

    String squadKey = 'squad5v5';
    if (format == '7v7') squadKey = 'squad7v7';
    List squad = details[squadKey] as List? ?? [];
    if (squad.isEmpty && squadKey == 'squad5v5') {
      squad = details['squad7v7'] as List? ?? [];
    }
    if (squad.isEmpty) {
      squad = details['players'] as List? ?? [];
    }

    return squad
        .map((p) {
          if (p is! Map) return null;
          final id = p['_id']?.toString() ?? p['id']?.toString() ?? '';
          final fName = p['firstName']?.toString() ?? '';
          final lName = p['lastName']?.toString() ?? '';
          String name = '$fName $lName'.trim();
          if (name.isEmpty) name = p['name']?.toString() ?? 'Unknown';

          final number =
              p['playerNumber']?.toString() ?? p['number']?.toString() ?? '00';
          final position = p['position']?.toString() ?? 'Player';
          final image = p['image']?.toString() ?? p['profileImage']?.toString();

          // Find stats
          PlayerStatModel? stats;
          if (teamStats != null && teamStats.playerStats.isNotEmpty) {
            try {
              stats = teamStats.playerStats.firstWhere((s) => s.playerId == id);
            } catch (e) {
              // not found
            }
          }

          return _PlayerStatsData(
            id: id,
            number: number.startsWith('#') ? number : '#$number',
            name: name,
            position: position,
            teamName: teamName,
            imageUrl: image,
            stats:
                stats ??
                PlayerStatModel(
                  playerId: id,
                  playerName: name,
                  image: image ?? '',
                ),
          );
        })
        .whereType<_PlayerStatsData>()
        .toList();
  }

  Widget _buildPlayerStatsCard(
    BuildContext context,
    _PlayerStatsData player,
    GameTabsProvider provider,
  ) {
    final isExpanded = provider.isPlayerExpanded(player.id);
    final stats = player.stats;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              provider.togglePlayerExpansion(player.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlayerDetailScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child:
                            player.imageUrl != null &&
                                player.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: player.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.person,
                                      color: Color(0xFF9CA3AF),
                                      size: 24,
                                    ),
                              )
                            : const Icon(
                                Icons.person,
                                color: Color(0xFF6B7280),
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${player.number} — ${player.name}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Position: ${player.position}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Team: ${player.teamName}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Player Stats Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                      Icon(
                        Icons.file_download_outlined,
                        size: 20,
                        color: Colors.blue[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Catches', '${stats.catches}'),
                  _buildStatRow('Catches Yrds', '${stats.catchesYards}'),
                  _buildStatRow('Rushes', '${stats.rushes}'),
                  _buildStatRow('Rushes Yrds', '${stats.rushesYards}'),
                  _buildStatRow('Pass Attempts', '${stats.passAttempts}'),
                  _buildStatRow('Pass Yrds', '${stats.passYards}'),
                  _buildStatRow('Completions', '${stats.completions}'),
                  _buildStatRow('TD\'s', '${stats.tds}'),
                  _buildStatRow('Flag Pull', '${stats.flagPull}'),
                  _buildStatRow('Sack', '${stats.sack}'),
                  _buildStatRow('INT', '${stats.interceptions}'),
                  _buildStatRow('Safety', '${stats.safety}'),
                  _buildStatRow(
                    'Conversion Points',
                    '${stats.conversionPoints}',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _PlayerStatsData {
  final String id;
  final String number;
  final String name;
  final String position;
  final String teamName;
  final String? imageUrl;
  final PlayerStatModel stats;

  _PlayerStatsData({
    required this.id,
    required this.number,
    required this.name,
    required this.position,
    required this.teamName,
    this.imageUrl,
    required this.stats,
  });
}
