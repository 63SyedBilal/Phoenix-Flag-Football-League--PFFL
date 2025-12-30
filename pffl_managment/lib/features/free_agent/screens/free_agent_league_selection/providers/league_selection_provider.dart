import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/league_service.dart';

class LeagueSelectionProvider extends ChangeNotifier {
  List<LeagueModel> _availableLeagues = [];
  List<LeagueModel> _selectedLeagues = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LeagueModel> get availableLeagues => _availableLeagues;
  List<LeagueModel> get selectedLeagues => _selectedLeagues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get selectedCount => _selectedLeagues.length;
  int get totalCount => _availableLeagues.length;

  double get totalPrice {
    return _selectedLeagues.fold(
      0.0,
      (sum, league) => sum + league.perPlayerLeagueFee,
    );
  }

  bool isLeagueSelected(LeagueModel league) {
    return _selectedLeagues.any((l) => l.id == league.id);
  }

  Future<void> fetchAllLeagues() async {
    _setLoading(true);
    _clearError();

    try {
      final allLeagues = await LeagueService.getAllLeagues();
      _availableLeagues = List.from(allLeagues);

      // Sort: Newest created leagues first
      _availableLeagues.sort((a, b) {
        final dateA = a.createdAt ?? a.startDate;
        final dateB = b.createdAt ?? b.startDate;
        return dateB.compareTo(dateA);
      });
    } catch (e) {
      _errorMessage = 'Failed to load leagues: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void toggleLeagueSelection(LeagueModel league) {
    if (isLeagueSelected(league)) {
      _selectedLeagues.removeWhere((l) => l.id == league.id);
    } else {
      _selectedLeagues.add(league);
    }
    notifyListeners();
  }

  void selectLeague(LeagueModel league) {
    if (!isLeagueSelected(league)) {
      _selectedLeagues.add(league);
      notifyListeners();
    }
  }

  void clearAllSelections() {
    _selectedLeagues.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

