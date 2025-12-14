import 'package:flutter/material.dart';

import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Teams',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 28, color: Color(0xFF000000)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
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
      'logo': 'assets/team_logos/stc.png',
      'players': 4,
      'total': 8,
      'playersList': [
        {'number': '01', 'name': 'Alex Morgan (C)', 'paid': true},
        {'number': '02', 'name': 'John Carter', 'paid': true},
        {'number': '03', 'name': 'Michael Lee', 'paid': false},
        {'number': '04', 'name': 'Rebecca Torres', 'paid': true},
      ],
    },
    {
      'id': '2',
      'name': 'GEO',
      'logo': 'assets/team_logos/geo.png',
      'players': 8,
      'total': 8,
      'playersList': [],
    },
    {
      'id': '3',
      'name': 'RTA',
      'logo': 'assets/team_logos/rta.png',
      'players': 8,
      'total': 8,
      'playersList': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LeagueDetailProvider>(context);
    return Column(
      children: _teams.map((team) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      team['logo'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.shield,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    team['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => viewModel.toggleTeamExpansion(team['id']),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View Team Overview (${team['players']}/${team['total']})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Icon(
                        team['expanded']
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF111827),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (team['expanded'] && team['playersList'].isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '#/No',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Player Name',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Payment Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...team['playersList'].map<Widget>((player) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              player['number'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              player['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: player['paid']
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFA2A2A2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  player['paid'] ? 'Paid' : 'UnPaid',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: player['paid']
                                    ? const Color(0xFFD1D5DB)
                                    : const Color(0xFFA2A2A2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
