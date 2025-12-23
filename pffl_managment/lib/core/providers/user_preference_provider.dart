import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/services/preference_service.dart';

class UserPreferenceProvider extends ChangeNotifier {
  final PreferenceService _preferenceService;

  UserPreferenceProvider(this._preferenceService) {
    _loadAll();
  }

  bool _isLoggedIn = false;
  String? _userRole;
  String? _userId;
  String? _userToken;
  String? _userEmail;
  String? _userName;
  String? _selectedLeagueId;
  String? _selectedTeamId;
  bool _isFirstLaunch = true;
  bool _onboardingCompleted = false;
  bool _isRefereeProfileComplete = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;
  String? get userId => _userId;
  String? get userToken => _userToken;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get selectedLeagueId => _selectedLeagueId;
  String? get selectedTeamId => _selectedTeamId;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isRefereeProfileComplete => _isRefereeProfileComplete;

  void _loadAll() {
    _isLoggedIn = _preferenceService.isLoggedIn;
    _userRole = _preferenceService.userRole;
    _userId = _preferenceService.userId;
    _userToken = _preferenceService.userToken;
    _userEmail = _preferenceService.userEmail;
    _userName = _preferenceService.userName;
    _selectedLeagueId = _preferenceService.selectedLeagueId;
    _selectedTeamId = _preferenceService.selectedTeamId;
    _isFirstLaunch = _preferenceService.isFirstLaunch;
    _onboardingCompleted = _preferenceService.onboardingCompleted;
    _isRefereeProfileComplete = _preferenceService.isRefereeProfileComplete;
  }

  Future<void> setLoggedIn(bool value) async {
    _isLoggedIn = value;
    await _preferenceService.setLoggedIn(value);
    notifyListeners();
  }

  Future<void> setUserRole(String? value) async {
    _userRole = value;
    await _preferenceService.setUserRole(value);
    notifyListeners();
  }

  Future<void> setUserId(String? value) async {
    _userId = value;
    await _preferenceService.setUserId(value);
    notifyListeners();
  }

  Future<void> setUserToken(String? value) async {
    _userToken = value;
    await _preferenceService.setUserToken(value);
    notifyListeners();
  }

  Future<void> setUserEmail(String? value) async {
    _userEmail = value;
    await _preferenceService.setUserEmail(value);
    notifyListeners();
  }

  Future<void> setUserName(String? value) async {
    _userName = value;
    await _preferenceService.setUserName(value);
    notifyListeners();
  }

  Future<void> setSelectedLeagueId(String? value) async {
    _selectedLeagueId = value;
    await _preferenceService.setSelectedLeagueId(value);
    notifyListeners();
  }

  Future<void> setSelectedTeamId(String? value) async {
    _selectedTeamId = value;
    await _preferenceService.setSelectedTeamId(value);
    notifyListeners();
  }

  Future<void> setFirstLaunch(bool value) async {
    _isFirstLaunch = value;
    await _preferenceService.setFirstLaunch(value);
    notifyListeners();
  }

  Future<void> setOnboardingCompleted(bool value) async {
    _onboardingCompleted = value;
    await _preferenceService.setOnboardingCompleted(value);
    notifyListeners();
  }

  Future<void> setRefereeProfileComplete(bool value) async {
    _isRefereeProfileComplete = value;
    await _preferenceService.setRefereeProfileComplete(value);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userRole = null;
    _userId = null;
    _userToken = null;
    _userEmail = null;
    _userName = null;
    _selectedLeagueId = null;
    _selectedTeamId = null;
    _isRefereeProfileComplete = false;

    await _preferenceService.setLoggedIn(false);
    await _preferenceService.setUserRole(null);
    await _preferenceService.setUserId(null);
    await _preferenceService.setUserToken(null);
    await _preferenceService.setUserEmail(null);
    await _preferenceService.setUserName(null);
    await _preferenceService.setSelectedLeagueId(null);
    await _preferenceService.setSelectedTeamId(null);
    await _preferenceService.setRefereeProfileComplete(false);

    notifyListeners();
  }
}
