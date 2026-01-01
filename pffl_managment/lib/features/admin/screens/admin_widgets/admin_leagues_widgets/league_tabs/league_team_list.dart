import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';

class LeagueTeamList extends StatelessWidget {
  const LeagueTeamList({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.userRole.toLowerCase() == 'admin';

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
              if (isAdmin)
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 28,
                    color: Color(0xFF000000),
                  ),
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
  const _TeamList();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LeagueDetailProvider>(context);
    final teams = viewModel.leagueTeams;

    if (viewModel.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (teams.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: const Text(
          'No teams added to this league yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return Column(
      children: teams.map((team) {
        final isExpanded = viewModel.isTeamExpanded(team.id);

        // Use the helper we added to TeamModel to get UI-ready player list
        final playersList = team.formattedPlayers;

        return _buildTeamItem(
          team,
          playersList,
          isExpanded,
          viewModel,
          context,
        );
      }).toList(),
    );
  }

  Widget _buildTeamItem(
    dynamic
    team, // Using dynamic or TeamModel. Since we imported service, it's TeamModel
    List<Map<String, dynamic>> playersList,
    bool isExpanded,
    LeagueDetailProvider viewModel,
    BuildContext context,
  ) {
    // Determine player counts
    final currentPlayers = team.playerCount;
    // We can default total to something reasonable or hide it if unknown,
    // but the UI mockup usually wants "current/total".
    // Assuming 5v5 league = 8 max, 7v7 = 12 max usually, but we don't have format here easily.
    // Let's just show current count for now to be safe, or 12 as generic max.

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
                    child: team.image != null && team.image!.isNotEmpty
                        ? Image.network(
                            team.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholderIcon(),
                          )
                        : _buildPlaceholderIcon(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          team.teamName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/icons/home_icons/WhiteclockAlarmIcon.svg',
                        width: 22,
                        height: 22,
                     //   color: const Color(0xFF000000),
                     color: Colors.black26,
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/icons/home_icons/deletewhiteIcon.svg',
                        width: 22,
                        height: 22,
                        color: const Color(0xFF000000),
                      ),
                    ],
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
                onTap: () => viewModel.toggleTeamExpansion(team.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View Team Overview ($currentPlayers)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lato',
                          color: Color(0xFF111827),
                        ),
                      ),
                      Icon(
                        isExpanded
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
          if (isExpanded && playersList.isNotEmpty)
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
                              fontFamily: 'Lato',
                              color: Colors.black,
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
                              color: Colors.black,
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
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...playersList.map<Widget>((player) {
                    final isPaid = player['paid'] == true;
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
                              Text(
                                isPaid ? 'Paid' : 'UnPaid',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: !isPaid
                                      ? () {
                                          if (player['id'] != null &&
                                              player['id'].isNotEmpty) {
                                            viewModel.sendPaymentReminder(
                                              player['id'],
                                            );
                                          }
                                        }
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SvgPicture.asset(
                                      'assets/icons/home_icons/WhiteclockAlarmIcon.svg',
                                      width: 18,
                                      height: 18,
                                      color: isPaid
                                          ? const Color(0xFFD1D5DB)
                                          : const Color(0xFFA2A2A2),
                                    ),
                                  ),
                                ),
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

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[100],
      child: const Icon(Icons.shield, size: 24, color: Colors.grey),
    );
  }
}