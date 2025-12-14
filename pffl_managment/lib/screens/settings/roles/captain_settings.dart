import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/features/profile_screens/admin_profile_screen.dart/admin_profile_screen.dart';
import 'package:pffl_managment/features/captain/view/teams/team_management_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/payment_history.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/notification_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/change_passowrd.dart';

/// Captain role settings configuration
/// Sections: Profile Information, Team, Payment History, Notifications, Change Password
List<SettingsSectionModel> getCaptainSettings() {
  return [
    SettingsSectionModel(
      title: 'Profile information',
      screen: const AdminProfileScreen(),
    ),
    SettingsSectionModel(title: 'Team', screen: const TeamManagementScreen()),
    SettingsSectionModel(title: 'Payment history', screen: PaymentHistory()),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const NotificationsScreen(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const ChangePassowrd(),
    ),
  ];
}
