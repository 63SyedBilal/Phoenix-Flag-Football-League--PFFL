import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/profile_image_section.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/position_dropdown.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/jersey_number_field.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/emergency_contact_fields.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/success_bottom_sheet.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/terms_checkbox.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/complete_button.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/skip_button.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/error_message_display.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/widgets/loading_overlay.dart';

class CompleteProfileScreen extends StatelessWidget {
  final bool showBackButton;

  const CompleteProfileScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CompleteProfileProvider(
        Provider.of<UserPreferenceProvider>(context, listen: false),
      )..initialize(),
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
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: ArrowBackButton(),
          ),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: SizedBox.expand(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            const Text(
                              'Complete Your Profile',
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: 'Serotiva',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF000000),
                              ),
                            ),

                            Text(
                              'This helps teams find you',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lato',
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const ProfileImageSection(),
                            const SizedBox(height: 22),
                            const PositionDropdown(),

                            const SizedBox(height: 8),
                            const JerseyNumberField(),
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
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
