import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/features/admin/provider/dashboard_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_home_screen_widgets/stat_card_widget.dart';
import 'package:provider/provider.dart';

import 'package:pffl_managment/features/admin/utils/admin_navigation_helper.dart';

/// Admin Overview Section displaying real-time statistics
/// Fetches data from API and handles loading/error states
class AdminOverViewSection extends StatelessWidget {
  const AdminOverViewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        // Trigger data fetch if not already fetched
        if (!viewModel.hasFetched && !viewModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.fetchDashboardStats();
          });
        }

        final stats = viewModel.statCards;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overview', style: AppTextStyles.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (viewModel.error != null && !viewModel.isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => viewModel.fetchDashboardStats(),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    stat: stats[0].copyWith(
                      onTap: () =>
                          AdminNavigationHelper.navigateToLeagues(context),
                    ),
                  ),
                ),
                Expanded(
                  child: StatCardWidget(
                    stat: stats[1].copyWith(
                      onTap: () =>
                          AdminNavigationHelper.navigateToGames(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    stat: stats[2].copyWith(
                      onTap: () =>
                          AdminNavigationHelper.navigateToUsers(context),
                    ),
                  ),
                ),
                Expanded(
                  child: StatCardWidget(
                    stat: stats[3].copyWith(
                      onTap: () =>
                          AdminNavigationHelper.navigateToPayments(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
