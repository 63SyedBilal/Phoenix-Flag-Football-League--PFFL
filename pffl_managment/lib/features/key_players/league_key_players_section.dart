import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_player_card.dart';
import 'package:provider/provider.dart';

class LeagueKeyPlayersSection extends StatelessWidget {
  const LeagueKeyPlayersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeagueDetailProvider>();
    final players = provider.getKeyPlayers();
    if (players.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Players',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: players.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                return LeaguePlayerCard(player: players[index], index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
