import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
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
        // Fetch referees on first build if not already loading
        if (viewModel.referees.isEmpty && !viewModel.isLoadingReferees) {
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
                hintText: 'Search by Referee name or email',
                suffixIcon: const Icon(
                  AppIcons.search,
                  color: AppColors.textDisabled,
                ),
                onChanged: (query) {
                  viewModel.setRefereeSearchQuery(query);
                },
              ),
              const SizedBox(height: 12),
              
              // Info text about invitation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap the notification icon to invite referees. They will receive a notification and can accept to join this league.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Loading state
              if (viewModel.isLoadingReferees)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              // Empty state
              else if (filteredReferees.isEmpty)
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
                      ],
                    ),
                  ),
                )
              // Referee list
              else
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
    // Check invitation status
    final bool isInviteSending = viewModel.isRefereeInviteSending(referee.id);
    final bool isInviteSent = viewModel.isRefereeInviteSent(referee.id);

    // Generate avatar URL from email
    final avatarUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=${referee.email}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInviteSent ? AppColors.primary.withOpacity(0.5) : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight, width: 2),
              image: DecorationImage(
                image: NetworkImage(avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referee.displayName,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  referee.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          
          // Invitation icon - ONLY way to invite
          _buildInviteButton(context, referee.id, viewModel, isInviteSending, isInviteSent),
        ],
      ),
    );
  }

  Widget _buildInviteButton(
    BuildContext context,
    String refereeId,
    CreateLeagueViewModel viewModel,
    bool isInviteSending,
    bool isInviteSent,
  ) {
    // If invitation was sent successfully
    if (isInviteSent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Invited',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // If invitation is being sent
    if (isInviteSending) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Default - invite button
    return IconButton(
      icon: Icon(
        AppIcons.emailOutlined,
        color: AppColors.primary,
        size: 22,
      ),
      onPressed: () async {
        // Check if league is created
        if (viewModel.leagueId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait, league is being created...'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Send invitation
        final success = await viewModel.sendInvitationToReferee(refereeId);
        
        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invitation sent successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to send invitation. The referee may have already been invited.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      },
      tooltip: 'Send invitation to referee',
    );
  }
}
