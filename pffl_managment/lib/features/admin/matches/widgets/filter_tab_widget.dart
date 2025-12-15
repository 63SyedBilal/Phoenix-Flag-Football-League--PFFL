import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/matches/providers/matches_provider.dart';
import 'package:provider/provider.dart';

class FilterTabsWidget extends StatelessWidget {
  const FilterTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchesProvider>(
      builder: (context, viewModel, child) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = viewModel.filters[index];
              final isSelected = viewModel.selectedFilter == filter.id;

              return FilterTab(
                label: filter.label,
                isSelected: isSelected,
                onTap: () => viewModel.selectFilter(filter.id),
              );
            },
          ),
        );
      },
    );
  }
}

class FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : Colors.black.withValues(alpha: 0.12),
            width: isSelected ? 1 : 0.67,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
