import 'package:flutter/material.dart';
import 'package:pffl_managment/features/captain/providers/captain_league_detail_provider.dart';
import 'package:provider/provider.dart';

class CaptainLeagueTeamStatsSection extends StatelessWidget {
  const CaptainLeagueTeamStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptainLeagueDetailProvider>(
      builder: (context, provider, child) {
        final stats = provider.getTeamStats();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Team Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (stats.isEmpty)
                const Center(
                  child: Text(
                    'No team stats data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Column(
                  children: stats.map((stat) {
                    return _buildStatCard(context, stat);
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, dynamic stat) {
    final isMyTeam = stat.teamName == 'My Team';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stat.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stat.teamName.substring(0, 1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: stat.backgroundColor,
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
                  stat.teamName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stat.statValue} ${stat.statLabel}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (isMyTeam)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'My Team',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}