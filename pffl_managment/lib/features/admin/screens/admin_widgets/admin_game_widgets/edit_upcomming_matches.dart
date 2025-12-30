import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

class EditUpcommingMatches extends StatefulWidget {
  final MatchModel match;
  final bool hideTeamSelection;

  const EditUpcommingMatches({
    super.key,
    required this.match,
    this.hideTeamSelection = false,
  });

  @override
  State<EditUpcommingMatches> createState() => _EditMatchViewState();
}

class _EditMatchViewState extends State<EditUpcommingMatches> {
  String? selectedTeamA;
  String? selectedTeamB;
  String? selectedVenue;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  List<String> teams = [];
  bool isLoadingTeams = false;
  bool isSaving = false;

  final List<String> venues = [
    'Phoenix Turf Arena - Field 1',
    'Phoenix Turf Arena - Field 2',
    'Phoenix Turf Arena - Field 3',
    'City Stadium',
    'Training Ground',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Pre-fill date from matchDateTime if available
    if (widget.match.matchDateTime != null) {
      final d = widget.match.matchDateTime!;
      dateController.text = "${d.day}/${d.month}/${d.year}";
    } else {
      dateController.text = widget
          .match
          .date; // Fallback to string if needed but likely incomplete
    }

    timeController.text = widget.match.time;
    selectedTeamA = widget.match.homeTeam;
    selectedTeamB = widget.match.awayTeam;

    // Normalize venue
    if (widget.match.venue != null && widget.match.venue!.isNotEmpty) {
      if (!venues.contains(widget.match.venue)) {
        venues.add(widget.match.venue!);
      }
      selectedVenue = widget.match.venue;
    }

    // Fetch teams
    if (widget.match.leagueId != null) {
      setState(() => isLoadingTeams = true);
      try {
        final league = await LeagueService.getLeagueById(
          widget.match.leagueId!,
        );
        if (league != null) {
          setState(() {
            teams = league.teams.map((t) => t.teamName).toList();
            // Ensure proper lookup
            if (selectedTeamA != null && !teams.contains(selectedTeamA))
              teams.add(selectedTeamA!);
            if (selectedTeamB != null && !teams.contains(selectedTeamB))
              teams.add(selectedTeamB!);
          });
        }
      } catch (e) {
        setState(() {
          teams = [widget.match.homeTeam, widget.match.awayTeam];
        });
      } finally {
        setState(() => isLoadingTeams = false);
      }
    } else {
      teams = [widget.match.homeTeam, widget.match.awayTeam];
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> _updateMatch() async {
    if (isSaving) return;

    if (selectedTeamA == null ||
        selectedTeamB == null ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final Map<String, dynamic> updateData = {
        'teamAName': selectedTeamA,
        'teamBName': selectedTeamB,
        'gameDate': _parseDateForBackend(dateController.text),
        'gameTime': timeController.text,
        'venue': selectedVenue,
      };

      await MatchService.updateMatch(widget.match.id!, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Match updated successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating match: $e")));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  String _parseDateForBackend(String displayDate) {
    // displayDate is dd/MM/yyyy
    try {
      final parts = displayDate.split('/');
      final d = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final y = int.parse(parts[2]);
      return DateTime(y, m, d).toIso8601String();
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
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
                fontFamily: 'Serotiva',
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
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (isLoadingTeams) const LinearProgressIndicator(),

          /// TEAM SELECTION (hidden for playoff games)
          if (!widget.hideTeamSelection) ...[
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
                          fontFamily: 'Lato',
                          color: Color(0xFF111827),
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
                          fontFamily: 'Lato',
                          color: Color(0xFF111827),
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
          ],

          /// GAME DATE
          const Text(
            "Game Date",
            style: TextStyle(
              fontSize: 14,
           fontWeight: FontWeight.w500,
          fontFamily: 'Lato',
         color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          CustomTextField(
            controller: dateController,
            hintText: "Select Date",
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            onTap: () async {
              final initial = widget.match.matchDateTime ?? DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initial,
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
                fontFamily: 'Lato',
                   color: Color(0xFF111827),
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
              fontFamily: 'Lato',
                   color: Color(0xFF111827),
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
                child: isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton.primary(
                        text: "Edit",
                        onPressed: _updateMatch,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

