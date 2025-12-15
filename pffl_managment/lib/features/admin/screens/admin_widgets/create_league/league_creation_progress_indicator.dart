import 'package:flutter/material.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class StepIndicatorWidget extends StatelessWidget {
  const StepIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildStepCircle(context, viewModel, 1, 'Create League'),
              Container(
                width: 56,
                height: 2,
                color: viewModel.currentStep > 0
                    ? AppColors.stepActive
                    : AppColors.stepInactive,
              ),
              _buildStepCircle(context, viewModel, 2, 'Referees'),
              Container(
                width: 56,
                height: 2,
                color: viewModel.currentStep > 1
                    ? AppColors.stepActive
                    : AppColors.stepInactive,
              ),
              _buildStepCircle(context, viewModel, 3, 'Stat Keeper'),
              Container(
                width: 56,
                height: 2,
                color: viewModel.currentStep > 2
                    ? AppColors.stepActive
                    : AppColors.stepInactive,
              ),
              _buildStepCircle(context, viewModel, 4, 'Invite Teams'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Create League'),
              _buildStepLabel('Referees'),
              _buildStepLabel('Stat Keeper'),
              _buildStepLabel('Invite Teams'),
            ],
          ),
        ],
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

  Widget _buildStepLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.stepActive,
      ),
    );
  }
}
