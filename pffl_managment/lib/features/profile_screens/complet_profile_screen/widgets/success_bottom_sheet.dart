import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/routes/app_routes.dart';

/// Success bottom sheet widget shown after profile completion
class SuccessBottomSheet extends StatelessWidget {
  const SuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, _) {
        if (!provider.showSuccessSheet) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Prevent dismissing on background tap
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Profile Complete!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome to PFFL!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s see you at game.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(26),
                            onTap: () async {
                              provider.hideSuccessSheet();

                              // Check user role to determine next screen
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final role =
                                  prefs.getString('userRole') ??
                                  prefs.getString('role') ??
                                  authProvider.userRole;

                              // Determine route based on user role
                              String route;
                              switch (role.toLowerCase()) {
                                case 'captain':
                                  // For captain, check if team exists (fresh check after profile completion)
                                  // Don't rely on stale authProvider.needsTeamForm value
                                  try {
                                    final hasTeam = await TeamService.hasTeam();
                                    if (!hasTeam) {
                                      // Team doesn't exist, navigate to create team screen
                                      route = AppRoutes.captainCreateTeam;
                                    } else {
                                      // Team exists, go to dashboard
                                      route = AppRoutes.captainDashboard;
                                    }
                                  } catch (e) {
                                    // If check fails, default to create team screen
                                    debugPrint(
                                      '⚠️ Error checking team existence: $e',
                                    );
                                    route = AppRoutes.captainCreateTeam;
                                  }
                                  break;
                                case 'player':
                                  route = AppRoutes.playerDashboard;
                                  break;
                                case 'freeagent':
                                case 'free-agent':
                                  route = AppRoutes.freeAgentDashboard;
                                  break;
                                case 'referee':
                                  route = AppRoutes.refereeDashboard;
                                  break;
                                case 'statkeeper':
                                case 'stat-keeper':
                                  route = AppRoutes.statKeeperDashboard;
                                  break;
                                default:
                                  route = AppRoutes
                                      .playerDashboard; // Default fallback
                              }

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                route,
                                (route) => false,
                              );
                            },
                            child: const Center(
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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
