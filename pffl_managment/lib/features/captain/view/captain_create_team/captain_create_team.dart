import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/providers/create_team_provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/screen_header.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/team_logo_section.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/team_name_field.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/location_field.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/skill_level_dropdown.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/create_button.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/success_bottom_sheet.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/error_message_display.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/loading_overlay.dart';
import 'package:pffl_managment/routes/app_routes.dart';

/// Captain Create Team Screen
/// Allows captain to create their team after completing profile
class CaptainCreateTeam extends StatelessWidget {
  const CaptainCreateTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateTeamProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenHeader(),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Create Your Team',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Fill in the details below to create your team',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const TeamLogoSection(),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TeamNameField(),
                          const SizedBox(height: 24),
                          const LocationField(),
                          const SizedBox(height: 24),
                          const SkillLevelDropdown(),
                          const SizedBox(height: 32),
                          Consumer<CreateTeamProvider>(
                            builder: (context, provider, _) {
                              if (provider.errorMessage != null &&
                                  provider.errorMessage!.isNotEmpty) {
                                return Column(
                                  children: [
                                    ErrorMessageDisplay(
                                      message: provider.errorMessage!,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const CreateButton(),
                          const SizedBox(height: 16),
                          // Skip button - navigate to dashboard without creating team
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.captainDashboard,
                                  (route) => false,
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Skip for now',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Colors.grey[700],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<CreateTeamProvider>(
                builder: (context, provider, _) {
                  return LoadingOverlay(isLoading: provider.isLoading);
                },
              ),
              const SuccessBottomSheet(),
            ],
          ),
        ),
      ),
    );
  }
}
