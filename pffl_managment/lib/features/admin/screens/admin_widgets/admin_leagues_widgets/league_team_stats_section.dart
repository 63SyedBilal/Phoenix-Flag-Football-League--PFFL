import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_team_stat_card.dart';
import 'package:provider/provider.dart';

class LeagueTeamStatsSection extends StatelessWidget {
  const LeagueTeamStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeagueDetailProvider>();
    final stats = provider.getTeamStats();
    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:   Text(
            'Team Stats',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(
              fontFamily: 'Lato',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827)),
          ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: stats.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return LeagueTeamStatCard(teamStat: stats[index], index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
