import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/core/models/game_model.dart';

import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';

// Card widget with league name display
class UpcommingGamesCardWidget extends StatelessWidget {
  final MatchModel match;

  const UpcommingGamesCardWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
            child: Row(
              children: [
                Text(
                  match.leagueName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 8,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildTeamSection(
                  match.homeTeam,
                  match.homeTeamLogo,
                  isLeft: true,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        match.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        match.time,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildTeamSection(
                  match.awayTeam,
                  match.awayTeamLogo,
                  isLeft: false,
                ),
              ],
            ),
          ),
          const Divider(
            indent: 12,
            endIndent: 12,
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEditGameDialog(context, match),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Game',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(String name, String logo, {required bool isLeft}) {
    return Row(
      children: [
        if (isLeft) ...[
          _buildTeamLogo(logo),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
        ] else ...[
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(width: 8),
          _buildTeamLogo(logo),
        ],
      ],
    );
  }

  Widget _buildTeamLogo(String logo) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: logo.isNotEmpty ? null : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: logo.isNotEmpty
          ? ClipOval(
              child: Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.group, size: 16, color: Colors.white54),
              ),
            )
          : const Icon(Icons.group, size: 16, color: Colors.white54),
    );
  }

  void _showEditGameDialog(BuildContext context, MatchModel match) {
    final provider = Provider.of<UnifiedGamesProvider>(context, listen: false);

    // Initial values
    DateTime selectedDate = match.matchDateTime ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    String selectedHomeTeam = match.homeTeam;
    String selectedHomeTeamId = match.homeTeamId ?? '';
    String selectedAwayTeam = match.awayTeam;
    String selectedAwayTeamId = match.awayTeamId ?? '';
    String? selectedVenueStr = match.venue;
    final List<String> availableVenues = [
      'Main Stadium',
      'Training Ground A',
      'Training Ground B',
      'City Arena',
      'Community Field',
    ];
    List<Map<String, dynamic>> leagueTeams = [];
    bool isLoadingTeams = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          if (isLoadingTeams && match.leagueId != null) {
            LeagueService.getLeagueById(match.leagueId!)
                .then((league) {
                  if (league != null) {
                    setState(() {
                      leagueTeams = league.teams
                          .map(
                            (t) => {
                              'id': t.id,
                              'name': t.teamName,
                              'logo': t.image ?? '',
                            },
                          )
                          .toList();
                      isLoadingTeams = false;
                    });
                  } else {
                    setState(() => isLoadingTeams = false);
                  }
                })
                .catchError((_) {
                  setState(() => isLoadingTeams = false);
                });
          } else if (match.leagueId == null) {
            isLoadingTeams = false;
          }

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Edit Game Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000000),
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Update match schedule, venue, or other game information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomField(
                            label: 'Edit Team A',
                            child: _buildTeamSelectionDropdown(
                              context: context,
                              placeholder: selectedHomeTeam,
                              teams: leagueTeams,
                              onSelected: (team) {
                                setState(() {
                                  selectedHomeTeam = team['name'];
                                  selectedHomeTeamId = team['id'];
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCustomField(
                            label: 'Edit Team B',
                            child: _buildTeamSelectionDropdown(
                              context: context,
                              placeholder: selectedAwayTeam,
                              teams: leagueTeams,
                              onSelected: (team) {
                                setState(() {
                                  selectedAwayTeam = team['name'];
                                  selectedAwayTeamId = team['id'];
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCustomField(
                      label: 'Game Date',
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 2),
                            ),
                          );
                          if (picked != null)
                            setState(() => selectedDate = picked);
                        },
                        child: _buildDisplayField(
                          text:
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCustomField(
                      label: 'Game Time',
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null)
                            setState(() => selectedTime = picked);
                        },
                        child: _buildDisplayField(
                          text: selectedTime.format(context),
                          icon: Icons.access_time_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCustomField(
                      label: 'Venue',
                      child: _buildVenueSelectionDropdown(
                        context: context,
                        placeholder: selectedVenueStr ?? 'Select Venue',
                        venues: availableVenues,
                        onSelected: (venue) {
                          setState(() {
                            selectedVenueStr = venue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPillButton(
                            text: 'Cancel',
                            onTap: () => Navigator.pop(context),
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: provider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildPillButton(
                                  text: 'Edit',
                                  onTap: () async {
                                    final finalDateTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );

                                    final success = await provider
                                        .updateMatchDetails(match.id ?? '', {
                                          'gameDate': finalDateTime
                                              .toIso8601String(),
                                          'gameTime':
                                              '${selectedTime.hour}:${selectedTime.minute}',
                                          'venue': selectedVenueStr ?? '',
                                          'homeTeamId': selectedHomeTeamId,
                                          'awayTeamId': selectedAwayTeamId,
                                          'teamAName': selectedHomeTeam,
                                          'teamBName': selectedAwayTeam,
                                        });

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Game updated successfully!'
                                                : 'Failed to update game',
                                          ),
                                          backgroundColor: success
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
            fontFamily: 'Lato',
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTeamSelectionDropdown({
    required BuildContext context,
    required String placeholder,
    required List<Map<String, dynamic>> teams,
    required Function(Map<String, dynamic>) onSelected,
  }) {
    return PopupMenuButton<Map<String, dynamic>>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 48),
      onSelected: onSelected,
      itemBuilder: (context) => teams.map((team) {
        return PopupMenuItem<Map<String, dynamic>>(
          value: team,
          child: Text(
            team['name'],
            style: const TextStyle(fontSize: 14, fontFamily: 'Lato'),
          ),
        );
      }).toList(),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                placeholder,
                style: TextStyle(
                  fontSize: 14,
                  color: placeholder == 'Team A' || placeholder == 'Team B'
                      ? Colors.grey[400]
                      : Colors.black,
                  fontFamily: 'Lato',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueSelectionDropdown({
    required BuildContext context,
    required String placeholder,
    required List<String> venues,
    required Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 48),
      onSelected: onSelected,
      itemBuilder: (context) => venues.map((venue) {
        return PopupMenuItem<String>(
          value: venue,
          child: Text(
            venue,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Lato',
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
      child: _buildDisplayField(
        text: placeholder,
        icon: Icons.location_on_outlined,
      ),
    );
  }

  Widget _buildDisplayField({required String text, required IconData icon}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Lato',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon, color: Colors.grey[400], size: 18),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String text,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isOutlined ? Colors.white : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: isOutlined
            ? Border.all(color: const Color(0xFF000000), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isOutlined ? const Color(0xFF000000) : Colors.white,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpcommingGames extends StatelessWidget {
  final String? leagueId;
  const UpcommingGames({super.key, this.leagueId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedGamesProvider>(
      builder: (context, gamesProvider, child) {
        final leagueDetailProvider = Provider.of<LeagueDetailProvider>(context);
        final matches = leagueId != null
            ? leagueDetailProvider.getUpcomingGames()
            : gamesProvider.upcomingGamesPerLeague;

        // Always trigger data fetch on first build to ensure fresh data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (leagueId == null &&
              gamesProvider.allGames.isEmpty &&
              !gamesProvider.isLoading) {
            debugPrint(
              '🔄 UpcommingGames: Triggering data fetch via UnifiedGamesProvider...',
            );
            gamesProvider.fetchAllMatches();
          }
        });

        debugPrint('🔍 UpcommingGames Widget Build:');
        debugPrint(
          '   - Total games in provider: ${gamesProvider.allGames.length}',
        );
        debugPrint('   - Upcoming games per league: ${matches.length}');
        debugPrint('   - Is loading: ${gamesProvider.isLoading}');

        if (matches.isNotEmpty) {
          debugPrint(
            '   - First entry: ${matches.first.leagueName} - ${matches.first.homeTeam} vs ${matches.first.awayTeam}',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Games',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: const Color(0xff0F173E),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lato',
                  ),
                ),
                if (leagueId != null)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllMatchesScreen(
                            matches: matches
                                .map(
                                  (m) => GameModel(
                                    id: m.id ?? '',
                                    leagueName: m.leagueName,
                                    team1Name: m.homeTeam,
                                    team1Logo: m.homeTeamLogo,
                                    team2Name: m.awayTeam,
                                    team2Logo: m.awayTeamLogo,
                                    date: m.matchDateTime ?? DateTime.now(),
                                    time: m.time,
                                    isFeePaid: false,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'View more',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (matches.isEmpty)
              _buildEmptyState(context)
            else
              ...matches.map(
                (match) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: UpcommingGamesCardWidget(match: match),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No upcoming games scheduled',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            fontFamily: 'Lato',
          ),
        ),
      ),
    );
  }
}
