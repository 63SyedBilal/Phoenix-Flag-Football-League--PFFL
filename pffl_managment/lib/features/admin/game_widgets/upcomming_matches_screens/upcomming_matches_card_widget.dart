import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';
// Assuming AppAdminIcons is here or exported
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_game_widgets/edit_upcomming_matches.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';

class UpcommingMatchesCardWidget extends StatelessWidget {
  final MatchModel match;

  const UpcommingMatchesCardWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userRole = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).userRole.toLowerCase();
    final isAdmin = userRole == 'admin' || userRole == 'superadmin';

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
          if (isAdmin) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final updated = await showDialog<bool>(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: EditUpcommingMatches(match: match),
                  ),
                );
                if (updated == true && context.mounted) {
                  // Since this uses UpcomingGamesProvider in its original code,
                  // but EditUpcommingMatches uses MatchService directly,
                  // we might need to refresh whatever provider is managing the main view.
                  // Usually these screens are wrapped in a provider.
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Game',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff0F173E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xff0F173E),
                    size: 6,
                  ),
                ],
              ),
            ),
          ],
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
}
