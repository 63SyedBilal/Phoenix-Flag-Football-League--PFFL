import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserRole = 'userRole';
  static const String keyUserId = 'userId';
  static const String keyUserToken = 'token';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserName = 'userName';
  static const String keyFirstName = 'firstName';
  static const String keyLastName = 'lastName';
  static const String keyUserPhone = 'userPhone';
  static const String keyProfileImage = 'profileImage';
  static const String keySelectedLeagueId = 'selectedLeagueId';
  static const String keySelectedTeamId = 'selectedTeamId';
  static const String keyIsFirstLaunch = 'isFirstLaunch';
  static const String keyOnboardingCompleted = 'onboardingCompleted';
  static const String keyIsRefereeProfileComplete = 'isRefereeProfileComplete';
  static const String keyIsCaptainProfileComplete = 'isCaptainProfileComplete';
  static const String keyIsProfileComplete = 'isProfileComplete';
  static const String keyHasCreatedTeam = 'hasCreatedTeam';

  // Role specific fields
  static const String keyExperience = 'experience';
  static const String keyEmergencyContactName = 'emergencyContactName';
  static const String keyEmergencyPhone = 'emergencyPhone';
  static const String keyJerseyNumber = 'jerseyNumber';
  static const String keyPosition = 'position';

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

  bool get isCaptainProfileComplete =>
      getBool(keyIsCaptainProfileComplete) ?? false;
  Future<void> setCaptainProfileComplete(bool value) =>
      setBool(keyIsCaptainProfileComplete, value);

  bool get isProfileComplete => getBool(keyIsProfileComplete) ?? false;
  Future<void> setProfileComplete(bool value) =>
      setBool(keyIsProfileComplete, value);

  String? get firstName => getString(keyFirstName);
  Future<void> setFirstName(String? value) =>
      value != null ? setString(keyFirstName, value) : remove(keyFirstName);

  String? get lastName => getString(keyLastName);
  Future<void> setLastName(String? value) =>
      value != null ? setString(keyLastName, value) : remove(keyLastName);

  String? get userPhone => getString(keyUserPhone);
  Future<void> setUserPhone(String? value) =>
      value != null ? setString(keyUserPhone, value) : remove(keyUserPhone);

  String? get profileImage => getString(keyProfileImage);
  Future<void> setProfileImage(String? value) => value != null
      ? setString(keyProfileImage, value)
      : remove(keyProfileImage);

  String? get experience => getString(keyExperience);
  Future<void> setExperience(String? value) =>
      value != null ? setString(keyExperience, value) : remove(keyExperience);

  String? get emergencyContactName => getString(keyEmergencyContactName);
  Future<void> setEmergencyContactName(String? value) => value != null
      ? setString(keyEmergencyContactName, value)
      : remove(keyEmergencyContactName);

  String? get emergencyPhone => getString(keyEmergencyPhone);
  Future<void> setEmergencyPhone(String? value) => value != null
      ? setString(keyEmergencyPhone, value)
      : remove(keyEmergencyPhone);

  String? get jerseyNumber => getString(keyJerseyNumber);
  Future<void> setJerseyNumber(String? value) => value != null
      ? setString(keyJerseyNumber, value)
      : remove(keyJerseyNumber);

  String? get position => getString(keyPosition);
  Future<void> setPosition(String? value) =>
      value != null ? setString(keyPosition, value) : remove(keyPosition);

  bool get hasCreatedTeam => getBool(keyHasCreatedTeam) ?? false;
  Future<void> setHasCreatedTeam(bool value) =>
      setBool(keyHasCreatedTeam, value);
}
