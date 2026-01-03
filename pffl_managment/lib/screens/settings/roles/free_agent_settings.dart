import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/shared_change_password/shared_change_passowrd.dart';
import 'package:pffl_managment/features/profile_screens/admin_profile_screen.dart/admin_profile_screen.dart';
import 'package:pffl_managment/screens/notification/freeagent_notification/freeagent_notification.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_payment_history_screen.dart';

List<SettingsSectionModel> getFreeAgentSettings() {
  return [
    SettingsSectionModel(
      title: 'Player information',
      screen: const AdminProfileScreen(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const SharedChangePassowrd(),
    ),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const FreeAgentNotification(),
    ),
    SettingsSectionModel(
      title: 'Payment history',
      screen: const FreeAgentPaymentHistoryScreen(),
    ),
  ];
}
