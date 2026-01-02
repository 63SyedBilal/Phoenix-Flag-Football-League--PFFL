import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

/// Complete profile submission button widget
class CompleteButton extends StatelessWidget {
  const CompleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, _) {
        final isEnabled = !provider.isLoading && provider.isFormValid;

        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: isEnabled
                ? const Color(0xFF0F172A)
                : const Color(0xFF0F172A).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: isEnabled
                  ? () async {
                      final success = await provider.submitProfile();
                      if (success && context.mounted) {
                        // Get user role and redirect to appropriate dashboard
                        final prefs = await SharedPreferences.getInstance();
                        final userRole = prefs.getString('userRole') ?? 'player';
                        
                        // Determine route based on user role
                        String route;
                        switch (userRole.toLowerCase()) {
                          case 'admin':
                            route = AppRoutes.adminDashboard;
                            break;
                          case 'captain':
                            route = AppRoutes.captainDashboard;
                            break;
                          case 'player':
                            route = AppRoutes.playerDashboard;
                            break;
                          case 'referee':
                            route = AppRoutes.refereeDashboard;
                            break;
                          case 'stat_keeper':
                            route = AppRoutes.statKeeperDashboard;
                            break;
                          case 'free_agent':
                            route = AppRoutes.freeAgentDashboard;
                            break;
                          default:
                            route = AppRoutes.playerDashboard;
                        }

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          route,
                          (route) => false,
                        );
                      }
                    }
                  : null,
              child: Center(
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}