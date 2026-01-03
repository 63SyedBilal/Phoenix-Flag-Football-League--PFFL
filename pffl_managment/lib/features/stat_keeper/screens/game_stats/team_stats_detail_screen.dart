import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';

// Provider
class TeamStatsProvider extends ChangeNotifier {
  String _selectedTab = 'Team Stats';

  String get selectedTab => _selectedTab;

  void selectTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}

// Main Screen
class TeamStatsDetailScreen extends StatelessWidget {
  final TeamStatModel teamStats;
  final bool isWinner;

  const TeamStatsDetailScreen({
    super.key,
    required this.teamStats,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamStatsProvider(),
      child: _TeamStatsDetailView(teamStats: teamStats, isWinner: isWinner),
    );
  }
}

class _TeamStatsDetailView extends StatelessWidget {
  final TeamStatModel teamStats;
  final bool isWinner;

  const _TeamStatsDetailView({required this.teamStats, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeamStatsProvider>(context);

    // Filter players who have any stats (optional, but cleaner)
    // For now show all players in the list even if stats are 0
    // But since valid stats list comes from backend, it might only contain those with stats?
    // The parsing logic in StatKeeperRepository might include all players if backend sends them.
    // Let's rely on what's in teamStats.playerStats.

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: ArrowBackButton(),),
      body: SafeArea(
        child: Column(
          children: [
           
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildTeamHeader(),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 24),
                  provider.selectedTab == 'Team Stats'
                      ? _buildTeamStats()
                      : _buildPlayerStats(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTeamHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: ClipOval(
            child: teamStats.teamLogo.isNotEmpty
                ? Image.network(
                    teamStats.teamLogo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.shield, size: 24, color: Colors.grey),
                  )
                : const Icon(Icons.shield, size: 24, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            teamStats.teamName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isWinner)
          const Text(
            'winner',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFBBF24),
            ),
          ),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'View all Stats game summary of this league assigned game.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Consumer<TeamStatsProvider>(
          builder: (context, provider, _) {
            return Row(
              children: [
                _buildTabButton('Team Stats', provider),
                const SizedBox(width: 12),
                _buildTabButton('Players Stats', provider),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, TeamStatsProvider provider) {
    final isSelected = provider.selectedTab == title;
    return GestureDetector(
      onTap: () => provider.selectTab(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF000000),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamStats() {
    final statList = [
      {'label': 'Catches', 'value': teamStats.catches.toString()},
      {'label': 'Catches Yrds', 'value': teamStats.catchesYards.toString()},
      {'label': 'Rushes', 'value': teamStats.rushes.toString()},
      {'label': 'Rushes Yrds', 'value': teamStats.rushesYards.toString()},
      {'label': 'Pass Attempts', 'value': teamStats.passAttempts.toString()},
      {'label': 'Pass Yrds', 'value': teamStats.passYards.toString()},
      {'label': 'Completions', 'value': teamStats.completions.toString()},
      {'label': 'TD\'s', 'value': teamStats.tds.toString()},
      {'label': 'Flag Pull', 'value': teamStats.flagPull.toString()},
      {'label': 'Sack', 'value': teamStats.sack.toString()},
      {'label': 'INT', 'value': teamStats.interceptions.toString()},
      {'label': 'Safety', 'value': teamStats.safety.toString()},
      {
        'label': 'Conversion Points',
        'value': teamStats.conversionPoints.toString(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Team Statistics',
              style: TextStyle(
                fontSize: 16,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: statList.asMap().entries.map((entry) {
              final index = entry.key;
              final stat = entry.value;
              final isLast = index == statList.length - 1;
              return _buildStatRow(
                stat['label']!,
                stat['value']!,
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerStats() {
    final players = teamStats.playerStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Player Statistics',
              style: TextStyle(
                fontSize: 16,
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
        if (players.isEmpty) const Text('No player stats available'),

        ...players
            .map(
              (player) => _buildPlayerCard(
                player.playerName,
                'Player', // Position not in PlayerStatModel currently, but PlayerModel has it.
                // We might need to update PlayerStatModel to include position or fetch it.
                // For now, default to 'Player' or empty.
                showStats: true, // Always show stats if requested
                stats: [
                  {'label': 'Catches', 'value': player.catches.toString()},
                  {
                    'label': 'Catches Yrds',
                    'value': player.catchesYards.toString(),
                  },
                  {'label': 'Rushes', 'value': player.rushes.toString()},
                  {
                    'label': 'Rushes Yrds',
                    'value': player.rushesYards.toString(),
                  },
                  {
                    'label': 'Pass Attempts',
                    'value': player.passAttempts.toString(),
                  },
                  {'label': 'Pass Yrds', 'value': player.passYards.toString()},
                  {
                    'label': 'Completions',
                    'value': player.completions.toString(),
                  },
                  {'label': 'TD\'s', 'value': player.tds.toString()},
                  {'label': 'Flag Pull', 'value': player.flagPull.toString()},
                  {'label': 'Sack', 'value': player.sack.toString()},
                  {'label': 'INT', 'value': player.interceptions.toString()},
                  {'label': 'Safety', 'value': player.safety.toString()},
                  {
                    'label': 'Conversion Points',
                    'value': player.conversionPoints.toString(),
                  },
                ],
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildPlayerCard(
    String name,
    String position, {
    bool showStats = false,
    List<Map<String, String>>? stats,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Builder(
        builder: (context) {
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              childrenPadding: EdgeInsets.zero,
              shape: const Border(), // Remove expansion border
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Position: $position',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                if (showStats && stats != null) ...[
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Player Stats Summary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: stats.asMap().entries.map((entry) {
                              final index = entry.key;
                              final stat = entry.value;
                              final isLast = index == stats.length - 1;
                              return _buildStatRow(
                                stat['label']!,
                                stat['value']!,
                                isLast: isLast,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No stats available'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isLast = false}) {
    // Helper to format values if needed (currently strings)
    // Could add formatting logic here if needed.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        if (!isLast)
          const Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
} // End class
