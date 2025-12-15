import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/provider/dashboard_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_home_screen_widgets/admin_quick_action_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';

class AdminQuickActionSection extends StatelessWidget {
  const AdminQuickActionSection ({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final actions = viewModel.quickActions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('Quick Actions', style: AppTextStyles.headlineSmall),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: AdminQuickActionCardWidget(action: actions[0])),
                Expanded(child: AdminQuickActionCardWidget(action: actions[1])),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('Comming Soon', style: AppTextStyles.headlineSmall),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: AdminQuickActionCardWidget(action: actions[2])),
                Expanded(child: AdminQuickActionCardWidget(action: actions[3])),
              ],
            ),
          ],
        );
      },
    );
  }
}
