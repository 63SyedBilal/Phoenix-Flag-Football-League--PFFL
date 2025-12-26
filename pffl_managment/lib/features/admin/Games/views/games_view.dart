import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/Games/widgets/game_card_widget.dart';
import 'package:pffl_managment/features/admin/Games/providers/matches_provider.dart';
import 'package:provider/provider.dart';

class GamesView extends StatelessWidget {
  const GamesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Consumer<MatchesProvider>(
              builder: (context, viewModel, child) {
                return _LeagueFilterTabs(
                  selectedFilter: viewModel.selectedFilter,
                  onFilterSelected: (filter) {
                    viewModel.selectFilter(filter);
                  },
                );
              },
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Consumer<MatchesProvider>(
                builder: (context, viewModel, child) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: viewModel.filteredMatches.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return GameCardWidget(
                        match: viewModel.filteredMatches[index],
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
  }
}

class _LeagueFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const _LeagueFilterTabs({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> filters = [
      {'id': 'all', 'label': 'All Games'},
      {'id': 'six_nations', 'label': 'Six Nations'},
      {'id': 'world_cup', 'label': 'Rugby World Cup'},
      {'id': 'super_rugby', 'label': 'Super Rugby'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['id'];

          return GestureDetector(
            onTap: () => onFilterSelected(filter['id']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF000000).withValues(alpha: 0.12),
                  width: 0.67,
                ),
              ),
              child: Center(
                child: Text(
                  filter['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
