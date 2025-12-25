import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/utils/helpers.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';
import 'package:pffl_managment/core/widgets/text_with_text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';

class CompleteProfile extends StatelessWidget {
  const CompleteProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (context) => CompleteProfileProvider(
        Provider.of<UserPreferenceProvider>(context, listen: false),
      )..initialize(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(leading: ArrowBackButton()),
        body: SafeArea(
          child: Consumer<CompleteProfileProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This helps teams find you',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          DottedBorder(
                            options: CircularDottedBorderOptions(
                              dashPattern: const <double>[5, 5],
                              strokeWidth: 1,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white70
                                  : const Color.fromRGBO(0, 0, 0, 0.4),
                            ),
                            child: Container(
                              width: 120,
                              height: 120,
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
                            left: 30,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Profile Pic',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.70,
                      child: Text(
                        'Submit this image if you think it\'s readable or tap on re-upload button to upload another one',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Input Fields
                    Text('Position', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    SimpleDropdownList(
                      items: const [
                        'Quarterback',
                        'Receiver',
                        'Running Back',
                        'Linebacker',
                        'Cornerback',
                        'Safety',
                      ],
                      onSelected: (val) => provider.togglePosition(val),
                    ),
                    if (provider.fieldErrors['position'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          provider.fieldErrors['position']!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),

                    Text('Jersey Number', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    TextWithTextField(
                      hintText: 'e.g. 12',
                      onChanged: (val) => provider.setJerseyNumber(val),
                    ),
                    if (provider.fieldErrors['jerseyNumber'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          provider.fieldErrors['jerseyNumber']!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),

                    Text(
                      'Emergency Contact Name',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    TextWithTextField(
                      hintText: 'e.g. Tyler',
                      onChanged: (val) => provider.setEmergencyContactName(val),
                    ),
                    if (provider.fieldErrors['emergencyContactName'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          provider.fieldErrors['emergencyContactName']!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),

                    Text(
                      'Emergency Phone Number',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    ImprovedPhoneField(
                      onInputChanged: (PhoneNumber number) {
                        provider.setEmergencyPhone(number.completeNumber);
                      },
                      onInputValidated: (bool value) {
                        // Validation handled in provider
                      },
                      initialCountryCode: 'US',
                      hintText: 'e.g +1 123 456 7890',
                      errorText: provider.phoneError,
                    ),
                    const SizedBox(height: 20),

                    // Terms & Conditions
                    GestureDetector(
                      onTap: () => provider.toggleTermsAgreement(
                        !provider.agreedToTerms,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: provider.agreedToTerms,
                            onChanged: (val) =>
                                provider.toggleTermsAgreement(val),
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
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),

                    // Complete Button
                    if (provider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            textColor: AppColors.lightAppBarBackground,
                            text: 'Complete',
                            onPressed: () async {
                              final success = await provider.submitProfile();
                              if (success && context.mounted) {
                                final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                );
                                String targetRoute;

                                // Determine dashboard route based on role
                                switch (authProvider.userRole.toLowerCase()) {
                                  case 'captain':
                                    targetRoute = AppRoutes.captainDashboard;
                                    break;
                                  case 'referee':
                                    targetRoute = AppRoutes.refereeDashboard;
                                    break;
                                  case 'stat-keeper':
                                  case 'statkeeper':
                                    targetRoute = AppRoutes.statKeeperDashboard;
                                    break;
                                  case 'player':
                                    targetRoute = AppRoutes.playerDashboard;
                                    break;
                                  case 'freeagent':
                                  case 'free-agent':
                                    targetRoute = AppRoutes.freeAgentDashboard;
                                    break;
                                  default:
                                    targetRoute = AppRoutes.home;
                                }

                                showCustomBottomSheet(
                                  context: context,
                                  title: 'Profile Created',
                                  subtitle:
                                      "Welcome to PFFL.!\nLet's see some games.",
                                  buttonText: 'Continue',
                                  onButtonPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      targetRoute,
                                      (route) => false,
                                    );
                                  },
                                  content: Container(),
                                );
                              }
                            },
                          ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        await provider.skipForNow();
                        if (context.mounted) {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          String targetRoute;

                          switch (authProvider.userRole.toLowerCase()) {
                            case 'captain':
                              targetRoute = AppRoutes.captainDashboard;
                              break;
                            case 'referee':
                              targetRoute = AppRoutes.refereeDashboard;
                              break;
                            case 'stat-keeper':
                            case 'statkeeper':
                              targetRoute = AppRoutes.statKeeperDashboard;
                              break;
                            case 'player':
                              targetRoute = AppRoutes.playerDashboard;
                              break;
                            case 'freeagent':
                            case 'free-agent':
                              targetRoute = AppRoutes.freeAgentDashboard;
                              break;
                            default:
                              targetRoute = AppRoutes.home;
                          }

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
              );
            },
          ),
        ),
      ),
    );
  }
}
