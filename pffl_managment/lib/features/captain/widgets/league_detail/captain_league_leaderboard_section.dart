import 'package:flutter/material.dart';
import 'package:pffl_managment/features/captain/providers/captain_league_detail_provider.dart';
import 'package:provider/provider.dart';

class CaptainLeagueLeaderboardSection extends StatelessWidget {
  const CaptainLeagueLeaderboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptainLeagueDetailProvider>(
      builder: (context, provider, child) {
        final leaderboard = provider.getLeaderboard();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (leaderboard.isEmpty)
                const Center(
                  child: Text(
                    'No leaderboard data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Column(
                  children: leaderboard.map((team) {
                    final isMyTeam = team.teamName == 'My Team';
                    return _buildLeaderboardItem(context, team, isMyTeam);
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, dynamic team, bool isMyTeam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMyTeam ? const Color(0xFFDBEAFE) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMyTeam ? const Color(0xFF3B82F6) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankColor(team.rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                team.rank.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              team.teamName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isMyTeam ? FontWeight.bold : FontWeight.normal,
                color: isMyTeam ? const Color(0xFF3B82F6) : Colors.black,
              ),
            ),
          ),
          Text(
            '${team.wins}W - ${team.losses}L',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF9CA3AF); // Grey
    }
  }
}