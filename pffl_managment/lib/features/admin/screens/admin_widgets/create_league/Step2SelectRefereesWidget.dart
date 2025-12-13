import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/leagues/providers/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class Step2SelectRefereesWidget extends StatelessWidget {
  const Step2SelectRefereesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    List<PlayerModel> filteredReferees = viewModel.availableReferees;
    if (viewModel.refereeSearchQuery.isNotEmpty) {
      filteredReferees = viewModel.availableReferees
          .where(
            (referee) => referee.name.toLowerCase().contains(
              viewModel.refereeSearchQuery,
            ),
          )
          .toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            hintText: 'Search by Referees name',
            suffixIcon: const Icon(
              AppIcons.search,
              color: AppColors.textDisabled,
            ),
            onChanged: (query) {
              viewModel.setRefereeSearchQuery(query);
            },
          ),
          const SizedBox(height: 12),
          if (viewModel.selectedRefereeIds.isEmpty && viewModel.currentStep == 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Please select at least one referee',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 12,
                ),
              ),
            ),
          ...filteredReferees.map((referee) {
            return _buildRefereeItem(referee, viewModel, context);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRefereeItem(
    PlayerModel referee,
    CreateLeagueViewModel viewModel,
    BuildContext context,
  ) {
    // Check if this referee is selected
    bool isSelected = viewModel.selectedRefereeIds.contains(referee.id);
    // Check if email has been sent to this referee
    bool isEmailSent = viewModel.isEmailSending(referee.id);

    return GestureDetector(
      onTap: () {
        viewModel.toggleRefereeSelection(referee.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected 
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
                image: DecorationImage(
                  image: NetworkImage(referee.avatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(referee.name, style: AppTextStyles.titleMedium)),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              )
            else
              IconButton(
                icon: isEmailSent
                    ? const Icon(
                        AppIcons.email,
                        color: AppColors.iconEmailActive,
                        size: 20,
                      )
                    : const Icon(
                        AppIcons.emailOutlined,
                        color: AppColors.iconEmailInactive,
                        size: 20,
                      ),
                onPressed: isEmailSent
                    ? null
                    : () {
                        viewModel.startSendingEmail(referee.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email invitation sent to referee'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
              ),
          ],
        ),
      ),
    );
  }
}