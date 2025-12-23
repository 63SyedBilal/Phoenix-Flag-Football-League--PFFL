import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/features/admin/leagues/providers/league_detail_provider.dart';
import 'package:provider/provider.dart';

class LeagueTeamList extends StatelessWidget {
  const LeagueTeamList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teams title with plus button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Teams',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 30),
                onPressed: () {
                  // Navigate to invite teams page with Step4SetFeesWidget UI
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InviteTeamsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TeamList(),
        ],
      ),
    );
  }
}

class InviteTeamsPage extends StatelessWidget {
  const InviteTeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Invite Teams'),
      ),
      body: const Step4SetFeesWidgetSameAsOriginal(),
    );
  }
}

// Exact copy of Step4SetFeesWidget with no changes
class Step4SetFeesWidgetSameAsOriginal extends StatelessWidget {
  const Step4SetFeesWidgetSameAsOriginal({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by team name',
                hintStyle: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 12.0, // Reduced hint text size
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _TeamListSameAsOriginal(),
        ],
      ),
    );
  }
}

class _TeamListSameAsOriginal extends StatelessWidget {
  _TeamListSameAsOriginal();

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
    final viewModel = Provider.of<LeagueDetailProvider>(context);
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
    LeagueDetailProvider viewModel,
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

// Custom painter for dotted border
class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final double dashWidth = 2;
    final double dashSpace = 2;
    final double radius = size.width / 2;

    double circumference = 2 * 3.141592653589793 * radius;
    int dashCount = (circumference / (dashWidth + dashSpace)).floor();

    double angleIncrement = (2 * 3.141592653589793) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      double startAngle = i * angleIncrement;
      double endAngle =
          startAngle + (dashWidth / circumference) * 2 * 3.141592653589793;

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    {
      'id': '4',
      'name': 'RC',
      'players': 7,
      'total': 10,
      'emailSent': false,
      'playersList': [
        {'number': '01', 'name': 'Captain Smith', 'position': 'Quarterback'},
        {'number': '02', 'name': 'Jane Doe', 'position': 'Receiver'},
        {'number': '03', 'name': 'John Smith', 'position': 'Center'},
        {'number': '04', 'name': 'Mike Johnson', 'position': 'Slot Receiver'},
        {'number': '05', 'name': 'Sarah Wilson', 'position': 'Rusher'},
        {'number': '06', 'name': 'Tom Brown', 'position': 'Blocker'},
        {'number': '07', 'name': 'Lisa Davis', 'position': 'Safety'},
      ],
    },
    {
      'id': '5',
      'name': 'STA',
      'players': 9,
      'total': 11,
      'emailSent': true,
      'playersList': [
        {'number': '01', 'name': 'Robert King (C)', 'position': 'Quarterback'},
        {'number': '02', 'name': 'Emily Stone', 'position': 'Receiver'},
        {'number': '03', 'name': 'David Lee', 'position': 'Center'},
        {'number': '04', 'name': 'James White', 'position': 'Slot Receiver'},
        {'number': '05', 'name': 'Jennifer Green', 'position': 'Rusher'},
        {'number': '06', 'name': 'Christopher Black', 'position': 'Blocker'},
        {'number': '07', 'name': 'Amanda Blue', 'position': 'Safety'},
        {'number': '08', 'name': 'Daniel Red', 'position': 'Cornerback'},
        {'number': '09', 'name': 'Michelle Yellow', 'position': 'Running Back'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LeagueDetailProvider>(context);
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
    LeagueDetailProvider viewModel,
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
                          Text('Payment Status', style: AppTextStyles.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...team['playersList'].map<Widget>((player) {
                        // Determine payment status for demo purposes
                        final int playerNumber = int.tryParse(player['number']) ?? 0;
                        final bool isPaid = playerNumber % 3 == 0; // Every 3rd player is paid
                        
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
                              // Payment status badge - only Paid/Unpaid
                              if (isPaid)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Paid',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFA2A2A2), // Unpaid color as requested
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Unpaid',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              // Alarm icon - same color as payment status
                              Icon(
                                Icons.alarm,
                                size: 20,
                                color: isPaid ? Colors.grey : Color(0xFFA2A2A2), // Unpaid color as requested
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
