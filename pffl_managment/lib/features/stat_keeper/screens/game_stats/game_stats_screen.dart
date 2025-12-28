import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/providers/game_stats_provider.dart';
import 'package:pffl_managment/features/stat_keeper/screens/game_stats/team_stats_detail_screen.dart';

class GameStatsScreen extends StatelessWidget {
  final String matchId;

  const GameStatsScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameStatsProvider(matchId: matchId),
      child: const _GameStatsScreenContent(),
    );
  }
}

class _GameStatsScreenContent extends StatelessWidget {
  const _GameStatsScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameStatsProvider>();
    final stats = provider.gameStats;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Game Stats')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load game stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  provider.errorMessage!.contains('timeout')
                      ? 'Connection timeout. Please check your internet connection and try again.'
                      : provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => provider.refreshStats(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (stats == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Game Stats')),
        body: const Center(child: Text('No stats available')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildLeagueHeader(stats.leagueName),
                  const SizedBox(height: 24),
                  _buildScoreCards(context, provider, stats),
                  const SizedBox(height: 32),
                  _buildTeamStats(context, provider, stats),
                  const SizedBox(height: 24),
                  _buildDetailsButton(context, provider, stats),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueHeader(String leagueName) {
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
            child: Image.asset(
              'assets/league_logo.png', // Placeholder or use network image if available
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.shield, size: 24, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leagueName.isNotEmpty ? leagueName : 'League Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View all Stats game summary of this league assigned game.',
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
    );
  }

  Widget _buildScoreCards(
    BuildContext context,
    GameStatsProvider provider,
    GameStatModel stats,
  ) {
    // Determine winner based on score if available (not in current model, using parsed stats?)
    // GameStatModel has team1Stats and team2Stats. Let's start with TDS count as proxy or just visual selection.

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => provider.toggleTeamSelection(true),
            child: _buildTeamCard(
              teamName: stats.team1Name,
              score: stats.team1Stats.tds
                  .toString(), // Using TDs as score for now or just display
              logoAsset: stats.team1Logo,
              isWinner: false, // Calculate logic if needed
              isSelected: provider.isTeamASelected,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => provider.toggleTeamSelection(false),
            child: _buildTeamCard(
              teamName: stats.team2Name,
              score: stats.team2Stats.tds.toString(),
              logoAsset: stats.team2Logo,
              isWinner: false,
              isSelected: !provider.isTeamASelected,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard({
    required String teamName,
    required String score,
    required String logoAsset,
    required bool isWinner,
    required bool isSelected,
  }) {
    final bgColor = isSelected ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isSelected ? Colors.white : Colors.black;
    final subTextColor = isSelected ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isSelected
        ? Colors.transparent
        : const Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        teamName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Winner',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  score,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TDs', // Label for the score
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: logoAsset.isNotEmpty
                ? Image.network(
                    logoAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.shield,
                      size: 30,
                      color: isSelected ? Colors.white54 : Colors.grey,
                    ),
                  )
                : Icon(
                    Icons.shield,
                    size: 30,
                    color: isSelected ? Colors.white54 : Colors.grey,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStats(
    BuildContext context,
    GameStatsProvider provider,
    GameStatModel stats,
  ) {
    final currentStats = provider.isTeamASelected
        ? stats.team1Stats
        : stats.team2Stats;

    final statList = [
      {'label': 'Catches', 'value': currentStats.catches.toString()},
      {'label': 'Catches Yrds', 'value': currentStats.catchesYards.toString()},
      {'label': 'Rushes', 'value': currentStats.rushes.toString()},
      {'label': 'Rushes Yrds', 'value': currentStats.rushesYards.toString()},
      {'label': 'Pass Attempts', 'value': currentStats.passAttempts.toString()},
      {'label': 'Pass Yrds', 'value': currentStats.passYards.toString()},
      {'label': 'Completions', 'value': currentStats.completions.toString()},
      {'label': 'TD\'s', 'value': currentStats.tds.toString()},
      {'label': 'Flag Pull', 'value': currentStats.flagPull.toString()},
      {'label': 'Sack', 'value': currentStats.sack.toString()},
      {'label': 'INT', 'value': currentStats.interceptions.toString()},
      {'label': 'Safety', 'value': currentStats.safety.toString()},
      {
        'label': 'Conversion Points',
        'value': currentStats.conversionPoints.toString(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${currentStats.teamName} Team Stats',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000),
          ),
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

  Widget _buildStatRow(String label, String value, {bool isLast = false}) {
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

  Widget _buildDetailsButton(
    BuildContext context,
    GameStatsProvider provider,
    GameStatModel stats,
  ) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () {
            final isWinner = false;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamStatsDetailScreen(
                  teamStats: provider.isTeamASelected
                      ? stats.team1Stats
                      : stats.team2Stats,
                  isWinner: isWinner,
                ),
              ),
            );
          },
          child: const Center(
            child: Text(
              'See Stats in Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
