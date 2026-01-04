import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/shared_change_password/shared_change_passowrd.dart';
import 'package:pffl_managment/screens/profile_screen/statkeeper_profile_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';

List<SettingsSectionModel> getStatKeeperSettings() {
  return [
    SettingsSectionModel(
      title: 'Profile information',
      screen: const StatkeeperProfileScreen(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const SharedChangePassowrd(),
    ),
  ];
}
