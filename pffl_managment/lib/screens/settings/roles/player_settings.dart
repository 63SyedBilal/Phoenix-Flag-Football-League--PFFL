import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/screens/settings/sections/player_information.dart';
import 'package:pffl_managment/screens/settings/sections/my_performance.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/payment_history.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/notification_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/change_passowrd.dart';

/// Player role settings configuration
/// Sections: Player Information, My Performance, Payment History, Notifications, Change Password
List<SettingsSectionModel> getPlayerSettings() {
  return [
    SettingsSectionModel(
      title: 'Player information',
      screen: const PlayerInformationScreen(),
    ),
    SettingsSectionModel(
      title: 'My performance',
      screen: const MyPerformanceScreen(),
    ),
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
