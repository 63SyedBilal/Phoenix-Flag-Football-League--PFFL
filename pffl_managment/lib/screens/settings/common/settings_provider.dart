import 'package:flutter/material.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/screens/settings/roles/admin_settings.dart';
import 'package:pffl_managment/screens/settings/roles/captain_settings.dart';
import 'package:pffl_managment/screens/settings/roles/player_settings.dart';
import 'package:pffl_managment/screens/settings/roles/free_agent_settings.dart';
import 'package:pffl_managment/screens/settings/roles/referee_settings.dart';
import 'package:pffl_managment/screens/settings/roles/stat_keeper_settings.dart';
import 'package:pffl_managment/core/utils/role_utils.dart';

class RoleBasedSettingsProvider extends ChangeNotifier {
  final String userRole;
  int _selectedSectionIndex = 0;

  RoleBasedSettingsProvider({required this.userRole});

  int get selectedSectionIndex => _selectedSectionIndex;

  List<SettingsSectionModel> get settingsSections {
    final normalizedRole = UserRoleUtils.normalizeRole(userRole);

    switch (normalizedRole) {
      case 'superadmin':
      case 'admin':
        return getAdminSettings();
      case 'captain':
        return getCaptainSettings();
      case 'player':
        return getPlayerSettings();
      case 'freeagent':
        return getFreeAgentSettings();
      case 'referee':
        return getRefereeSettings();
      case 'statkeeper':
        return getStatKeeperSettings();
      default:
        print(
          'Warning: Unknown role "$userRole" (normalized: "$normalizedRole"), defaulting to Player Settings',
        );
        return getPlayerSettings();
    }
  }

  void selectSection(int index) {
    _selectedSectionIndex = index;
    notifyListeners();
  }

  void navigateToSection(BuildContext context, int index) {
    final section = settingsSections[index];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => section.screen),
    );
  }
}
