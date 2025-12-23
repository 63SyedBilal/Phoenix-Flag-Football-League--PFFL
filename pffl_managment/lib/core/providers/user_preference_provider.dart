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
  bool _isCaptainProfileComplete = false;
  bool _isProfileComplete = false;
  bool _hasCreatedTeam = false;

  String? _firstName;
  String? _lastName;
  String? _userPhone;
  String? _profileImage;
  String? _experience;
  String? _emergencyContactName;
  String? _emergencyPhone;
  String? _jerseyNumber;
  String? _position;

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
  bool get isCaptainProfileComplete => _isCaptainProfileComplete;
  bool get isProfileComplete => _isProfileComplete;
  bool get hasCreatedTeam => _hasCreatedTeam;

  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get userPhone => _userPhone;
  String? get profileImage => _profileImage;
  String? get experience => _experience;
  String? get emergencyContactName => _emergencyContactName;
  String? get emergencyPhone => _emergencyPhone;
  String? get jerseyNumber => _jerseyNumber;
  String? get position => _position;

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
    _isCaptainProfileComplete = _preferenceService.isCaptainProfileComplete;
    _isProfileComplete = _preferenceService.isProfileComplete;
    _hasCreatedTeam = _preferenceService.hasCreatedTeam;

    _firstName = _preferenceService.firstName;
    _lastName = _preferenceService.lastName;
    _userPhone = _preferenceService.userPhone;
    _profileImage = _preferenceService.profileImage;
    _experience = _preferenceService.experience;
    _emergencyContactName = _preferenceService.emergencyContactName;
    _emergencyPhone = _preferenceService.emergencyPhone;
    _jerseyNumber = _preferenceService.jerseyNumber;
    _position = _preferenceService.position;
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

  Future<void> setCaptainProfileComplete(bool value) async {
    _isCaptainProfileComplete = value;
    await _preferenceService.setCaptainProfileComplete(value);
    notifyListeners();
  }

  Future<void> setProfileComplete(bool value) async {
    _isProfileComplete = value;
    await _preferenceService.setProfileComplete(value);
    notifyListeners();
  }

  Future<void> setFirstName(String? value) async {
    _firstName = value;
    await _preferenceService.setFirstName(value);
    notifyListeners();
  }

  Future<void> setLastName(String? value) async {
    _lastName = value;
    await _preferenceService.setLastName(value);
    notifyListeners();
  }

  Future<void> setUserPhone(String? value) async {
    _userPhone = value;
    await _preferenceService.setUserPhone(value);
    notifyListeners();
  }

  Future<void> setProfileImage(String? value) async {
    _profileImage = value;
    await _preferenceService.setProfileImage(value);
    notifyListeners();
  }

  Future<void> setExperience(String? value) async {
    _experience = value;
    await _preferenceService.setExperience(value);
    notifyListeners();
  }

  Future<void> setEmergencyContactName(String? value) async {
    _emergencyContactName = value;
    await _preferenceService.setEmergencyContactName(value);
    notifyListeners();
  }

  Future<void> setEmergencyPhone(String? value) async {
    _emergencyPhone = value;
    await _preferenceService.setEmergencyPhone(value);
    notifyListeners();
  }

  Future<void> setJerseyNumber(String? value) async {
    _jerseyNumber = value;
    await _preferenceService.setJerseyNumber(value);
    notifyListeners();
  }

  Future<void> setPosition(String? value) async {
    _position = value;
    await _preferenceService.setPosition(value);
    notifyListeners();
  }

  Future<void> setHasCreatedTeam(bool value) async {
    _hasCreatedTeam = value;
    await _preferenceService.setHasCreatedTeam(value);
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
    _isCaptainProfileComplete = false;
    _isProfileComplete = false;
    _hasCreatedTeam = false;
    _firstName = null;
    _lastName = null;
    _userPhone = null;
    _profileImage = null;
    _experience = null;
    _emergencyContactName = null;
    _emergencyPhone = null;
    _jerseyNumber = null;
    _position = null;

    await _preferenceService.setLoggedIn(false);
    await _preferenceService.setUserRole(null);
    await _preferenceService.setUserId(null);
    await _preferenceService.setUserToken(null);
    await _preferenceService.setUserEmail(null);
    await _preferenceService.setUserName(null);
    await _preferenceService.setSelectedLeagueId(null);
    await _preferenceService.setSelectedTeamId(null);
    await _preferenceService.setRefereeProfileComplete(false);
    await _preferenceService.setCaptainProfileComplete(false);
    await _preferenceService.setProfileComplete(false);
    await _preferenceService.setHasCreatedTeam(false);
    await _preferenceService.setFirstName(null);
    await _preferenceService.setLastName(null);
    await _preferenceService.setUserPhone(null);
    await _preferenceService.setProfileImage(null);
    await _preferenceService.setExperience(null);
    await _preferenceService.setEmergencyContactName(null);
    await _preferenceService.setEmergencyPhone(null);
    await _preferenceService.setJerseyNumber(null);
    await _preferenceService.setPosition(null);

    notifyListeners();
  }
}
