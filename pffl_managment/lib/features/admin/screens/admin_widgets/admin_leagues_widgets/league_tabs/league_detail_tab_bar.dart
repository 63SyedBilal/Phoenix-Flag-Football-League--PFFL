import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:provider/provider.dart';

class LeagueDetailTabBar extends StatelessWidget {
  const LeagueDetailTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LeagueDetailProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildTab(
                context,
                label: 'Overview',
                index: 0,
                isSelected: provider.selectedTabIndex == 0,
                onTap: () => provider.selectTab(0),
              ),
              const SizedBox(width: 8),
              _buildTab(
                context,
                label: 'Games',
                index: 1,
                isSelected: provider.selectedTabIndex == 1,
                onTap: () => provider.selectTab(1),
              ),
              const SizedBox(width: 8),
              _buildTab(
                context,
                label: 'Leaderboard',
                index: 2,
                isSelected: provider.selectedTabIndex == 2,
                onTap: () => provider.selectTab(2),
              ),
              const SizedBox(width: 8),
              _buildTab(
                context,
                label: 'Teams',
                index: 3,
                isSelected: provider.selectedTabIndex == 3,
                onTap: () => provider.selectTab(3),
              ),
              const SizedBox(width: 8),
              _buildTab(
                context,
                label: 'Officials',
                index: 4,
                isSelected: provider.selectedTabIndex == 4,
                onTap: () => provider.selectTab(4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFD1D5DB),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
