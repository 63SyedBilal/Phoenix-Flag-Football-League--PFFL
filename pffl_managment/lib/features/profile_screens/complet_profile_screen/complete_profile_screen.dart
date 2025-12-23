import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/profile_image_section.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/position_dropdown.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/emergency_contact_fields.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/success_bottom_sheet.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/jersey_number_field.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/terms_checkbox.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/complete_button.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/skip_button.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/error_message_display.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/screen_header.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/loading_overlay.dart';

/// Complete Profile Screen - First screen shown to Player role users
class CompleteProfileScreen extends StatelessWidget {
  final bool showBackButton;

  const CompleteProfileScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompleteProfileProvider()..initialize(),
      child: const _CompleteProfileView(),
    );
  }
}

class _CompleteProfileView extends StatelessWidget {
  const _CompleteProfileView();

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
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
                            'Complete Your Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This helps teams find you',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          const ProfileImageSection(),
                          const SizedBox(height: 32),
                          const PositionDropdown(),
                          
                          const SizedBox(height: 20),
                          const EmergencyContactFields(),
                          const SizedBox(height: 24),
                          const TermsCheckbox(),
                          if (provider.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            ErrorMessageDisplay(
                              message: provider.errorMessage!,
                            ),
                          ],
                          const SizedBox(height: 32),
                          const CompleteButton(),
                          const SizedBox(height: 16),
                          const SkipButton(),
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
