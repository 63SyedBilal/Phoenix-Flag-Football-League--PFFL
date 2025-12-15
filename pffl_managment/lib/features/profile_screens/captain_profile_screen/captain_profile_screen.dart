import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_phone_field.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class CaptainProfileScreen extends StatelessWidget {
  const CaptainProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(leading: ArrowBackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your personal details & update\nyour player information.',
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
                      left: 29,
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
              const SizedBox(height: 30),
                         Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("First Name", style: theme.textTheme.labelLarge),
                        const SizedBox(height: 4),
                        CustomTextField(
                          hintText: 'First Name',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Last Name", style: theme.textTheme.labelLarge),
                        const SizedBox(height: 4),
                        CustomTextField(
                          hintText: 'Last Name',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text("Email Address", style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              CustomTextField(
                hintText: 'Email Address',
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phone Number", style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  CustomPhoneField(
                    hintText: 'Enter your phone number',
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              CustomButton(
                textColor: AppColors.lightAppBarBackground,
                text: 'Save',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.adminDashboard);
                },
              ),
           
            ],
          ),
        ),
      ),
    );
  }
}