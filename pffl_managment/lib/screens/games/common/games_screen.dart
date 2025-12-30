import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/games/common/games_provider.dart';
import 'package:pffl_managment/screens/games/widgets/game_filter_tabs.dart';
import 'package:pffl_managment/screens/games/widgets/role_based_game_card.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/captain/providers/league_payment_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    final userRole = authProvider.userRole.toLowerCase();
    final isCaptain = userRole == 'captain';
    final isPlayer = userRole == 'player';

    return Consumer2<GamesProvider, LeaguePaymentProvider>(
      builder: (context, gamesProvider, paymentProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!gamesProvider.isLoading &&
              gamesProvider.leagues.isEmpty &&
              gamesProvider.allMatches.isEmpty &&
              gamesProvider.errorMessage == null) {
            gamesProvider.initialize();
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (!gamesProvider.isLoading &&
                    gamesProvider.errorMessage == null)
                  GameFilterTabs(
                    filters: gamesProvider.availableFilters,
                    selectedFilter: gamesProvider.selectedFilter,
                    onFilterSelected: (filter) {
                      gamesProvider.selectFilter(filter);
                    },
                  ),
                const SizedBox(height: 18),
                if (gamesProvider.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (gamesProvider.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            gamesProvider.errorMessage!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => gamesProvider.refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (gamesProvider.filteredMatches.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        gamesProvider.selectedTeamId != null
                            ? 'No games found for selected team'
                            : 'No games scheduled yet',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        if (gamesProvider.selectedTeamId != null)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Filtered by team',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => gamesProvider.clearTeamFilter(),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (gamesProvider.selectedTeamId != null)
                          const SizedBox(height: 12),
                        // Games list
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: gamesProvider.filteredMatches.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final match =
                                  gamesProvider.filteredMatches[index];
                              bool shouldShowPaymentPrompt = false;

                              if ((isCaptain || isPlayer) &&
                                  match.leagueId != null &&
                                  userId.isNotEmpty) {
                                final hasPaid =
                                    paymentProvider.getCachedPaymentStatus(
                                      match.leagueId!,
                                      userId,
                                    ) ??
                                    false;
                                shouldShowPaymentPrompt = !hasPaid;

                                // Trigger load if not in cache
                                if (paymentProvider.getCachedPaymentStatus(
                                      match.leagueId!,
                                      userId,
                                    ) ==
                                    null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    paymentProvider.checkLeaguePaymentStatus(
                                      match.leagueId!,
                                      userId,
                                    );
                                  });
                                }
                              }

                              return RoleBasedGameCard(
                                match: match,
                                userRole: userRole,
                                canEdit: gamesProvider.canEdit,
                                shouldShowPaymentPrompt:
                                    shouldShowPaymentPrompt,
                                onPayLeagueFee: shouldShowPaymentPrompt
                                    ? () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.freeAgentPaymentHistory,
                                        );
                                      }
                                    : null,
                                onTeamTap: (teamId) {
                                  gamesProvider.selectTeam(teamId);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
