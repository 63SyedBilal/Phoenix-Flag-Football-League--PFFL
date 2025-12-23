import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_tabs_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlayersTab extends StatelessWidget {
  const PlayersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameTabsProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final homeName = provider.match.homeTeam;
    final awayName = provider.match.awayTeam;

    final homeStats = provider.match.homeTeamStats;
    final awayStats = provider.match.awayTeamStats;

    final homePlayers = _getPlayers(
      provider.homeTeamDetails,
      provider.match.format,
      homeStats?.playerStats.map((e) => e.playerId).toSet() ?? {},
    );
    final awayPlayers = _getPlayers(
      provider.awayTeamDetails,
      provider.match.format,
      awayStats?.playerStats.map((e) => e.playerId).toSet() ?? {},
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (homePlayers.isNotEmpty)
                    _buildTeamSection(homeName, homePlayers),
                  if (homePlayers.isNotEmpty && awayPlayers.isNotEmpty)
                    const SizedBox(height: 24),
                  if (awayPlayers.isNotEmpty)
                    _buildTeamSection(awayName, awayPlayers),
                  if (homePlayers.isEmpty && awayPlayers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No players found for this match.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_PlayerData> _getPlayers(
    Map<String, dynamic>? details,
    String? format,
    Set<String> activeIds,
  ) {
    if (details == null) return [];

    // Determine squad Key
    String squadKey = 'squad5v5';
    if (format == '7v7') squadKey = 'squad7v7';
    // If format is generic or null, try both or prefer one.
    // Let's check if 7v7 key exists and has items, otherwise valid.

    List squad = details[squadKey] as List? ?? [];
    if (squad.isEmpty && squadKey == 'squad5v5') {
      squad = details['squad7v7'] as List? ?? [];
    }
    // Also check generic 'players' if others fail
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

          // Check if active (played in this match)
          // If roster data has 'isPresent' or similar for this game context (unlikely in team endpoint),
          // we rely on stats presence.
          final isActive = activeIds.contains(id);

          return _PlayerData(
            number: number.startsWith('#') ? number : '#$number',
            name: name,
            position: position,
            status: isActive ? 'Active' : 'Resting',
            imageUrl: image,
          );
        })
        .whereType<_PlayerData>()
        .toList();
  }

  Widget _buildTeamSection(String teamName, List<_PlayerData> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            teamName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
        ),
        ...players.map(
          (player) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildPlayerCard(player),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(_PlayerData player) {
    final isActive = player.status == 'Active';

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: player.imageUrl != null && player.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: player.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  )
                : const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${player.number} ${player.name}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Position: ${player.position}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E293B) : const Color(0xFF9CA3AF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            player.status,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerData {
  final String number;
  final String name;
  final String position;
  final String status;
  final String? imageUrl;

  _PlayerData({
    required this.number,
    required this.name,
    required this.position,
    required this.status,
    this.imageUrl,
  });
}
