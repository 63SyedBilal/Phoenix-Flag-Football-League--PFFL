import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

class UpcomingGamesProvider extends ChangeNotifier {
  MatchModel? _editingMatch;
  String? _selectedTeamA;
  String? _selectedTeamB;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedVenue;

  // Mock Data for Dropdowns
  final List<String> _teams = [
    'Shadow Wolves',
    'Iron Rangers',
    'Eagle Eye',
    'Thunder Strike',
    'Mystic Dragons',
  ];

  final List<String> _venues = [
    'Select Venue',
    'Main Stadium',
    'Training Ground A',
    'City Arena',
  ];

  // Getters
  MatchModel? get editingMatch => _editingMatch;
  String? get selectedTeamA => _selectedTeamA;
  String? get selectedTeamB => _selectedTeamB;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String? get selectedVenue => _selectedVenue;
  List<String> get availableTeams => _teams;
  List<String> get availableVenues => _venues;

  void loadMatch(MatchModel match) {
    _editingMatch = match;
    _selectedTeamA = match.homeTeam;
    _selectedTeamB = match.awayTeam;
    // Parsing date and time strings to objects would happen here in a real app
    // For now we will try to parse if possible or default to now
    try {
      // Assuming date format dd/MM/yyyy used in other parts
      // _selectedDate = ...
      _selectedDate = DateTime.now(); // Placeholder default
    } catch (e) {
      _selectedDate = DateTime.now();
    }

    // Parse Time
    _selectedTime = TimeOfDay.now(); // Placeholder default

    _selectedVenue = match.venue ?? _venues.first;
    notifyListeners();
  }

  void updateTeamA(String? team) {
    _selectedTeamA = team;
    notifyListeners();
  }

  void updateTeamB(String? team) {
    _selectedTeamB = team;
    notifyListeners();
  }

  void updateDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void updateTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  void updateVenue(String? venue) {
    _selectedVenue = venue;
    notifyListeners();
  }

  Future<void> saveMatch() async {
    // Logic to save match to backend or update the main list
    print(
      'Saving match: $_selectedTeamA vs $_selectedTeamB at $_selectedVenue',
    );
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }
}
