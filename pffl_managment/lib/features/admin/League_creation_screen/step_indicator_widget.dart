import 'package:flutter/material.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class StepIndicatorWidget extends StatelessWidget {
  const StepIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildStepCircle(context, viewModel, 1, 'Create League'),
              _buildConnectorLine(viewModel, 0),
              _buildStepCircle(context, viewModel, 2, 'Referees'),
              _buildConnectorLine(viewModel, 1),
              _buildStepCircle(context, viewModel, 3, 'Stat Keeper'),
              _buildConnectorLine(viewModel, 2),
              _buildStepCircle(context, viewModel, 4, 'Invite Teams'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Create League', screenWidth),
              _buildStepLabel('Referees', screenWidth),
              _buildStepLabel('Stat Keeper', screenWidth),
              _buildStepLabel('Invite Teams', screenWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine(CreateLeagueViewModel viewModel, int stepIndex) {
    return Expanded(
      child: Container(
        height: 2,
        color: viewModel.currentStep > stepIndex
            ? AppColors.stepActive
            : AppColors.stepInactive,
      ),
    );
  }

  Widget _buildStepCircle(
    BuildContext context,
    CreateLeagueViewModel viewModel,
    int stepNumber,
    String label,
  ) {
    final isActive = stepNumber == viewModel.currentStep + 1;
    final isCompleted = stepNumber <= viewModel.currentStep;

    return GestureDetector(
      onTap: () {
        if (stepNumber - 1 < viewModel.currentStep) {
          viewModel.goToStep(stepNumber - 1);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive || isCompleted
              ? AppColors.stepActive
              : AppColors.backgroundWhite,
          border: Border.all(
            color: isActive || isCompleted
                ? AppColors.stepActive
                : AppColors.stepInactive,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$stepNumber',
            style: TextStyle(
              color: isActive || isCompleted
                  ? AppColors.buttonText
                  : AppColors.stepActive,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepLabel(String label, double screenWidth) {
    final fontSize = screenWidth < 360 ? 9.0 : 10.0;

    return Flexible(
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.stepActive,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
