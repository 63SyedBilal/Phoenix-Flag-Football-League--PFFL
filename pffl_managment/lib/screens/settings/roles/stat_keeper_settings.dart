import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/shared_change_password/shared_change_passowrd.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/features/profile_screens/admin_profile_screen.dart/admin_profile_screen.dart';

/// Stat Keeper role settings configuration
/// Sections: Profile Information, Change Password
List<SettingsSectionModel> getStatKeeperSettings() {
  return [
    SettingsSectionModel(
      title: 'Profile information',
      screen: const AdminProfileScreen(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const SharedChangePassowrd(),
    ),
  ];
}
