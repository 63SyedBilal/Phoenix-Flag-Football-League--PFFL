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

/// Step 2 - Referee Invitation Widget
///
/// Requirements:
/// - No selection validation
/// - Tiles must be unselectable (no tap response)
/// - Invitations sent ONLY by tapping notification/email icon
/// - When referee accepts invitation, league is assigned to them
/// - Multiple referees can be assigned to the same league
class Step2SelectRefereesWidget extends StatelessWidget {
  const Step2SelectRefereesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateLeagueViewModel>(
      builder: (context, viewModel, child) {
        // Fetch referees on first build if not already attempted
        if (!viewModel.hasAttemptedRefereesFetch &&
            !viewModel.isLoadingReferees) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.fetchReferees();
          });
        }

        // Use filtered referees based on search
        final filteredReferees = viewModel.filteredReferees;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              CustomTextField(
  hintText: 'Search by Referees name',
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
                  viewModel.setRefereeSearchQuery(query);
                },
              ),

              const SizedBox(height: 16),

              // Loading state - only show if currently loading
              if (viewModel.isLoadingReferees)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              // Empty state - show if fetch attempted but no results
              else if (viewModel.hasAttemptedRefereesFetch &&
                  filteredReferees.isEmpty)
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
                          viewModel.refereeSearchQuery.isNotEmpty
                              ? 'No referees found matching your search'
                              : 'No referees available',
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            // Allow retry by resetting the fetch attempt flag
                            viewModel.retryFetchReferees();
                          },
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Referee list - show if we have data
              else if (filteredReferees.isNotEmpty)
                ...filteredReferees.map((referee) {
                  return _buildRefereeItem(context, referee, viewModel);
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefereeItem(
    BuildContext context,
    UserModel referee,
    CreateLeagueViewModel viewModel,
  ) {
    // Get profile image URL from viewModel (if available)
    final profileImageUrl = viewModel.getRefereeProfileImageUrl(referee.id);

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
                Text(referee.displayName, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  referee.email,
                  style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),

          // Invitation icon - ONLY way to invite
          Consumer<CreateLeagueViewModel>(
            builder: (context, vm, child) {
              return _buildInviteButton(context, referee.id, vm);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton(
    BuildContext context,
    String refereeId,
    CreateLeagueViewModel viewModel,
  ) {
    // Check invitation status directly from viewModel to ensure latest state
    final bool isInviteSent = viewModel.isRefereeInviteSent(refereeId);

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
              viewModel.sendInvitationToReferee(refereeId);
            },
      tooltip: isInviteSent ? 'Invitation sent' : 'Send invitation to referee',
    );
  }
}
