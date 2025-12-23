import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/team_color_field.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/providers/create_team_provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/team_logo_section.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/team_name_field.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/location_field.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/skill_level_dropdown.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/create_button.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/success_bottom_sheet.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/error_message_display.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/loading_overlay.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';

/// Captain Create Team Screen
/// Allows captain to create their team after completing profile
class CaptainCreateTeam extends StatelessWidget {
  const CaptainCreateTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateTeamProvider(
        Provider.of<UserPreferenceProvider>(context, listen: false),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: ArrowBackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Build your team right here.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                 
                    const SizedBox(height: 16),
                    const TeamLogoSection(),
                    const SizedBox(height: 16),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Team Logo (Optional)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Please upload your team\'s logo in this section to ensure that we can represent your brand accurately.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TeamNameField(),
                          const SizedBox(height: 2),
                          const TeamColorField(), // Assuming you have a TeamColorField widget
                          const SizedBox(height: 2),
                          const LocationField(),
                          const SizedBox(height: 2),
                          const SkillLevelDropdown(),
                          const SizedBox(height: 2),
                          // Terms and Privacy Checkbox
                          Consumer<CreateTeamProvider>(
                            builder: (context, provider, _) {
                              return Row(
                                children: [
                                  Checkbox(
                                    value: provider.agreedToTerms,
                                    onChanged: (bool? value) {
                                      provider.setAgreedToTerms(value ?? false);
                                    },
                                    activeColor: const Color(0xFF0F172A),
                                  ),
                                  Text(
                                    'I agree to Terms & Privacy',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Consumer<CreateTeamProvider>(
                            builder: (context, provider, _) {
                              if (provider.fieldErrors['terms'] != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                                  child: Text(
                                    provider.fieldErrors['terms']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
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
