import 'package:flutter/material.dart';
import 'package:pffl_managment/core/utils/helpers.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:provider/provider.dart';

class LeagueCreationActionButton extends StatelessWidget {
  const LeagueCreationActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    return Material(
      color: const Color(0xFFF9FAFB), // Match scaffold background
      elevation: 8, // Elevation to keep button above content when keyboard opens
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: _getButtonText(viewModel.currentStep),
                onPressed: _getButtonAction(context, viewModel) ?? () {},
                backgroundColor: const Color(0xFF0F173E),
                textColor: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                isLoading: viewModel.isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText(int step) {
    switch (step) {
      case 0:
      case 1:
      case 2:
        return 'Next';
      case 3:
        return 'Create League';
      default:
        return 'Next';
    }
  }

  VoidCallback? _getButtonAction(
    BuildContext context,
    CreateLeagueViewModel viewModel,
  ) {
    if (viewModel.isLoading) return null;

    switch (viewModel.currentStep) {
      case 0:
        // Step 1: Validate on button press
        return () {
          if (viewModel.validateStep1()) {
            viewModel.nextStep();
          }
        };
      case 1:
        // Step 2: Always valid (invitations sent via icon)
        return viewModel.nextStep;
      case 2:
        // Step 3: Always valid (invitations sent via icon)
        return viewModel.nextStep;
      case 3:
        return () async {
          await viewModel.createLeague(context);
          if (context.mounted) {
            showCustomBottomSheet(
              context: context,
              title: 'League created\nsuccessfully!',
              subtitle: 'Invites have been sent to team captains and officials. You can now manage scheduling, rosters, and games for this league.',
              buttonText: 'Continue',
              onButtonPressed: () {
                Navigator.of(context).pop();// Close bottom sheet
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.adminDashboard,
                  (route) => false,
                );
              },
              content: const SizedBox(), // Empty content since we're using the optional icon
            );          }
        };
      default:
        return null;
    }
  }
}
