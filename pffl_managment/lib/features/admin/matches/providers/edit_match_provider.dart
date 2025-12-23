import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_detail_models.dart';

class EditMatchProvider extends ChangeNotifier {
  LeagueGameModel? _game;
  TextEditingController _teamAController = TextEditingController();
  TextEditingController _teamBController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedVenue = 'Select Venue';

  final List<String> _venues = [
    'Select Venue',
    'Stadium A',
    'Stadium B',
    'Stadium C',
    'Central Park Field',
    'University Ground'
  ];

  // Getters
  LeagueGameModel? get game => _game;
  TextEditingController get teamAController => _teamAController;
  TextEditingController get teamBController => _teamBController;
  DateTime get selectedDate => _selectedDate;
  TimeOfDay get selectedTime => _selectedTime;
  String get selectedVenue => _selectedVenue;
  List<String> get venues => _venues;

  // Initialize the provider with a game (if editing) or for creating a new game
  void initialize(LeagueGameModel? game) {
    _game = game;
    
    if (game != null) {
      _teamAController.text = game.team1Name;
      _teamBController.text = game.team2Name;
      _selectedDate = game.gameDateTime;
      _selectedTime = TimeOfDay.fromDateTime(game.gameDateTime);
    } else {
      _teamAController.clear();
      _teamBController.clear();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
    
    _selectedVenue = 'Select Venue';
    notifyListeners();
  }

  // Update team A name
  void updateTeamA(String value) {
    _teamAController.text = value;
    notifyListeners();
  }

  // Update team B name
  void updateTeamB(String value) {
    _teamBController.text = value;
    notifyListeners();
  }

  // Update selected date
  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Update selected time
  void updateSelectedTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  // Update selected venue
  void updateSelectedVenue(String venue) {
    _selectedVenue = venue;
    notifyListeners();
  }

  // Get combined date and time
  DateTime getCombinedDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  // Create updated game model
  LeagueGameModel createUpdatedGame() {
    return LeagueGameModel(
      id: _game?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      team1Name: _teamAController.text,
      team1Logo: _game?.team1Logo ?? '',
      team2Name: _teamBController.text,
      team2Logo: _game?.team2Logo ?? '',
      gameDateTime: getCombinedDateTime(),
    );
  }

  // Reset the provider
  void reset() {
    _teamAController.clear();
    _teamBController.clear();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedVenue = 'Select Venue';
    _game = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }
}
