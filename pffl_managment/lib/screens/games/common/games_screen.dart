import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/games/common/games_provider.dart';
import 'package:pffl_managment/screens/games/widgets/game_filter_tabs.dart';
import 'package:pffl_managment/screens/games/widgets/role_based_game_card.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GamesProvider>(
      builder: (context, gamesProvider, child) {
        // Initialize provider on first build
        if (!gamesProvider.isLoading && 
            gamesProvider.leagues.isEmpty && 
            gamesProvider.allMatches.isEmpty &&
            gamesProvider.errorMessage == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            gamesProvider.initialize();
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Show filter tabs only if not loading and no error
                if (!gamesProvider.isLoading && gamesProvider.errorMessage == null)
                  GameFilterTabs(
                    filters: gamesProvider.availableFilters,
                    selectedFilter: gamesProvider.selectedFilter,
                    onFilterSelected: (filter) {
                      gamesProvider.selectFilter(filter);
                    },
                  ),
                const SizedBox(height: 18),
                // Loading state
                if (gamesProvider.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                // Error state
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
                // Empty state
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
                // Games list
                else
                  Expanded(
                    child: Column(
                      children: [
                        // Team filter indicator (if active)
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
                              return RoleBasedGameCard(
                                match: gamesProvider.filteredMatches[index],
                                userRole: gamesProvider.userRole,
                                canEdit: gamesProvider.canEdit,
                                shouldShowPaymentPrompt:
                                    gamesProvider.shouldShowPaymentPrompt,
                                onPayLeagueFee: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Navigate to payment screen'),
                                    ),
                                  );
                                },
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
