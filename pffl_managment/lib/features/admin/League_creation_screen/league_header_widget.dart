import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class LeagueHeaderWidget extends StatelessWidget {
  const LeagueHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);

    String title = _getTitleForStep(viewModel.currentStep);
    String subtitle = _getSubtitleForStep(viewModel.currentStep);
    final bool showSkipButton =
        viewModel.currentStep > 0 && viewModel.currentStep < 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.titleSmall.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (showSkipButton)
            GestureDetector(
              onTap: () {
                viewModel.nextStep();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skip',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_sharp,
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTitleForStep(int step) {
    switch (step) {
      case 0:
        return 'Create League';
      case 1:
        return 'Invite Referees';
      case 2:
        return 'Invite Stat Keepers';
      case 3:
        return 'Invite Teams';
      default:
        return 'Create League';
    }
  }

  String _getSubtitleForStep(int step) {
    switch (step) {
      case 0:
        return 'Enter league information below to create a new tournament.';
      case 1:
        return 'Choose referees for this league. You can invite new referees or select from existing ones.';
      case 2:
        return 'Choose Stat Keepers for this league. You can invite new Stat Keepers or select from existing ones.';
      case 3:
        return 'Invite teams to join this league. You can search existing teams.';
      default:
        return 'Enter league information below to create a new tournament.';
    }
  }
}
