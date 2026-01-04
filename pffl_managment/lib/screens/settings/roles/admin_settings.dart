import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/payment_history/payment_history.dart';
import 'package:pffl_managment/screens/notification/admin_notification/admin_notification.dart';
import 'package:pffl_managment/screens/settings/common/settings_section_model.dart';
import 'package:pffl_managment/screens/profile_screen/admin_profile_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/sponser_screen/sponser_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/shared_change_password/shared_change_passowrd.dart';

/// Admin role settings configuration
/// Sections: Profile Information, Notifications, Payment History, Sponsors, Change Password
List<SettingsSectionModel> getAdminSettings() {
  return [
    SettingsSectionModel(
      title: 'Profile information',
      screen: const AdminProfileScreen(),
    ),
    SettingsSectionModel(
      title: 'Notifications',
      screen: const AdminNotification(),
    ),
    SettingsSectionModel(title: 'Payment history', screen: PaymentHistory()),
    SettingsSectionModel(title: 'Sponsers', screen: const SponserScreen()),
    SettingsSectionModel(
      title: 'Change Password',
      screen: const SharedChangePassowrd(),
    ),
  ];
}
