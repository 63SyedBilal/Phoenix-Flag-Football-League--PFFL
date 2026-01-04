import 'package:pffl_managment/screens/notification/referee_notification/referee_notification.dart';
import 'package:pffl_managment/screens/profile_screen/referee_profile_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/shared_change_password/shared_change_passowrd.dart';

/// Referee role settings configuration
/// Sections: Profile Information, Change Password, Notifications
List<SettingsSectionModel> getRefereeSettings() {
  return [
    SettingsSectionModel(
      title: 'Profile information',
      screen: const RefereeProfileScreen(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const SharedChangePassowrd(),
    ),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const RefereeNotification(),
    ),
  ];
}
