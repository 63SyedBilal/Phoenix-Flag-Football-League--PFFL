import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/features/admin/screens/all_matches_screen.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

// Helper function to build team widget
Widget _buildTeamWidget(BuildContext context, String teamName, String teamLogo, bool isAway) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return SizedBox(
    width: 100,
    child: Row(
      mainAxisAlignment:
          isAway ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isAway) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: ClipOval(
              child: teamLogo.isNotEmpty
                  ? Image.network(
                      teamLogo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.sports_football,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.sports_football,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          teamName,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (isAway) ...[
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: ClipOval(
              child: teamLogo.isNotEmpty
                  ? Image.network(
                      teamLogo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.sports_football,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.sports_football,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        ],
      ],
    ),
  );
}

// Modified card widget that doesn't show league name
class UpcommingGamesCardWidget extends StatelessWidget {
  final MatchModel match;

  const UpcommingGamesCardWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed league name display - only showing the teams and match details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamWidget(context, match.homeTeam, match.homeTeamLogo, false),
              Column(
                children: [
                  Text(
                    match.date,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    match.time,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              _buildTeamWidget(context, match.awayTeam, match.awayTeamLogo, true),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          // Keeping the edit functionality simpler without the dialog
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Game',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Icon(Icons.edit, size: 16, color: colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class UpcommingGames extends StatelessWidget {
  const UpcommingGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedGamesProvider>(
      builder: (context, gamesProvider, child) {
        // Always trigger data fetch on first build to ensure fresh data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (gamesProvider.allGames.isEmpty && !gamesProvider.isLoading) {
            debugPrint('🔄 UpcommingGames: Triggering data fetch...');
            gamesProvider.fetchAllMatches();
          }
        });

        final matches = gamesProvider.upcomingGames;
        
        // Debug print to check data
        debugPrint('🔍 UpcommingGames Widget Build:');
        debugPrint('   - Total games in provider: ${gamesProvider.allGames.length}');
        debugPrint('   - Upcoming games: ${matches.length}');
        debugPrint('   - Is loading: ${gamesProvider.isLoading}');
        debugPrint('   - Error: ${gamesProvider.errorMessage}');
        
        if (matches.isNotEmpty) {
          debugPrint('   - First upcoming game: ${matches.first.homeTeam} vs ${matches.first.awayTeam}');
          debugPrint('   - First game date: ${matches.first.matchDateTime}');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upcoming Games', style: AppTextStyles.headlineSmall),
                if (matches.isNotEmpty)
                  GestureDetector(
                    onTap: () {
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
            const SizedBox(height: 18),
            if (matches.isEmpty)
              _buildEmptyState(context)
            else
              ...matches.take(3).map(
                (match) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: UpcommingGamesCardWidget(match: match),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Games',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no upcoming games scheduled at the moment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}