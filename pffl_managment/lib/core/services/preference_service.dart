import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserRole = 'userRole';
  static const String keyUserId = 'userId';
  static const String keyUserToken = 'token';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserName = 'userName';
  static const String keySelectedLeagueId = 'selectedLeagueId';
  static const String keySelectedTeamId = 'selectedTeamId';
  static const String keyIsFirstLaunch = 'isFirstLaunch';
  static const String keyOnboardingCompleted = 'onboardingCompleted';
  static const String keyIsRefereeProfileComplete = 'isRefereeProfileComplete';

  static PreferenceService? _instance;
  late SharedPreferences _prefs;

  PreferenceService._();

  static Future<PreferenceService> getInstance() async {
    if (_instance == null) {
      _instance = PreferenceService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Generic methods
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();

  // Helper methods for specific keys
  bool get isLoggedIn => getBool(keyIsLoggedIn) ?? false;
  Future<void> setLoggedIn(bool value) => setBool(keyIsLoggedIn, value);

  String? get userRole => getString(keyUserRole);
  Future<void> setUserRole(String? value) =>
      value != null ? setString(keyUserRole, value) : remove(keyUserRole);

  String? get userId => getString(keyUserId);
  Future<void> setUserId(String? value) =>
      value != null ? setString(keyUserId, value) : remove(keyUserId);

  String? get userToken => getString(keyUserToken);
  Future<void> setUserToken(String? value) =>
      value != null ? setString(keyUserToken, value) : remove(keyUserToken);

  String? get userEmail => getString(keyUserEmail);
  Future<void> setUserEmail(String? value) =>
      value != null ? setString(keyUserEmail, value) : remove(keyUserEmail);

  String? get userName => getString(keyUserName);
  Future<void> setUserName(String? value) =>
      value != null ? setString(keyUserName, value) : remove(keyUserName);

  String? get selectedLeagueId => getString(keySelectedLeagueId);
  Future<void> setSelectedLeagueId(String? value) => value != null
      ? setString(keySelectedLeagueId, value)
      : remove(keySelectedLeagueId);

  String? get selectedTeamId => getString(keySelectedTeamId);
  Future<void> setSelectedTeamId(String? value) => value != null
      ? setString(keySelectedTeamId, value)
      : remove(keySelectedTeamId);

  bool get isFirstLaunch => getBool(keyIsFirstLaunch) ?? true;
  Future<void> setFirstLaunch(bool value) => setBool(keyIsFirstLaunch, value);

  bool get onboardingCompleted => getBool(keyOnboardingCompleted) ?? false;
  Future<void> setOnboardingCompleted(bool value) =>
      setBool(keyOnboardingCompleted, value);

  bool get isRefereeProfileComplete =>
      getBool(keyIsRefereeProfileComplete) ?? false;
  Future<void> setRefereeProfileComplete(bool value) =>
      setBool(keyIsRefereeProfileComplete, value);
}
