import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_active_leagues_provider.dart';
import 'package:pffl_managment/features/free_agent/widgets/free_agent_league_selection_card.dart';
import 'package:pffl_managment/routes/app_routes.dart';

/// Screen for Free Agent to view and select active leagues
/// Matches the design from the provided image
class FreeAgentActiveLeaguesScreen extends StatelessWidget {
  const FreeAgentActiveLeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => FreeAgentActiveLeaguesProvider()..fetchActiveLeagues(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ArrowBackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
        ),
        body: SafeArea(
          child: Consumer<FreeAgentActiveLeaguesProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          "Get Ready for Upcoming Leagues!",
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Select upcoming leagues and pay in advance to confirm your spot.",
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        // Section title with progress indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Select League",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "1/8",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Leagues list
                  Expanded(child: _buildLeaguesList(context, provider, theme)),
                  // Bottom buttons section
                  _buildBottomSection(context, provider, theme),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLeaguesList(
    BuildContext context,
    FreeAgentActiveLeaguesProvider provider,
    ThemeData theme,
  ) {
    // Loading state
    if (provider.isLoading && provider.activeLeagues.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (provider.errorMessage != null && provider.activeLeagues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchActiveLeagues(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (provider.activeLeagues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No active leagues available',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    // Leagues list
    return RefreshIndicator(
      onRefresh: () => provider.refreshLeagues(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ...provider.activeLeagues.map(
              (league) => FreeAgentLeagueSelectionCard(
                league: league,
                isSelected: provider.isLeagueSelected(league.id),
                onTap: () {
                  // Navigate to league detail or handle tap
                },
                onSelectionToggle: () {
                  provider.toggleLeagueSelection(league.id);
                },
                onShowMore: () {
                  // Navigate to league detail
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    FreeAgentActiveLeaguesProvider provider,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Proceed to Payment button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Proceed to Payment',
              backgroundColor: provider.hasSelectedLeagues
                  ? AppColors.primaryColor
                  : const Color(0xFF9CA3AF), // Disabled color
              textColor: Colors.white,
              onPressed: provider.hasSelectedLeagues
                  ? () => _handleProceedToPayment(context, provider)
                  : () {},
            ),
          ),
          const SizedBox(height: 12),
          // Skip link
          GestureDetector(
            onTap: () => _handleSkip(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Skip',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280), // Text secondary
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Color(0xFF6B7280), // Text secondary
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleProceedToPayment(
    BuildContext context,
    FreeAgentActiveLeaguesProvider provider,
  ) {
    // TODO: Navigate to payment screen with selected leagues
    // For now, navigate to dashboard
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.freeAgentDashboard, (route) => false);
  }

  void _handleSkip(BuildContext context) {
    // Navigate to Free Agent dashboard
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.freeAgentDashboard, (route) => false);
  }
}
