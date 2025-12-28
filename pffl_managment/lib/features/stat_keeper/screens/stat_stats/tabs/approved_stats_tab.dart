import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/widgets/team_stat_card.dart';
import 'package:pffl_managment/features/stat_keeper/screens/approved_stats/approved_stats_screen.dart';

class ApprovedStatsTab extends StatelessWidget {
  const ApprovedStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatStatsProvider>(
      builder: (context, provider, child) {
        final stats = provider.approvedStats;

        return Column(
          children: [
            // View All Approved Stats Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ApprovedStatsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics, size: 20),
                label: const Text('View All Approved Stats (All Leagues)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Divider with text
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Approved Stats for Selected Match',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            // Match-specific approved stats
            Expanded(
              child: stats.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No approved stats for this match',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Stats will appear here once they are approved by the admin.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: stats.length,
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        return TeamStatCard(gameStat: stat, isDraft: false);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
