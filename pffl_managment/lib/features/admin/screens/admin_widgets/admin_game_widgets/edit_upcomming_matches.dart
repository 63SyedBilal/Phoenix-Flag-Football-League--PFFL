import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';

class EditUpcommingMatches extends StatefulWidget {
  const EditUpcommingMatches({super.key});

  @override
  State<EditUpcommingMatches> createState() => _EditMatchViewState();
}

class _EditMatchViewState extends State<EditUpcommingMatches> {
  String? selectedTeamA;
  String? selectedTeamB;
  String? selectedVenue;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  final List<String> teams = [
    'Team Alpha',
    'Team Beta',
    'Team Gamma',
    'Team Delta',
  ];
  final List<String> venues = ['Stadium A', 'Stadium B', 'Ground C'];

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Edit Game Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "Update match schedule, venue, or other\ngame information.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// TEAM SELECTION
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit Team A",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SimpleDropdownList(
                      hintText: "Select Team",
                      selectedValue: selectedTeamA,
                      items: teams,
                      onSelected: (value) {
                        setState(() {
                          selectedTeamA = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit Team B",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SimpleDropdownList(
                      hintText: "Select Team",
                      selectedValue: selectedTeamB,
                      items: teams,
                      onSelected: (value) {
                        setState(() {
                          selectedTeamB = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// GAME DATE
          const Text(
            "Game Date",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          CustomTextField(
            controller: dateController,
            hintText: "Select Date",
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() {
                  dateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                });
              }
            },
          ),

          const SizedBox(height: 6),

          /// GAME TIME
          const Text(
            "Game Time",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          CustomTextField(
            controller: timeController,
            hintText: "Select Time",
            readOnly: true,
            suffixIcon: const Icon(Icons.access_time, size: 20),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  timeController.text = picked.format(context);
                });
              }
            },
          ),

          const SizedBox(height: 6),

          const Text(
            "Venue",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          SimpleDropdownList(
            hintText: "Select Venue",
            selectedValue: selectedVenue,
            items: venues,
            onSelected: (value) {
              setState(() {
                selectedVenue = value;
              });
            },
          ),

          const SizedBox(height: 12),

          /// BUTTONS
          Row(
            children: [
              Expanded(
                child: CustomButton.secondary(
                  text: "Cancel",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CustomButton.primary(
                  text: "Edit",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
