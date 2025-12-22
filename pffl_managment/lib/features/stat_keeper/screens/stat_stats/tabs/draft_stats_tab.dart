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

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  return TeamStatCard(
                    gameStat: stat,
                    isDraft: true,
                    onApprove: () {
                      // Individual approval removed in favor of match-wide submission
                      // but keeping for UI compatibility if needed
                    },
                  );
                },
              ),
            ),

            // Submit for Approval Button (Requirement #4)
            if (stats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: provider.isSubmitting
                        ? null
                        : () => _showSubmitConfirmation(context, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit for Approval',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showSubmitConfirmation(
    BuildContext context,
    StatStatsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Stats'),
        content: const Text(
          'Are you sure you want to submit all draft stats for approval? You won\'t be able to edit them until they are reviewed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.submitForApproval();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
