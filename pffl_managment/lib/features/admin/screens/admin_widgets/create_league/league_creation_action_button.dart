import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/features/admin/leagues/providers/create_league_viewmodel.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:provider/provider.dart';

class LeagueCreationActionButton extends StatelessWidget {
  const LeagueCreationActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
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
    bool isCurrentStepValid = false;
    switch (viewModel.currentStep) {
      case 0:
        isCurrentStepValid = viewModel.isStep1Valid;
        break;
      case 1:
        isCurrentStepValid = viewModel.isStep2Valid;
        break;
      case 2:
        isCurrentStepValid = viewModel.isStep3Valid;
        break;
      case 3:
        isCurrentStepValid = viewModel.isStep4Valid;
        break;
    }

    if (!isCurrentStepValid && viewModel.currentStep < 4) {
      return null;
    }

    switch (viewModel.currentStep) {
      case 0:
      case 1:
      case 2:
        return viewModel.nextStep;
      case 3:
        return () async {
          await viewModel.createLeague(context);
          if (context.mounted) {
            // Show bottom sheet instead of snackbar
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'League Created',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'League created successfully!\nNotifications sent to all players.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Continue',
                        onPressed: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                          Navigator.of(context).pop(); // Close dialog
                          // Navigate to admin dashboard
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.adminDashboard,
                            (route) => false,
                          );
                        },
                        backgroundColor: const Color(0xFF0F173E),
                        textColor: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                );
              },
            );
          }
        };
      default:
        return null;
    }
  }
}
