import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/screens/profile_screen/provider/base_profile_provider.dart';

class StatkeeperProfileProvider extends BaseProfileProvider {
  StatkeeperProfileProvider(super.prefsProvider);

  @override
  String get role => 'statkeeper';

  @override
  String get dashboardRoute => AppRoutes.statKeeperDashboard;
}
