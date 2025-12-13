import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/game_widgets/upcomming_matches_screens/upcomming_matches_card_widget.dart';
import 'package:pffl_managment/features/admin/provider/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';

class UpcommingMatches extends StatelessWidget {
  const UpcommingMatches({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final matches = viewModel.upcomingMatches;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Matches', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 18),
            ...matches.map(
              (match) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: UpcommingMatchesCardWidget(match: match),
              ),
            ),
          ],
        );
      },
    );
  }
}
