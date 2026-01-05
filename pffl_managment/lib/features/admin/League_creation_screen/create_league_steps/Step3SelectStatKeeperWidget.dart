import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/user_avatar_widget.dart';
import 'package:pffl_managment/core/services/user_service.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

/// Step 3 - Stat Keeper Invitation Widget
///
/// Requirements:
/// - No selection validation
/// - Tiles must be unselectable (no tap response)
/// - Invitations sent ONLY by tapping notification/email icon
/// - When stat keeper accepts invitation, league is assigned to them
/// - Multiple stat keepers can be assigned to the same league
class Step3SelectStatKeeperWidget extends StatelessWidget {
  const Step3SelectStatKeeperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateLeagueViewModel>(
      builder: (context, viewModel, child) {
        // Fetch stat keepers on first build if not already loading
        if (viewModel.statKeepers.isEmpty && !viewModel.isLoadingStatKeepers) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.fetchStatKeepers();
          });
        }

        // Use filtered stat keepers based on search
        final filteredStatKeepers = viewModel.filteredStatKeepers;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
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
  suffixIcon: Padding(
    padding: const EdgeInsets.all(12.0),
    child: SvgPicture.asset(
      'assets/icons/home_icons/searchrightIcon.svg',
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(
        AppColors.textDisabled,
        BlendMode.srcIn,
      ),
    ),
  ),
                  onChanged: (query) {
                    viewModel.setStatKeeperSearchQuery(query);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Loading state
              if (viewModel.isLoadingStatKeepers)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              // Empty state
              else if (filteredStatKeepers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 48,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          viewModel.statKeeperSearchQuery.isNotEmpty
                              ? 'No stat keepers found matching your search'
                              : 'No stat keepers available',
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              // Stat keeper list
              else
                ...filteredStatKeepers.map((statKeeper) {
                  return _buildStatKeeperItem(context, statKeeper, viewModel);
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatKeeperItem(
    BuildContext context,
    UserModel statKeeper,
    CreateLeagueViewModel viewModel,
  ) {
    // Get profile image URL from viewModel (if available)
    final profileImageUrl = viewModel.getStatKeeperProfileImageUrl(
      statKeeper.id,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar - displays profile image or default person icon
          UserAvatarWidget(
            imageUrl: profileImageUrl,
            size: 44,
            borderWidth: 2,
            borderColor: AppColors.borderLight,
            backgroundColor: AppColors.backgroundWhite,
            iconColor: AppColors.textDisabled,
          ),
          const SizedBox(width: 12),

          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statKeeper.displayName, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  statKeeper.email,
                  style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),

          // Invitation icon - ONLY way to invite
          Consumer<CreateLeagueViewModel>(
            builder: (context, vm, child) {
              return _buildInviteButton(context, statKeeper.id, vm);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton(
    BuildContext context,
    String statKeeperId,
    CreateLeagueViewModel viewModel,
  ) {
    // Check invitation status directly from viewModel to ensure latest state
    final bool isInviteSent = viewModel.isStatKeeperInviteSent(statKeeperId);

    // Icon color: grey initially, red when invitation is sent
    final iconColor = isInviteSent
        ? AppColors.buttonBackground
        : AppColors.borderDefault;

    return IconButton(
      icon: isInviteSent
          ? SvgIcons.emailAfterInvitation(size: 22, color: iconColor)
          : Icon(AppIcons.emailOutlined, color: iconColor, size: 22),
      onPressed: isInviteSent
          ? null
          : () {
              // Send invitation - no validation, fire-and-forget
              viewModel.sendInvitationToStatKeeperIcon(statKeeperId);
            },
      tooltip: isInviteSent
          ? 'Invitation sent'
          : 'Send invitation to stat keeper',
    );
  }
}
