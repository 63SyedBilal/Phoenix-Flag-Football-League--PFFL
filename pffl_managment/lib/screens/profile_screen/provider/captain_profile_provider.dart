import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/screens/profile_screen/provider/athlete_profile_provider.dart';

class CaptainProfileProvider extends AthleteProfileProvider {
  CaptainProfileProvider(super.prefsProvider);

  @override
  String get role => 'captain';

  @override
  String get dashboardRoute => AppRoutes.captainDashboard;
}
