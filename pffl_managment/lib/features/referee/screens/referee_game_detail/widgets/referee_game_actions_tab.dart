import 'package:flutter/material.dart';
import 'package:pffl_managment/features/referee/providers/referee_game_detail_provider.dart';
import 'package:pffl_managment/features/referee/widgets/game_timeline_widget.dart';

class RefereeGameActionsTab extends StatelessWidget {
  const RefereeGameActionsTab({
    super.key,
    required this.provider,
    required this.onAddActionTap,
  });

  final RefereeGameDetailProvider provider;
  final VoidCallback onAddActionTap;

  @override
  Widget build(BuildContext context) {
    final timelineEntries = provider.timelineEntries;

    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: false,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        if (timelineEntries.isEmpty)
          Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: onAddActionTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.sports_score_outlined,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text(
                        'No actions recorded yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          GameTimelineWidget(
            entries: timelineEntries,
            onAddActionTap: onAddActionTap,
          ),
      ],
    );
  }
}
