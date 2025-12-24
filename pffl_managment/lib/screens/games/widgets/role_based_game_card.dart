import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/core/services/league_service.dart';

/// Role-based game card widget
/// Shows different action sections based on user role
class RoleBasedGameCard extends StatelessWidget {
  final MatchModel match;
  final String userRole;
  final bool canEdit;
  final bool shouldShowPaymentPrompt;
  final VoidCallback? onPayLeagueFee;
  final Function(String?)? onTeamTap;

  const RoleBasedGameCard({
    Key? key,
    required this.match,
    required this.userRole,
    this.canEdit = false,
    this.shouldShowPaymentPrompt = false,
    this.onPayLeagueFee,
    this.onTeamTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailsScreen(match: match),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: 0.6,
                  child: Row(
                    children: [
                      Text(
                        match.leagueName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Lato',
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF111827),
                        size: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: GestureDetector(
                    onTap: onTeamTap != null && match.homeTeamId != null
                        ? () => onTeamTap!(match.homeTeamId)
                        : null,
                    child: Row(
                      children: [
                        _buildTeamLogo(match.homeTeamLogo),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            match.homeTeam,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Lato',
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      match.date,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      match.time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                // Away team
                SizedBox(
                  width: 100,
                  child: GestureDetector(
                    onTap: onTeamTap != null && match.awayTeamId != null
                        ? () => onTeamTap!(match.awayTeamId)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildTeamLogo(match.awayTeamLogo),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            match.awayTeam,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Lato',
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Divider
            Divider(
              height: 0,
              thickness: 0.5,
              color: const Color(0xFF000000).withValues(alpha: 0.12),
            ),

            // Simple text below divider
            const SizedBox(height: 8),
            // Role-based action section
            _buildActionSection(context, match),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String logoUrl) {
    if (logoUrl.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: const Center(
          child: Text(
            'No\nLogo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              height: 1.1,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF000000).withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.5),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'No\nLogo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, MatchModel match) {
    // Captain with unpaid league fee
    if (shouldShowPaymentPrompt) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Your league payment still unpaid',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                color: Color(0xFFDC2626), // Red color for warning
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPayLeagueFee,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Pay League Fee',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ],
      );
    }

    // Admin or Captain (with paid fee) - show edit option
    if (canEdit) {
      return InkWell(
        onTap: () => _showEditGameDialog(context, match),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Game',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lato',
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios_outlined, size: 12),
          ],
        ),
      );
    }

    // Other roles - no action section (view-only)
    return const SizedBox.shrink();
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
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: PopupMenuButton<String>(
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
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Lato',
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
