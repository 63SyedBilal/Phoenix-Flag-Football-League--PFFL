import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/services/user_service.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class Step2SelectRefereesWidget extends StatefulWidget {
  const Step2SelectRefereesWidget({super.key});

  @override
  State<Step2SelectRefereesWidget> createState() => _Step2SelectRefereesWidgetState();
}

class _Step2SelectRefereesWidgetState extends State<Step2SelectRefereesWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch free agents when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CreateLeagueViewModel>(context, listen: false);
      viewModel.fetchFreeAgents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    
    // Filter free agents based on search query
    List<UserModel> filteredFreeAgents = viewModel.freeAgents;
    if (viewModel.freeAgentSearchQuery.isNotEmpty) {
      filteredFreeAgents = viewModel.freeAgents
          .where(
            (freeAgent) => 
              freeAgent.displayName.toLowerCase().contains(
                viewModel.freeAgentSearchQuery,
              ) ||
              freeAgent.email.toLowerCase().contains(
                viewModel.freeAgentSearchQuery,
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
            hintText: 'Search by Free Agent name or email',
            suffixIcon: const Icon(
              AppIcons.search,
              color: AppColors.textDisabled,
            ),
            onChanged: (query) {
              viewModel.setFreeAgentSearchQuery(query);
            },
          ),
          const SizedBox(height: 12),
          if (viewModel.isLoadingFreeAgents)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredFreeAgents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No free agents found',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else ...[
            if (viewModel.selectedFreeAgentIds.isEmpty && viewModel.currentStep == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Please select at least one free agent',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 12,
                  ),
                ),
              ),
            ...filteredFreeAgents.map((freeAgent) {
              return _buildFreeAgentItem(freeAgent, viewModel, context);
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildFreeAgentItem(
    UserModel freeAgent,
    CreateLeagueViewModel viewModel,
    BuildContext context,
  ) {
    // Check if this free agent is selected
    bool isSelected = viewModel.selectedFreeAgentIds.contains(freeAgent.id);
    // Check if email has been sent to this free agent
    bool isEmailSent = viewModel.isFreeAgentEmailSending(freeAgent.id);

    // Generate avatar URL from email (using dicebear or similar)
    final avatarUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=${freeAgent.email}';

    return GestureDetector(
      onTap: () {
        viewModel.toggleFreeAgentSelection(freeAgent.id);
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
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    freeAgent.displayName,
                    style: AppTextStyles.titleMedium,
                  ),
                  Text(
                    freeAgent.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
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
                    : () async {
                        // Note: We need leagueId to send invitation
                        // This will be handled after league creation
                        // For now, just show a message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invitation will be sent after league creation'),
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