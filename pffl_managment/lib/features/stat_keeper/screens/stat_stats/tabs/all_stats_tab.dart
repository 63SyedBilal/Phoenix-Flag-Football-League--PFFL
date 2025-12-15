import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/stat_keeper_navigation_provider.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/widgets/stat_card.dart';

class AllStatsTab extends StatelessWidget {
  const AllStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatStatsProvider>(
      builder: (context, provider, child) {
        final stats = provider.allStats;

        if (stats.isEmpty) {
          return const Center(child: Text('No stats available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return StatCard(
              gameStat: stat,
              onTap: () {
                // Navigate to Add Stat screen (Index 2)
                Provider.of<StatKeeperNavigationProvider>(
                  context,
                  listen: false,
                ).setIndex(2);
              },
            );
          },
        );
      },
    );
  }
}
