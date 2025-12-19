import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/provider/upcoming_games_provider.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/shared/widgets/reusable_date_time_field.dart';
import 'package:pffl_managment/shared/widgets/reusable_dropdown.dart';
import 'package:pffl_managment/core/services/league_service.dart' show TeamModel;
import 'package:pffl_managment/core/services/user_service.dart' show UserModel;

class EditUpcomingGamesScreen extends StatelessWidget {
  final LeagueCreationModel? league;

  const EditUpcomingGamesScreen({
    super.key,
    this.league,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Consumer<UpcomingGamesProvider>(
        builder: (context, provider, child) {
          // Initialize provider if league is provided and not already initialized
          // Note: This is async, so we handle it in the loading state
          if (league != null && provider.leagueId == null && !provider.isLoadingTeams) {
            provider.initializeWithLeague(league!);
          } else if (league == null && provider.availableTeams.isEmpty && !provider.isLoadingTeams) {
            provider.initializeWithoutLeague();
          }

          // Show loading state
          if (provider.isLoadingTeams ||
              provider.isLoadingReferees ||
              provider.isLoadingStatKeepers) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Edit Game Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Update match schedule, venue, or other\ngame information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 24),

                // Team A
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Team A',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildTeamDropdown(
                  provider,
                  provider.selectedTeamAId,
                  (val) => provider.updateTeamA(val),
                ),
                const SizedBox(height: 16),

                // Team B
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Team B',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildTeamDropdown(
                  provider,
                  provider.selectedTeamBId,
                  (val) => provider.updateTeamB(val),
                ),
                const SizedBox(height: 16),

                // Game Date
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Game Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ReusableDateTimeField(
                  text: provider.selectedDate != null
                      ? "${provider.selectedDate!.day}/${provider.selectedDate!.month}/${provider.selectedDate!.year}"
                      : 'Edit Game Date',
                  icon: Icons.calendar_today_outlined,
                  isPlaceholder: provider.selectedDate == null,
                  onTap: () async {
                    final firstDate = provider.leagueStartDate ?? DateTime(2020);
                    final lastDate = provider.leagueEndDate ?? DateTime(2030);
                    final initialDate = provider.selectedDate ??
                        (firstDate.isAfter(DateTime.now())
                            ? firstDate
                            : DateTime.now());

                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: firstDate,
                      lastDate: lastDate,
                    );
                    if (picked != null) {
                      try {
                        await provider.updateDate(picked);
                      } catch (e) {
                        if (context.mounted) {
                          // Display user-friendly error message
                          final errorMessage = e.toString().replaceAll('Exception: ', '');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Game Time
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Game Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ReusableDateTimeField(
                  text: provider.selectedTime != null
                      ? provider.selectedTime!.format(context)
                      : 'Edit Game Time',
                  icon: Icons.access_time,
                  isPlaceholder: provider.selectedTime == null,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: provider.selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      try {
                        await provider.updateTime(picked);
                      } catch (e) {
                        if (context.mounted) {
                          // Display user-friendly error message
                          final errorMessage = e.toString().replaceAll('Exception: ', '');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Venue
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Venue',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ReusableDropdown(
                  value: provider.selectedVenue,
                  items: provider.availableVenues,
                  hint: 'Select Venue',
                  onChanged: (value) => provider.updateVenue(value),
                ),
                const SizedBox(height: 16),

                // Game Stage
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Game Stage',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ReusableDropdown(
                  value: provider.selectedRoundName,
                  items: provider.availableStages,
                  hint: 'Select Stage',
                  onChanged: (value) => provider.updateRoundName(value),
                ),
                const SizedBox(height: 16),

                // Referee
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Referee (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildUserDropdown(
                  provider,
                  provider.selectedRefereeId,
                  provider.availableReferees,
                  (val) => provider.updateReferee(val),
                ),
                const SizedBox(height: 16),

                // Stat Keeper
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Stat Keeper (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildUserDropdown(
                  provider,
                  provider.selectedStatKeeperId,
                  provider.availableStatKeepers,
                  (val) => provider.updateStatKeeper(val),
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Buttons
                Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await provider.updateMatch();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Game updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            // Display user-friendly error message
                            final errorMessage = e.toString().replaceAll('Exception: ', '');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF111827), // Dark navy
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamDropdown(
    UpcomingGamesProvider provider,
    String? value,
    Function(String?) onChanged,
  ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            'Select Team',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[400],
            size: 20,
          ),
          isExpanded: true,
          items: provider.availableTeams.map((TeamModel team) {
            return DropdownMenuItem<String>(
              value: team.id,
              child: Text(
                team.teamName,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildUserDropdown(
    UpcomingGamesProvider provider,
    String? value,
    List<UserModel> users,
    Function(String?) onChanged,
  ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            'Select',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[400],
            size: 20,
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'None',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            ...users.map((UserModel user) {
              return DropdownMenuItem<String>(
                value: user.id,
                child: Text(
                  user.displayName,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
