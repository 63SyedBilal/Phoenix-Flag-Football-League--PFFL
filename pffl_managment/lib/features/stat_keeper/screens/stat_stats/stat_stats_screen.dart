import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/tabs/all_stats_tab.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/tabs/draft_stats_tab.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/tabs/approved_stats_tab.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/widgets/stats_search_bar.dart';

class StatStatsScreen extends StatelessWidget {
  const StatStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider is now provided by the dashboard, so we just watch it
    final provider = context.watch<StatStatsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 16),
              child: StatsSearchBar(
                searchQuery: provider.searchQuery,
                onSearchChanged: (query) {
                  provider.setSearchQuery(query);
                },
                onFilterTap: () {},
              ),
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      context,
                      title: 'All Stats',
                      isSelected: provider.currentTabIndex == 0,
                      onTap: () => provider.setTabIndex(0),
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      context,
                      title: 'Draft Stats',
                      isSelected: provider.currentTabIndex == 1,
                      onTap: () => provider.setTabIndex(1),
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      context,
                      title: 'Approved Stats',
                      isSelected: provider.currentTabIndex == 2,
                      onTap: () => provider.setTabIndex(2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildTabContent(provider.currentTabIndex)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2), // Minimal gap
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return const AllStatsTab();
      case 1:
        return const DraftStatsTab();
      case 2:
        return const ApprovedStatsTab();
      default:
        return const AllStatsTab();
    }
  }
}
