import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/leagues/providers/league_detail_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_player_card.dart';
import 'package:provider/provider.dart';

class LeagueKeyPlayersSection extends StatelessWidget {
  const LeagueKeyPlayersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeagueDetailProvider>();
    final players = provider.getKeyPlayers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Key Players',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 90,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: players.length,
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              return LeaguePlayerCard(player: players[index], index: index);
            },
          ),
        ),
      ],
    );
  }
}