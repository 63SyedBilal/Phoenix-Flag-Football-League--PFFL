import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/provider/upcoming_games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/upcomming_matches_screens/game_created_bottom_sheet.dart';

class CreateUpcomingGamesScreen extends StatelessWidget {
  const CreateUpcomingGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ArrowBackButton(),
      ),
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (_) => UpcomingGamesProvider(),
          child: Consumer<UpcomingGamesProvider>(
            builder: (context, provider, child) {
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
                                child: _buildDropdownField(
                                  label: 'Select Team A',
                                  value: provider.selectedTeamA,
                                  items: provider.availableTeams,
                                  hint: 'Team A',
                                  onChanged: (val) => provider.updateTeamA(val),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'Select Team B',
                                  value: provider.selectedTeamB,
                                  items: provider.availableTeams,
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
                          _buildDropdownField(
                            label: 'Assign Referee (optional)',
                            value: null,
                            items: ['Referee 1', 'Referee 2'],
                            hint: 'Select Referee',
                            onChanged: (val) {},
                          ),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            label: 'Assign Stat Keeper (optional)',
                            value: null,
                            items: ['Stat Keeper 1', 'Stat Keeper 2'],
                            hint: 'Select Stat Keeper',
                            onChanged: (val) {},
                          ),
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
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              provider.updateDate(picked);
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
              provider.updateTime(picked);
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
            await provider.saveMatch();
            if (context.mounted) {
              Navigator.pop(context); // Close create screen
              showGameCreatedBottomSheet(context); // Show success sheet
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
