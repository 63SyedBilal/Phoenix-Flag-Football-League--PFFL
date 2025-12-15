import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/widgets/team_stat_card.dart';

class DraftStatsTab extends StatelessWidget {
  const DraftStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatStatsProvider>(
      builder: (context, provider, child) {
        final stats = provider.draftStats;

        if (stats.isEmpty) {
          return const Center(child: Text('No draft stats available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return TeamStatCard(
              gameStat: stat,
              isDraft: true,
              onApprove: () {
                provider.approveStat(stat.id);
              },
            );
          },
        );
      },
    );
  }
}
