import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/screens/profile_screen/provider/base_profile_provider.dart';

class RefereeProfileProvider extends BaseProfileProvider {
  RefereeProfileProvider(super.prefsProvider);

  @override
  String get role => 'referee';

  @override
  String get dashboardRoute => AppRoutes.refereeDashboard;
}
