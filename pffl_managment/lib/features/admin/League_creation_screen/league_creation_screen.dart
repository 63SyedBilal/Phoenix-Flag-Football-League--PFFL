import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:pffl_managment/features/admin/League_creation_screen/create_league_steps/Step1TeamInfoWidget.dart';
import 'package:pffl_managment/features/admin/League_creation_screen/create_league_steps/Step2SelectRefereesWidget.dart';
import 'package:pffl_managment/features/admin/League_creation_screen/create_league_steps/Step3SelectStatKeeperWidget.dart';
import 'package:pffl_managment/features/admin/League_creation_screen/create_league_steps/Step4InviteTeamWidget.dart';
import 'package:pffl_managment/features/admin/League_creation_screen/league_header_widget.dart';
import 'package:pffl_managment/features/admin/League_creation_screen/step_indicator_widget.dart';
import 'package:pffl_managment/features/admin/League_creation_screen/league_creation_action_button.dart';
import 'package:provider/provider.dart';

class LeagueCreationScreen extends StatelessWidget {
  const LeagueCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateLeagueViewModel(),
      child: Consumer<CreateLeagueViewModel>(
        builder: (context, viewModel, child) {
          return PopScope(
            canPop: viewModel.currentStep == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                if (viewModel.currentStep > 0) {
                  viewModel.previousStep();
                } else {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leading: ArrowBackButton(
                  onPressed: () {
                    if (viewModel.currentStep > 0) {
                      viewModel.previousStep();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    const LeagueHeaderWidget(),
                    const SizedBox(height: 24),
                    const StepIndicatorWidget(),
                    const SizedBox(height: 24),
                    Expanded(child: _buildStep(viewModel.currentStep)),
                    // Next button stays fixed at bottom
                    const LeagueCreationActionButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return const Step1TeamInfoWidget();
      case 1:
        return const Step2SelectRefereesWidget();
      case 2:
        return const Step3SelectStatKeeperWidget();
      case 3:
        return const Step4InvuteTeamWidget();
      default:
        return const Step1TeamInfoWidget();
    }
  }
}
