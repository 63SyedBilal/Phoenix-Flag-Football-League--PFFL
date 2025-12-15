import 'package:flutter/material.dart';
import 'package:pffl_managment/features/captain/providers/captain_league_detail_provider.dart';
import 'package:provider/provider.dart';

class CaptainLeagueKeyPlayersSection extends StatelessWidget {
  const CaptainLeagueKeyPlayersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptainLeagueDetailProvider>(
      builder: (context, provider, child) {
        final players = provider.getKeyPlayers();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Key Players',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (players.isEmpty)
                const Center(
                  child: Text(
                    'No key players data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: players.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _buildPlayerCard(context, players[index]);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerCard(BuildContext context, dynamic player) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            player.gradientStart,
            player.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                player.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: player.gradientStart,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            player.name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            '${player.statValue} ${player.statLabel}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}