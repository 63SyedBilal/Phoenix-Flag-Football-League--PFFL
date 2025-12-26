import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class CaptainProfileScreen extends StatefulWidget {
  const CaptainProfileScreen({super.key});

  @override
  State<CaptainProfileScreen> createState() => _CaptainProfileScreenState();
}

class _CaptainProfileScreenState extends State<CaptainProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jerseyNumberController = TextEditingController();
  final TextEditingController _emergencyContactNameController =
      TextEditingController();

  String? _selectedPosition;
  String _phoneNumber = '';
  String _emergencyPhoneNumber = '';

  // Available positions for football
  static const List<String> _positions = [
    'Center',
    'Blocker',
    'Receiver',
    'Slot',
    'QB',
    'Star QB',
    'Rusher',
    'LB',
    'Corner',
    'Safety',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _jerseyNumberController.dispose();
    _emergencyContactNameController.dispose();
    super.dispose();
  }

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
              Text('My Profile', style: theme.textTheme.headlineLarge),

              Text(
                'Manage your personal details & update\nyour player information.',
                style: theme.textTheme.titleSmall!.copyWith(
                  fontFamily: "Lato",
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
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
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: Center(
                            child: Icon(
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

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Profile Pic',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "First Name",
                          style: theme.textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: "Lato",
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomTextField(
                          hintText: 'First Name',
                          controller: _firstNameController,
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
                          controller: _lastNameController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Email Address", style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              CustomTextField(
                hintText: 'Email Address',
                controller: _emailController,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phone Number", style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  ImprovedPhoneField(
                    onInputChanged: (PhoneNumber number) {
                      _phoneNumber = number.completeNumber;
                    },
                    onInputValidated: (bool value) {
                      // Handle phone number validation
                    },
                    initialCountryCode: 'US',
                    hintText: 'Enter your phone number',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Jersey Number", style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              CustomTextField(
                hintText: 'Jersey Number',
                controller: _jerseyNumberController,
                keyboardType: TextInputType.number,
              ),

              Text("Position", style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              SimpleDropdownList(
                selectedValue: _selectedPosition,
                items: _positions,
                hintText: 'Select Position',
                onSelected: (String position) {
                  setState(() {
                    _selectedPosition = position;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text("Emergency Contact Name", style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              CustomTextField(
                hintText: 'Emergency Contact Name',
                controller: _emergencyContactNameController,
              ),
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency Phone Number",
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  ImprovedPhoneField(
                    onInputChanged: (PhoneNumber number) {
                      _emergencyPhoneNumber = number.completeNumber;
                    },
                    onInputValidated: (bool value) {
                      // Handle emergency phone number validation
                    },
                    initialCountryCode: 'US',
                    hintText: 'Enter emergency phone number',
                  ),
                ],
              ),
              const SizedBox(height: 30),

              CustomButton(
                width: double.infinity,
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
