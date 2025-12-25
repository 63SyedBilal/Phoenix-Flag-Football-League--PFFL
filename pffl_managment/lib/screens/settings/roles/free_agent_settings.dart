import 'package:pffl_managment/features/profile_screens/admin_profile_screen.dart/admin_profile_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_payment_history_screen.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_notifications_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/change_passowrd.dart';

/// Free Agent role settings configuration
/// Sections: Player Information, Change Password, Notifications, Payment History
List<SettingsSectionModel> getFreeAgentSettings() {
  return [
    SettingsSectionModel(
      title: 'Player information',
      screen: const AdminProfileScreen(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const ChangePassowrd(),
    ),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const FreeAgentNotificationsScreen(),
    ),
    SettingsSectionModel(
      title: 'Payment history',
      screen: const FreeAgentPaymentHistoryScreen(),
    ),
  ];
}
