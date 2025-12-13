import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/features/captain/providers/captain_dashboard_provider.dart';

class CaptainUpcomingMatches extends StatelessWidget {
  const CaptainUpcomingMatches({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<CaptainDashboardProvider>(context);
    final games = dashboardProvider.upcomingGames;

    return SharedUpcomingMatches(
      games: games,
      onViewMore: () {
        // Handle view more action
      },
    );
  }
}
