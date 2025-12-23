import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/provider/upcoming_games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/create_games_screens/game_created_bottom_sheet.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/services/league_service.dart'
    show TeamModel;
import 'package:pffl_managment/core/services/user_service.dart' show UserModel;

class CreateUpcomingGamesScreen extends StatelessWidget {
  final LeagueCreationModel league;

  const CreateUpcomingGamesScreen({super.key, required this.league});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: ArrowBackButton()),
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (_) {
            final provider = UpcomingGamesProvider();
            // Initialize with league data
            provider.initializeWithLeague(league);
            return provider;
          },
          child: Consumer<UpcomingGamesProvider>(
            builder: (context, provider, child) {
              // Show loading state
              if (provider.isLoadingTeams ||
                  provider.isLoadingReferees ||
                  provider.isLoadingStatKeepers) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show error state
              if (provider.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              provider.initializeWithLeague(league),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create New Game',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Schedule a new game for this league by filling out the details below.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTeamDropdownField(
                                  label: 'Select Team A',
                                  value: provider.selectedTeamAId,
                                  teams: provider.availableTeams,
                                  hint: 'Team A',
                                  onChanged: (val) => provider.updateTeamA(val),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTeamDropdownField(
                                  label: 'Select Team B',
                                  value: provider.selectedTeamBId,
                                  teams: provider.availableTeams,
                                  hint: 'Team B',
                                  onChanged: (val) => provider.updateTeamB(val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildDateField(context, provider),
                          const SizedBox(height: 8),
                          _buildTimeField(context, provider),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            label: 'Venue (optional)',
                            value: provider.selectedVenue,
                            items: provider.availableVenues,
                            hint: 'Select Venue',
                            onChanged: (val) => provider.updateVenue(val),
                          ),
                          const SizedBox(height: 8),
                          _buildRefereeDropdownField(provider),
                          const SizedBox(height: 8),
                          _buildStatKeeperDropdownField(provider),
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
                          _buildCreateButton(context, provider),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
                hint,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[400],
                size: 20,
              ),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, UpcomingGamesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final firstDate = provider.leagueStartDate ?? DateTime.now();
            final lastDate = provider.leagueEndDate ?? DateTime(2030);
            final initialDate =
                provider.selectedDate ??
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
                  final errorMessage = e.toString().replaceAll(
                    'Exception: ',
                    '',
                  );
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
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.selectedDate != null
                      ? "${provider.selectedDate!.day}/${provider.selectedDate!.month}/${provider.selectedDate!.year}"
                      : 'Select Game Date',
                  style: TextStyle(
                    fontSize: 14,
                    color: provider.selectedDate != null
                        ? Colors.black
                        : Colors.grey[400],
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(BuildContext context, UpcomingGamesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              try {
                await provider.updateTime(picked);
              } catch (e) {
                if (context.mounted) {
                  // Display user-friendly error message
                  final errorMessage = e.toString().replaceAll(
                    'Exception: ',
                    '',
                  );
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
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.selectedTime != null
                      ? provider.selectedTime!.format(context)
                      : 'Edit Game Time',
                  style: TextStyle(
                    fontSize: 14,
                    color: provider.selectedTime != null
                        ? Colors.black
                        : Colors.grey[400],
                  ),
                ),
                Icon(
                  Icons.access_time_outlined,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build team dropdown field
  /// In the future, teams will be fetched from the backend API
  /// Teams will be created by captains during team creation process
  Widget _buildTeamDropdownField({
    required String label,
    required String? value,
    required List<TeamModel> teams,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
                teams.isEmpty ? 'Loading teams...' : hint,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[400],
                size: 20,
              ),
              isExpanded: true,
              items: teams.isEmpty
                  ? null
                  : teams.map((TeamModel team) {
                      return DropdownMenuItem<String>(
                        value: team.id,
                        child: Text(
                          team.teamName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
              onChanged: teams.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefereeDropdownField(UpcomingGamesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assign Referee (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedRefereeId,
              hint: Text(
                'Select Referee',
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
                ...provider.availableReferees.map((UserModel referee) {
                  return DropdownMenuItem<String>(
                    value: referee.id,
                    child: Text(
                      referee.displayName,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  );
                }),
              ],
              onChanged: (val) => provider.updateReferee(val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatKeeperDropdownField(UpcomingGamesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assign Stat Keeper (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedStatKeeperId,
              hint: Text(
                'Select Stat Keeper',
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
                ...provider.availableStatKeepers.map((UserModel statKeeper) {
                  return DropdownMenuItem<String>(
                    value: statKeeper.id,
                    child: Text(
                      statKeeper.displayName,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  );
                }),
              ],
              onChanged: (val) => provider.updateStatKeeper(val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(
    BuildContext context,
    UpcomingGamesProvider provider,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () async {
            try {
              await provider.createMatch();
              if (context.mounted) {
                Navigator.pop(context); // Close create screen
                showGameCreatedBottomSheet(context); // Show success sheet
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
          child: const Center(
            child: Text(
              'Create Game',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
