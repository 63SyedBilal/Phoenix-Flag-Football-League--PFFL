import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/screens/profile_screen/provider/base_profile_provider.dart';

class AdminProfileProvider extends BaseProfileProvider {
  AdminProfileProvider(super.prefsProvider);

  @override
  String get role => 'admin';

  @override
  String get dashboardRoute => AppRoutes.adminDashboard;
}
