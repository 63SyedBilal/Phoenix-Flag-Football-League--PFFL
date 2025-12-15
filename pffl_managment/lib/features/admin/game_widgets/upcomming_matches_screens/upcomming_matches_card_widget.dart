import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';
// Assuming AppAdminIcons is here or exported
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/provider/upcoming_games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/upcomming_matches_screens/edit_upcoming_games_screen.dart';

class UpcommingMatchesCardWidget extends StatelessWidget {
  final MatchModel match;

  const UpcommingMatchesCardWidget({super.key, required this.match});

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                match.leagueName,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              SvgIcons.icon1(size: 12, color: colorScheme.onSurface),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TeamWidget(
                teamName: match.homeTeam,
                teamLogo: match.homeTeamLogo,
              ),
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
              TeamWidget(
                teamName: match.awayTeam,
                teamLogo: match.awayTeamLogo,
                isAway: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(16),
                    child: ChangeNotifierProvider(
                      create: (_) {
                        final provider = UpcomingGamesProvider();
                        // Initialize without league first, then load match
                        provider.initializeWithoutLeague();
                        provider.loadMatch(match);
                        return provider;
                      },
                      child: const EditUpcomingGamesScreen(),
                    ),
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Game',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                SvgIcons.icon1(size: 12, color: colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeamWidget extends StatelessWidget {
  final String teamName;
  final String teamLogo;
  final bool isAway;

  const TeamWidget({
    super.key,
    required this.teamName,
    required this.teamLogo,
    this.isAway = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 100,
      child: Row(
        mainAxisAlignment: isAway
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
                child: Image.network(
                  teamLogo,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons
                            .sports_football, // Fallback icon if AppAdminIcons is missing
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
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
                child: Image.network(
                  teamLogo,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.sports_football, // Fallback icon
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
