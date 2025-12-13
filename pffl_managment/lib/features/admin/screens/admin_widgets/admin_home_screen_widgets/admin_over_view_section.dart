

import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/features/admin/provider/dashboard_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_home_screen_widgets/stat_card_widget.dart';
import 'package:provider/provider.dart';

class AdminOverViewSection extends StatelessWidget {
  const AdminOverViewSection({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final stats = viewModel.statCards;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('Overview', style: AppTextStyles.headlineSmall),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCardWidget(stat: stats[0])),
                Expanded(child: StatCardWidget(stat: stats[1])),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: StatCardWidget(stat: stats[2])),
                Expanded(child: StatCardWidget(stat: stats[3])),
              ],
            ),
          ],
        );
      },
    );
  }
}
