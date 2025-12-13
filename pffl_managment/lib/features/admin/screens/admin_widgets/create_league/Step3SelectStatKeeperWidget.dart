import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/leagues/providers/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class Step3SelectStatKeeperWidget extends StatelessWidget {
  const Step3SelectStatKeeperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    List<PlayerModel> filteredStatKeepers = viewModel.availableStatKeepers;
    if (viewModel.statKeeperSearchQuery.isNotEmpty) {
      filteredStatKeepers = viewModel.availableStatKeepers
          .where(
            (statKeeper) => statKeeper.name.toLowerCase().contains(
              viewModel.statKeeperSearchQuery,
            ),
          )
          .toList();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderDefault),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDefault.withValues(alpha: 0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: CustomTextField(
              hintText: 'Search by Stat keeper name',
              prefixIcon: const Icon(
                AppIcons.search,
                color: AppColors.textDisabled,
              ),
              // Add search functionality
              onChanged: (query) {
                viewModel.setStatKeeperSearchQuery(query);
              },
            ),
          ),
          const SizedBox(height: 12),
          // Show error message if no stat keepers are selected
          if (viewModel.selectedStatKeeperIds.isEmpty && viewModel.currentStep == 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Please select at least one stat keeper',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 12,
                ),
              ),
            ),
          ...filteredStatKeepers.map((statKeeper) {
            return _buildStatKeeperItem(context, statKeeper, viewModel);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatKeeperItem(
    BuildContext context,
    PlayerModel statKeeper,
    CreateLeagueViewModel viewModel,
  ) {
    // Check if this stat keeper is selected
    bool isSelected = viewModel.selectedStatKeeperIds.contains(statKeeper.id);
    final hasSentEmail = viewModel.isEmailSent(statKeeper.id);
    
    return GestureDetector(
      onTap: () {
        viewModel.toggleStatKeeperSelection(statKeeper.id);
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
                  image: NetworkImage(statKeeper.avatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(statKeeper.name, style: AppTextStyles.titleMedium),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              )
            else
              IconButton(
                icon: hasSentEmail
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
                onPressed: hasSentEmail
                    ? null
                    : () {
                        viewModel.sendEmailToStatKeeper(statKeeper.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email invitation sent to stat keeper'),
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