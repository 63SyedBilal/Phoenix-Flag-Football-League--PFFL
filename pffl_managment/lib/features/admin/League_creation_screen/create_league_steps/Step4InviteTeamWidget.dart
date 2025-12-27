import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class Step4InvuteTeamWidget extends StatelessWidget {
  const Step4InvuteTeamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);

    // Fetch teams if empty and not loading when widget builds
    // Note: Step 4 widget is shown when currentStep == 3 (0-indexed)
    if (viewModel.currentStep == 3 &&
        viewModel.teams.isEmpty &&
        !viewModel.isLoadingTeams) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.fetchTeams();
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: CustomTextField(
              hintText: 'Search by team name',
              suffixIcon: const Icon(Icons.search),
              onChanged: (query) {
                viewModel.setTeamSearchQuery(query);
              },
            ),
          ),
          const SizedBox(height: 12),
          _TeamList(),
        ],
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  const _TeamList();

  // Map TeamModel to UI format
  Map<String, dynamic> _mapTeamToUIFormat(
    dynamic team,
    CreateLeagueViewModel viewModel,
  ) {
    // Determine which squad to use (prefer 5v5, fallback to 7v7)
    final squad5v5 = team.squad5v5;
    final squad7v7 = team.squad7v7;

    final players = (squad5v5 != null && squad5v5.isNotEmpty)
        ? squad5v5
        : (squad7v7 ?? []);

    final playerCount = players.length;
    final maxPlayers = (squad5v5 != null && squad5v5.isNotEmpty) ? 5 : 7;

    // Map players to playersList format
    final playersList = players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;

      // Handle player data - could be Map or already parsed
      String firstName = '';
      String lastName = '';

      if (player is Map) {
        firstName = player['firstName']?.toString() ?? '';
        lastName = player['lastName']?.toString() ?? '';
      }

      final name = '$firstName $lastName'.trim();

      return {
        'number': '${(index + 1).toString().padLeft(2, '0')}',
        'name': name.isEmpty ? 'Player ${index + 1}' : name,
        'position': 'N/A', // Position not available in team response
      };
    }).toList();

    return {
      'id': team.id,
      'name': team.teamName,
      'image': team.image, // Team logo URL
      'players': playerCount,
      'total': maxPlayers,
      'emailSent': viewModel.isTeamEmailSent(team.id),
      'playersList': playersList,
    };
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);

    // Show loading indicator
    if (viewModel.isLoadingTeams) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show empty state
    final filteredTeams = viewModel.filteredTeams;
    if (filteredTeams.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            viewModel.teamSearchQuery.isNotEmpty
                ? 'No teams found matching your search'
                : 'No teams found',
            style: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: filteredTeams.map((team) {
        // Map team to UI format
        final teamData = _mapTeamToUIFormat(team, viewModel);
        // Update the team's expanded state from the view model
        teamData['expanded'] = viewModel.isTeamExpanded(team.id);
        return _buildTeamItem(teamData, viewModel, context);
      }).toList(),
    );
  }

  Widget _buildTeamItem(
    Map<String, dynamic> team,
    CreateLeagueViewModel viewModel,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => viewModel.toggleTeamExpansion(team['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    // Team Logo Circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textBlack,
                          width: 0.5,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            (team['image'] != null &&
                                team['image'].toString().isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: team['image'].toString(),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFE5E7EB),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.backgroundWhite,
                                  child: const Icon(
                                    Icons.shield,
                                    size: 20,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.backgroundWhite,
                                child: const Icon(
                                  Icons.shield,
                                  size: 20,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Email icon - simple color change on tap
                    Consumer<CreateLeagueViewModel>(
                      builder: (context, vm, child) {
                        final teamId = team['id'] as String;
                        final bool isEmailSent = vm.isTeamEmailSent(teamId);

                        // Icon color: Red when sent, Grey when not sent
                        final iconColor = isEmailSent
                            ? AppColors.buttonBackground
                            : AppColors.borderDefault;

                        return GestureDetector(
                          onTap: isEmailSent
                              ? null
                              : () {
                                  // Send invitation - no validation, fire-and-forget
                                  vm.sendInvitationToTeam(vm.leagueId, teamId);
                                },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: isEmailSent
                                ? SvgIcons.emailAfterInvitation(
                                    size: 22,
                                    color: iconColor,
                                  )
                                : Icon(
                                    AppIcons.emailOutlined,
                                    color: iconColor,
                                    size: 22,
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (team['expanded'])
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Heading row
                      const Row(
                        children: [
                          SizedBox(width: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Player Name',
                              style: AppTextStyles.titleMedium,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Position', style: AppTextStyles.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...team['playersList'].map<Widget>((player) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  player['number'],
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  player['name'],
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext ctx) {
                                      return AlertDialog(
                                        title: const Text('Player States'),
                                        content: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            Chip(
                                              label: Text('Rusher'),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Lato",
                                              ),
                                              backgroundColor:
                                                  AppColors.primary,
                                            ),
                                            Chip(
                                              label: Text('Blocker'),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Lato",
                                              ),
                                              backgroundColor:
                                                  AppColors.primary,
                                            ),
                                            Chip(
                                              label: Text('Slot'),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Lato",
                                              ),
                                              backgroundColor:
                                                  AppColors.primary,
                                            ),
                                            Chip(
                                              label: Text('Center'),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Lato",
                                              ),
                                              backgroundColor:
                                                  AppColors.primary,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.positionButtonBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "View Position",
                                    style: AppTextStyles.labelLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Team Overview (${team['players']}/${team['total']})',
                    style: AppTextStyles.titleMedium,
                  ),
                  IconButton(
                    icon: Icon(
                      team['expanded']
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: AppColors.textBlack,
                    ),
                    onPressed: () => viewModel.toggleTeamExpansion(team['id']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
