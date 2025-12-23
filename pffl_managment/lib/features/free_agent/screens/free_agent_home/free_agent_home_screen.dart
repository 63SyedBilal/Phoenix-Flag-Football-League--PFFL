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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Consumer<FreeAgentDashboardProvider>(
          builder: (context, dashboardProvider, child) {
            return RefreshIndicator(
              onRefresh: () => dashboardProvider.refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildUpcomingGamesSection(context, dashboardProvider),
                      const SizedBox(height: 8),
                      const SponsorBannerScreen(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUpcomingGamesSection(
    BuildContext context,
    FreeAgentDashboardProvider provider,
  ) {
    // Loading state
    if (provider.isLoading && provider.upcomingGames.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Games',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    // Error state
    if (provider.error != null && provider.upcomingGames.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Games',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => provider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Empty state
    if (provider.upcomingGames.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Games',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.sports_football_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No upcoming games scheduled',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Games list
    final games = provider.upcomingGames;
    return SharedUpcomingMatches(
      games: games,
      maxVisibleGames: 3,
      title: 'Upcoming Games',
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
    );
  }
}
