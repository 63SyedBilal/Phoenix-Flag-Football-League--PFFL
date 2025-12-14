import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class LeagueHeaderWidget extends StatelessWidget {
  const LeagueHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    
    String title = _getTitleForStep(viewModel.currentStep);
    String subtitle = _getSubtitleForStep(viewModel.currentStep);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.titleSmall),
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
        return 'Choose Stat Keepeers for this league. You can invite new Stat Keepeers or select from existing ones.';
      case 3:
        return "Invite teams to join this league. You can search existing teams.";
      default:
        return 'Enter league information below to create a new tournament.';
    }
  }
}