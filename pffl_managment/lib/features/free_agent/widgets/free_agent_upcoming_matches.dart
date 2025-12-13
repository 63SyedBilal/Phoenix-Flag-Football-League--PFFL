import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import '../providers/free_agent_dashboard_provider.dart';

class FreeAgentUpcomingMatches extends StatelessWidget {
  const FreeAgentUpcomingMatches({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<FreeAgentDashboardProvider>(context);
    final games = dashboardProvider.upcomingGames;

    return SharedUpcomingMatches(
      games: games,
      onViewMore: () {
      },
    );
  }
}