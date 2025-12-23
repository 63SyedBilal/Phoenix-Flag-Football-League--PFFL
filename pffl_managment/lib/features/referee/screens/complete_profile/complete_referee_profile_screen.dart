import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/referee/providers/complete_referee_profile_provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/widgets/loading_overlay.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CompleteRefereeProfileScreen extends StatelessWidget {
  const CompleteRefereeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CompleteRefereeProfileView();
  }
}

class _CompleteRefereeProfileView extends StatelessWidget {
  const _CompleteRefereeProfileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CompleteRefereeProfileProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const ArrowBackButton(),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontFamily: 'Serotiva',
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This helps teams find you',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 22),

                    _buildImageSection(context, provider, theme),

                    const SizedBox(height: 22),

                    // Years of Experience Dropdown
                    _buildFieldLabel('Years of Experience'),
                    const SizedBox(height: 8),
                    _buildExperienceDropdown(context, provider),

                    const SizedBox(height: 24),

                    // Emergency Contact Name
                    _buildFieldLabel('Emergency Contact Name'),
                    const SizedBox(height: 8),
                    _buildNameField(context, provider),

                    const SizedBox(height: 24),

                    // Emergency Phone Number
                    _buildFieldLabel('Emergency Phone Number'),
                    const SizedBox(height: 8),
                    _buildPhoneField(context, provider),

                    const SizedBox(height: 24),

                    // Terms & Privacy
                    _buildTermsSection(context, provider),

                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Actions
                    _buildActions(context, provider),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
              LoadingOverlay(isLoading: provider.isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    CompleteRefereeProfileProvider provider,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            DottedBorder(
              options: CircularDottedBorderOptions(
                dashPattern: const [5, 5],
                strokeWidth: 1,
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : const Color.fromRGBO(0, 0, 0, 0.4),
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: Center(
                    child: provider.profileImagePath != null
                        ? Image.file(
                            File(provider.profileImagePath!),
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          )
                        : Icon(
                            Icons.person_outline,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -9,
              child: GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: false,
                  );
                  if (result != null && result.files.single.path != null) {
                    provider.setProfileImage(result.files.single.path);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.88),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload, size: 12, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Upload',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          height: 1.37,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Profile Pic',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Submit this image if you think it\'s readable or tap on re-upload button to upload another one',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lato',
              color: Colors.grey[400],
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceDropdown(
    BuildContext context,
    CompleteRefereeProfileProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.experience,
          hint: Text(
            'e.g 3-5',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontFamily: 'Lato',
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 20,
          ),
          items: provider.experienceOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontSize: 14, fontFamily: 'Lato'),
              ),
            );
          }).toList(),
          onChanged: (value) {
            provider.setExperience(value);
          },
        ),
      ),
    );
  }

  Widget _buildNameField(
    BuildContext context,
    CompleteRefereeProfileProvider provider,
  ) {
    return TextField(
      style: const TextStyle(fontSize: 14, fontFamily: 'Lato'),
      decoration: InputDecoration(
        hintText: 'e.g Tyler',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
          fontFamily: 'Lato',
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F173E), width: 1.5),
        ),
      ),
      onChanged: (value) => provider.setEmergencyContactName(value),
    );
  }

  Widget _buildPhoneField(
    BuildContext context,
    CompleteRefereeProfileProvider provider,
  ) {
    return ImprovedPhoneField(
      onInputChanged: (PhoneNumber number) {
        provider.setEmergencyPhone(number.completeNumber);
      },
      onInputValidated: (bool value) {
        // Validation handled in provider
      },
      initialCountryCode: 'US',
      hintText: 'e.g +44 123 456 7890',
      errorText: provider.phoneError,
    );
  }

  Widget _buildTermsSection(
    BuildContext context,
    CompleteRefereeProfileProvider provider,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: provider.agreedToTerms,
            activeColor: const Color(0xFF0F173E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) => provider.setAgreedToTerms(value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'I agree to Terms & Privacy',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    CompleteRefereeProfileProvider provider,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: provider.isFormValid
                ? () async {
                    final success = await provider.submitProfile();
                    if (success && context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.refereeDashboard,
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F173E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Complete Setup',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () async {
            await provider.skipForNow();
            if (context.mounted) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.refereeDashboard,
              );
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lato',
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
