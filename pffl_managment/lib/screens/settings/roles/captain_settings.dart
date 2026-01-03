import 'package:pffl_managment/features/payment_history/captain_payment_history.dart';
import 'package:pffl_managment/features/profile_screens/captain_profile_screen/captain_profile_screen.dart';
import 'package:pffl_managment/screens/notification/captain_notification/captain_notification.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/features/captain/view/teams/team_management_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/shared_change_password/shared_change_passowrd.dart';

/// Captain role settings configuration
/// Sections: Profile Information, Team, Payment History, Notifications, Change Password
List<SettingsSectionModel> getCaptainSettings() {
  return [
    SettingsSectionModel(
      title: 'Profile information',
      screen: const CaptainProfileScreen(),
    ),
    SettingsSectionModel(title: 'Team', screen: const TeamManagementScreen()),
    SettingsSectionModel(
      title: 'Payment history',
      screen: CaptainPaymentHistory(),
    ),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const CaptainNotification(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const SharedChangePassowrd(),
    ),
  ];
}
