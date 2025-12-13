import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/features/admin/leagues/providers/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class Step4InvuteTeamWidget extends StatelessWidget {
  const Step4InvuteTeamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<CreateLeagueViewModel>(context);
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
            child:CustomTextField(
              hintText: 'Search by team name',
              suffixIcon: const Icon(Icons.search),
              onChanged: (query) {},
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
  _TeamList();

  final List<Map<String, dynamic>> _teams = [
    {
      'id': '1',
      'name': 'STC',
      'players': 5,
      'total': 8,
      'emailSent': false,
      'playersList': [
        {'number': '01', 'name': 'Alex Morgan (C)', 'position': 'Quarterback'},
        {'number': '02', 'name': 'John Carter', 'position': 'Receiver'},
        {'number': '03', 'name': 'Michael Lee', 'position': 'Center'},
        {'number': '04', 'name': 'Rebecca Torres', 'position': 'Slot Receiver'},
        {'number': '05', 'name': 'Anthony Brooks', 'position': 'Rusher'},
      ],
    },
    {
      'id': '2',
      'name': 'GEO',
      'players': 12,
      'total': 12,
      'emailSent': true,
      'playersList': [
        {'number': '01', 'name': 'Player One', 'position': 'Position 1'},
        {'number': '02', 'name': 'Player Two', 'position': 'Position 2'},
        {'number': '03', 'name': 'Player Three', 'position': 'Position 3'},
        {'number': '04', 'name': 'Player Four', 'position': 'Position 4'},
        {'number': '05', 'name': 'Player Five', 'position': 'Position 5'},
        {'number': '06', 'name': 'Player Six', 'position': 'Position 6'},
        {'number': '07', 'name': 'Player Seven', 'position': 'Position 7'},
        {'number': '08', 'name': 'Player Eight', 'position': 'Position 8'},
        {'number': '09', 'name': 'Player Nine', 'position': 'Position 9'},
        {'number': '10', 'name': 'Player Ten', 'position': 'Position 10'},
        {'number': '11', 'name': 'Player Eleven', 'position': 'Position 11'},
        {'number': '12', 'name': 'Player Twelve', 'position': 'Position 12'},
      ],
    },
    {
      'id': '3',
      'name': 'RTA',
      'players': 8,
      'total': 8,
      'emailSent': false,
      'playersList': [
        {'number': '01', 'name': 'Player A', 'position': 'Position A'},
        {'number': '02', 'name': 'Player B', 'position': 'Position B'},
        {'number': '03', 'name': 'Player C', 'position': 'Position C'},
        {'number': '04', 'name': 'Player D', 'position': 'Position D'},
        {'number': '05', 'name': 'Player E', 'position': 'Position E'},
        {'number': '06', 'name': 'Player F', 'position': 'Position F'},
        {'number': '07', 'name': 'Player G', 'position': 'Position G'},
        {'number': '08', 'name': 'Player H', 'position': 'Position H'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    return Column(
      children: _teams.map((team) {
        // Update the team's expanded state from the view model
        final updatedTeam = Map<String, dynamic>.from(team);
        updatedTeam['expanded'] = viewModel.isTeamExpanded(team['id']);
        return _buildTeamItem(updatedTeam, viewModel, context);
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
                      child: Center(
                        child: Text(
                          team['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
                    // Email icon
                    IconButton(
                      icon: Icon(
                        team['emailSent'] ? Icons.email : Icons.email_outlined,
                        color: team['emailSent']
                            ? AppColors.iconEmailActive
                            : AppColors.iconEmailInactive.withValues(
                                alpha: 0.3,
                              ),
                      ),
                      onPressed: team['emailSent'] ? null : () {},
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
                                          children: const [
                                            Chip(
                                              label: Text('Rusher'),
                                              backgroundColor:
                                                  AppColors.chipBackground,
                                            ),
                                            Chip(
                                              label: Text('Blocker'),
                                              backgroundColor:
                                                  AppColors.chipBackground,
                                            ),
                                            Chip(
                                              label: Text('Slot'),
                                              backgroundColor:
                                                  AppColors.chipBackground,
                                            ),
                                            Chip(
                                              label: Text('Center'),
                                              backgroundColor:
                                                  AppColors.chipBackground,
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          CustomButton(
                                            text: 'Close',
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                            },
                                            backgroundColor: Colors.transparent,
                                            textColor: AppColors.textBlack,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
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
