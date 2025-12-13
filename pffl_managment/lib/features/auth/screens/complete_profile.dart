import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_phone_field.dart';
import 'package:pffl_managment/core/widgets/custombottomsheet/custom_bottom_sheet.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';
import 'package:pffl_managment/core/widgets/text_with_text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class CompleteProfile extends StatelessWidget {
  const CompleteProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(leading: ArrowBackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                        dashPattern: [5, 5],
                        strokeWidth: 1,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : const Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
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
                            Icon(Icons.upload, size: 12, color: Colors.white),
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

              // Input Fields using TextWithTextField
              Text('Position', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              SimpleDropdownList(items: [], onSelected: (_) {}),
              const SizedBox(height: 18),

              Text('Jersy Number', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              TextWithTextField(hintText: 'e.g. Center Forward'),
              const SizedBox(height: 18),

              Text('Emergency Contact Name', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              TextWithTextField(hintText: 'e.g. Tyler'),
              const SizedBox(height: 18),

              Text('Emergency Phone Number', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              CustomPhoneField(
                onInputChanged: (PhoneNumber number) {
                  // Handle phone number input
                },
                onInputValidated: (bool value) {
                  // Handle phone number validation
                },
                initialValue: PhoneNumber(isoCode: 'US'),
                hintText: 'e.g +1 123 456 7890',
              ),
              const SizedBox(height: 20),

              // Terms & Conditions
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF9CA3AF)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'I agree to Terms & Privacy',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Complete Button
              CustomButton(
                textColor: AppColors.lightAppBarBackground,
                text: 'Complete',
                  onPressed: () {
                final parentContext = context;
                showCustomBottomSheet(
                  context: context,
                  title: 'Profile Created',
                  subtitle: "Welcome to PFFL.!\nLet's see some games.",
                  buttonText: 'Continue',
                  onButtonPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      parentContext,
                      AppRoutes.adminDashboard,
                    );
                  },
                  content: Container(),
                );
              },
                // onPressed: () {
                //   Navigator.pushNamed(context, AppRoutes.adminDashboard);
                // },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
