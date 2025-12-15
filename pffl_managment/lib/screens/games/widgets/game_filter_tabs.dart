import 'package:flutter/material.dart';

/// Role-based filter tabs widget
/// Shows league tabs for Admin, date tabs for other roles
class GameFilterTabs extends StatelessWidget {
  final List<Map<String, String>> filters;
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const GameFilterTabs({
    Key? key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
