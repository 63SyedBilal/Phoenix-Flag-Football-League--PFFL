import 'package:pffl_managment/screens/notification/player_notification/player_notification.dart';
import 'package:pffl_managment/screens/profile_screen/player_profile_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/screens/settings/sections/my_performance.dart';
import 'package:pffl_managment/features/payment_history/player_payment_history.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/shared_change_password/shared_change_passowrd.dart';

/// Player role settings configuration
/// Sections: Player Information, My Performance, Payment History, Notifications, Change Password
List<SettingsSectionModel> getPlayerSettings() {
  return [
    SettingsSectionModel(
      title: 'Player information',
      screen: const PlayerProfileScreen(),
    ),
    SettingsSectionModel(
      title: 'My performance',
      screen: const MyPerformanceScreen(),
    ),
    SettingsSectionModel(
      title: 'Payment history',
      screen: PlayerPaymentHistory(),
    ),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const PlayerNotification(),
    ),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const SharedChangePassowrd(),
    ),
  ];
}
