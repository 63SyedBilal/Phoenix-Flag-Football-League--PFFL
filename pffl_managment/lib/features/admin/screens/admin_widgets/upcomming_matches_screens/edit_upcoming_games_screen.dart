import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/provider/upcoming_games_provider.dart';
import 'package:pffl_managment/shared/widgets/reusable_date_time_field.dart';
import 'package:pffl_managment/shared/widgets/reusable_dropdown.dart';

class EditUpcomingGamesScreen extends StatelessWidget {
  const EditUpcomingGamesScreen({super.key});

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
          return Column(
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
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: provider.selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    provider.updateDate(picked);
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
                    provider.updateTime(picked);
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
                        await provider.saveMatch();
                        if (context.mounted) {
                          Navigator.of(context).pop();
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
          );
        },
      ),
    );
  }
}
