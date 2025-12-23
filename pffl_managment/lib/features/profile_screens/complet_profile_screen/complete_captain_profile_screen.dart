import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_captain_profile_provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'dart:io';

class CompleteCaptainProfileScreen extends StatelessWidget {
  const CompleteCaptainProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CompleteCaptainProfileProvider(
        Provider.of<UserPreferenceProvider>(context, listen: false),
      )..initialize(),
      child: const _CompleteCaptainProfileView(),
    );
  }
}

class _CompleteCaptainProfileView extends StatelessWidget {
  const _CompleteCaptainProfileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<CompleteCaptainProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(leading: const ArrowBackButton()),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Your Profile',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This helps teams find you',
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
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
                            width: 125,
                            height: 125,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
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
                          left: 29,
                          child: GestureDetector(
                            onTap: () async {},
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.upload,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Upload',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontFamily: 'Satoshi Variable',
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
                  ),

                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Profile Pic',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "First Name",
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            CustomTextField(
                              hintText: 'First Name',
                              controller: provider.firstNameController,
                              errorText: provider.fieldErrors['firstName'],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Last Name",
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            CustomTextField(
                              hintText: 'Last Name',
                              controller: provider.lastNameController,
                              errorText: provider.fieldErrors['lastName'],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Emergency Contact Name",
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Last Name',
                    controller: provider.lastNameController,
                    errorText: provider.fieldErrors['lastName'],
                  ),
                  const SizedBox(height: 8),

                  Text("Phone Number", style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  ImprovedPhoneField(
                    onInputChanged: (PhoneNumber number) {
                      provider.setPhone(number.completeNumber);
                    },
                    onInputValidated: (bool value) {},
                    initialCountryCode: 'US',
                    hintText: 'Enter your phone number',
                    errorText: provider.fieldErrors['phone'],
                  ),

                  GestureDetector(
                    onTap: () =>
                        provider.toggleTermsAgreement(!provider.agreedToTerms),
                    child: Row(
                      children: [
                        Checkbox(
                          value: provider.agreedToTerms,
                          onChanged: (val) =>
                              provider.toggleTermsAgreement(val ?? false),
                          activeColor: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'I agree to Terms & Privacy',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (provider.fieldErrors['terms'] != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        provider.fieldErrors['terms']!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 14),

                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  CustomButton(
                    width: double.infinity,
                    textColor: AppColors.lightAppBarBackground,
                    text: provider.isLoading ? 'Processing...' : 'Complete',
                    onPressed: () async {
                      if (!provider.isLoading) {
                        final success = await provider.submitProfile();
                        if (success && context.mounted) {
                          final userPrefs = Provider.of<UserPreferenceProvider>(
                            context,
                            listen: false,
                          );
                          final targetRoute = userPrefs.hasCreatedTeam
                              ? AppRoutes.captainDashboard
                              : AppRoutes.captainCreateTeam;

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            targetRoute,
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      await provider.skipForNow();
                      if (context.mounted) {
                        final userPrefs = Provider.of<UserPreferenceProvider>(
                          context,
                          listen: false,
                        );
                        final targetRoute = userPrefs.hasCreatedTeam
                            ? AppRoutes.captainDashboard
                            : AppRoutes.captainCreateTeam;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          targetRoute,
                          (route) => false,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Skip for now',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator()),

          // Using the common SuccessBottomSheet if available,
          // but tailoring its behavior for captain
          if (provider.showSuccessSheet)
            _buildCaptainSuccessOverlay(context, provider),
        ],
      ),
    );
  }

  Widget _buildCaptainSuccessOverlay(
    BuildContext context,
    CompleteCaptainProfileProvider provider,
  ) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Profile Completed!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your captain profile is ready. Now you can create your team.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  provider.hideSuccessSheet();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.captainDashboard,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
