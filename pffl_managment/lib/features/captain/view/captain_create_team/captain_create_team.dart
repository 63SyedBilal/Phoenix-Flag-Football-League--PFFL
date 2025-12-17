import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/providers/create_team_provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/team_logo_section.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/team_name_field.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/team_color_field.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/location_field.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/skill_level_dropdown.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/success_bottom_sheet.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/screen_header.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/loading_overlay.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/error_message_display.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/create_button.dart';

/// Captain Create Team Screen - Shown after profile completion for Captain role
class CreateTeamScreen extends StatelessWidget {
  const CreateTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateTeamProvider(),
      child: const _CreateTeamView(),
    );
  }
}

class _CreateTeamView extends StatelessWidget {
  const _CreateTeamView();

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F0F0),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    if (provider.showSuccessSheet == false)
                      const ScreenHeader(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Create Your Team',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Build your team right here.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          const TeamLogoSection(),
                          const SizedBox(height: 32),
                          const TeamNameField(),
                          const SizedBox(height: 20),
                          const TeamColorField(),
                          const SizedBox(height: 20),
                          const LocationField(),
                          const SizedBox(height: 20),
                          const SkillLevelDropdown(),
                          if (provider.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            ErrorMessageDisplay(
                              message: provider.errorMessage!,
                            ),
                          ],
                          const SizedBox(height: 32),
                          const CreateButton(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              LoadingOverlay(isLoading: provider.isLoading),
              const SuccessBottomSheet(),
            ],
          ),
        );
      },
    );
  }
}
