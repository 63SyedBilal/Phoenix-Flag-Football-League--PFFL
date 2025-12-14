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
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                GameFilterTabs(
                  filters: gamesProvider.availableFilters,
                  selectedFilter: gamesProvider.selectedFilter,
                  onFilterSelected: (filter) {
                    gamesProvider.selectFilter(filter);
                  },
                ),
                const SizedBox(height: 18),
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
                      );
                    },
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
