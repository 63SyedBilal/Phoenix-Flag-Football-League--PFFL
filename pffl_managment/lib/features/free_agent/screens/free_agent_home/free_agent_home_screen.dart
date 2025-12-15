import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_dashboard_provider.dart';

class FreeAgentHomeScreen extends StatelessWidget {
  const FreeAgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<FreeAgentDashboardProvider>(context);
    final games = dashboardProvider.upcomingGames;

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
                const SizedBox(height: 24),
                SharedUpcomingMatches(

                  games: games,
                  maxVisibleGames: 3, // Show only 3 games in main view
                  title: 'Upcoming Games',
                  onViewMore: () {
                    // Navigate to full matches list
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
                SizedBox(height: 8,),
                SponsorBannerScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}