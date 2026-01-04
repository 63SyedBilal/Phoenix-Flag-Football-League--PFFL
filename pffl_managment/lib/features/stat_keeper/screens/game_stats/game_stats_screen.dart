import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/dotted_border_widget.dart';
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
        appBar: AppBar(leading: ArrowBackButton()),
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
        appBar: AppBar(leading: ArrowBackButton()),
        body: const Center(child: Text('No stats available')),
      );
    }

    return Scaffold(
      appBar: AppBar(leading: ArrowBackButton()),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildLeagueHeader(stats.leagueName),
                  const SizedBox(height: 8),
                  _buildScoreCards(context, provider, stats),
                  const SizedBox(height: 16),
                  _buildTeamStats(context, provider, stats),
                  const SizedBox(height: 24),
                  _buildDetailsButton(context, provider, stats),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueHeader(String leagueName) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: DottedBorderWidget(
                shape: DottedBorderShape.circle,
                strokeWidth: 1,
                dashWidth: 2,
                dashSpace: 2,
                color: const Color(0xFF000000).withValues(alpha: 0.5),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/league_logo.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Center(
                          child: Icon(
                            Icons.shield,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
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
                    leagueName.isNotEmpty ? leagueName : 'League Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            'View all Stats game summary of this league assigned game.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "Lato",
              color: Colors.grey[600],
            ),
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
    final bgColor = isSelected ? const Color(0xFF0C1232) : Colors.white;
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      score,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Lato",
                        color: textColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
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
