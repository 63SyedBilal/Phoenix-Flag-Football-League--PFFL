import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/captain_provider/home_screen_provider/captain_dashboard_provider.dart';
import 'package:pffl_managment/features/captain/providers/captain_team_provider.dart';

class CaptainUpcomingMatches extends StatelessWidget {
  const CaptainUpcomingMatches({super.key});

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<CaptainTeamProvider>(context, listen: false);
    final dashboardProvider = Provider.of<CaptainDashboardProvider>(context, listen: false);
    
    // Always show the games, even if team data is loading
    final allGames = dashboardProvider.upcomingGames;
    
    // Debug information
    print('Total games available: ${allGames.length}');
    print('Team provider loading state: ${teamProvider.isLoading}');
    
    // If no games, show a message
    if (allGames.isEmpty) {
      print('No games available');
      return const Center(
        child: Text('No upcoming games available'),
      );
    }
    
    // Get the captain's team name
    final team = teamProvider.team;
    if (team == null) {
      print('No team data available, showing all games');
      return SharedUpcomingMatches(
        games: allGames,
        maxVisibleGames: 3,
        title: 'Upcoming Games',
        onViewMore: () {
          // Handle view more action
        },
      );
    }
    
    print('Captain team name: ${team.name}');
    print('Selected format: ${teamProvider.selectedFormat}');
    
    // Filter games where captain's team is playing
    final captainTeamName = team.name;
    final captainGames = allGames.where((game) {
      final isMatch = game.team1Name == captainTeamName || game.team2Name == captainTeamName;
      print('Game ${game.id}: ${game.team1Name} vs ${game.team2Name} - Match: $isMatch');
      return isMatch;
    }).toList();
    
    print('Filtered games count: ${captainGames.length}');
    
    // Always show the filtered games
    return SharedUpcomingMatches(
      games: captainGames.isEmpty ? allGames : captainGames,
      maxVisibleGames: 3,
      title: 'Upcoming Games',
      onViewMore: () {
        // Handle view more action
      },
    );
  }
}