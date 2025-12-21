import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_game_card.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/referee/providers/referee_dashboard_provider.dart';
import 'package:pffl_managment/core/utils/game_navigation_helper.dart';

class RefereeHomeScreen extends StatelessWidget {
  const RefereeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<RefereeDashboardProvider>(context);
    final games = dashboardProvider.upcomingGames;
    final assignedGames = games.where((game) => game.isMyGame).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Assigned Games For You",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    if (assignedGames.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllMatchesScreen(
                                matches: assignedGames,
                                title: 'Assigned Games',
                              ),
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
                      )
                    else
                      Row(
                        children: [
                          Text(
                            'View more',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (assignedGames.isNotEmpty)
                  SharedGameCard(
                    game: assignedGames[0],
                    showYourGameTag: true,
                    onTap: () => GameNavigationHelper.navigateToGameDetail(
                      context,
                      assignedGames[0],
                    ),
                  )
                else
                  const Text('No games assigned to you yet.'),
                const SizedBox(height: 8),
                  SharedUpcomingMatches(
                  games: games,
                  maxVisibleGames: 3, // Show 3 games as before
                  title: 'Upcoming Games',
                  onGameTap: (game) => GameNavigationHelper.navigateToGameDetail(
                    context,
                    game,
                  ),
                  onViewMore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllMatchesScreen(
                          matches: games,
                          title: 'Upcoming Games',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SponsorBannerScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}