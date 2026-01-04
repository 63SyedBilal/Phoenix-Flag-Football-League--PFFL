import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/screens/profile_screen/provider/athlete_profile_provider.dart';

class PlayerProfileProvider extends AthleteProfileProvider {
  PlayerProfileProvider(super.prefsProvider);

  @override
  String get role => 'player';

  @override
  String get dashboardRoute => AppRoutes.playerDashboard;
}
