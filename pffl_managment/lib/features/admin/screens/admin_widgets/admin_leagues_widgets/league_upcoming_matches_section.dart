import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/features/admin/game_widgets/upcomming_matches_screens/upcomming_matches_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/screens/all_matches_screen.dart';

class LeagueUpcomingMatchesSection extends StatelessWidget {
  const LeagueUpcomingMatchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedGamesProvider>(
      builder: (context, gamesProvider, child) {
        final matches = gamesProvider.upcomingGames;

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              // Add View More row at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Matches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  if (matches.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        // Navigate to full list of matches
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllMatchesScreen(matches: matches),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'View more',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Display only first 3 matches (as per project requirement)
              ...matches.take(3).map(
                (match) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: UpcommingMatchesCardWidget(match: match),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}