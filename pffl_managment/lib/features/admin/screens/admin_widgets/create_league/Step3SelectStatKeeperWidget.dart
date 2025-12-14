import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/services/user_service.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class Step3SelectStatKeeperWidget extends StatefulWidget {
  const Step3SelectStatKeeperWidget({super.key});

  @override
  State<Step3SelectStatKeeperWidget> createState() => _Step3SelectStatKeeperWidgetState();
}

class _Step3SelectStatKeeperWidgetState extends State<Step3SelectStatKeeperWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch stat keepers when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CreateLeagueViewModel>(context, listen: false);
      viewModel.fetchStatKeepers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    
    // Filter stat keepers based on search query
    List<UserModel> filteredStatKeepers = viewModel.statKeepers;
    if (viewModel.statKeeperSearchQuery.isNotEmpty) {
      filteredStatKeepers = viewModel.statKeepers
          .where(
            (statKeeper) => 
              statKeeper.displayName.toLowerCase().contains(
                viewModel.statKeeperSearchQuery,
              ) ||
              statKeeper.email.toLowerCase().contains(
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
          if (viewModel.isLoadingStatKeepers)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredStatKeepers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No stat keepers found',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else ...[
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
        ],
      ),
    );
  }

  Widget _buildStatKeeperItem(
    BuildContext context,
    UserModel statKeeper,
    CreateLeagueViewModel viewModel,
  ) {
    // Check if this stat keeper is selected
    bool isSelected = viewModel.selectedStatKeeperIds.contains(statKeeper.id);
    final hasSentEmail = viewModel.isStatKeeperEmailSending(statKeeper.id);
    
    // Generate avatar URL from email
    final avatarUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=${statKeeper.email}';
    
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
                    statKeeper.displayName,
                    style: AppTextStyles.titleMedium,
                  ),
                  Text(
                    statKeeper.email,
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