import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/features/profile_screens/admin_profile_screen.dart/admin_profile_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/change_passowrd.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/notification_screen.dart';

/// Referee role settings configuration
/// Sections: Profile Information, Change Password, Notifications
List<SettingsSectionModel> getRefereeSettings() {
  return [
    SettingsSectionModel(
      title: 'Profile information',
      screen: const AdminProfileScreen(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const ChangePassowrd(),
    ),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const NotificationsScreen(),
    ),
  ];
}
