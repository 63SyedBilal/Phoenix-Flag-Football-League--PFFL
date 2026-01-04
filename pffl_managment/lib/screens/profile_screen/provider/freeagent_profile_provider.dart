import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/screens/profile_screen/provider/athlete_profile_provider.dart';

class FreeagentProfileProvider extends AthleteProfileProvider {
  FreeagentProfileProvider(super.prefsProvider);

  @override
  String get role => 'freeagent';

  @override
  String get dashboardRoute => AppRoutes.freeAgentDashboard;
}
