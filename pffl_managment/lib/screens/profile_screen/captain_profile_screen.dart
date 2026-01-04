import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/screens/profile_screen/provider/captain_profile_provider.dart';

class CaptainProfileScreen extends StatelessWidget {
  const CaptainProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = Provider.of<UserPreferenceProvider>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => CaptainProfileProvider(prefs)..initialize(),
      child: _CaptainProfileContent(theme: theme),
    );
  }
}

class _CaptainProfileContent extends StatelessWidget {
  final ThemeData theme;

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

  const _CaptainProfileContent({required this.theme});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaptainProfileProvider>(context);

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
                style: theme.textTheme.headlineLarge!.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Manage your personal details & update\nyour player information.',
                style: theme.textTheme.titleSmall!.copyWith(
                  fontFamily: "Lato",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          final path = result.files.first.path;
                          if (path != null) provider.selectImage(File(path));
                        }
                      },
                      child: DottedBorder(
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
                          child: ClipOval(child: _buildAvatar(provider)),
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
                                fontWeight: FontWeight.w700,
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
                child: Text('Profile Pic', style: theme.textTheme.labelLarge),
              ),
              const SizedBox(height: 12),
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
                          controller: provider.firstNameController,
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
                          controller: provider.lastNameController,
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
                controller: provider.emailController,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phone Number", style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  ImprovedPhoneField(
                    onInputChanged: (PhoneNumber number) =>
                        provider.phoneController.text = number.completeNumber,
                    onInputValidated: (bool isValid) =>
                        provider.setPhoneValid(isValid),
                    initialCountryCode: 'US',
                    hintText: 'Enter your phone number',
                    errorText: provider.phoneError,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Jersey Number", style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              CustomTextField(
                hintText: 'Jersey Number',
                controller: provider.jerseyNumberController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Text("Position", style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              SimpleDropdownList(
                selectedValue: provider.positionController.text.isEmpty
                    ? null
                    : provider.positionController.text,
                items: _positions,
                hintText: 'Select Position',
                onSelected: (String position) =>
                    provider.positionController.text = position,
              ),
              const SizedBox(height: 12),
              Text("Emergency Contact Name", style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              CustomTextField(
                hintText: 'Emergency Contact Name',
                controller: provider.emergencyContactNameController,
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
                    onInputChanged: (PhoneNumber number) =>
                        provider.emergencyPhoneController.text =
                            number.completeNumber,
                    initialCountryCode: 'US',
                    hintText: 'Enter emergency phone number',
                  ),
                ],
              ),
              const SizedBox(height: 30),
              CustomButton(
                width: double.infinity,
                textColor: AppColors.lightAppBarBackground,
                text: provider.isLoading ? 'Saving...' : 'Save',
                isLoading: provider.isLoading,
                onPressed: () async {
                  final success = await provider.saveProfile();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      provider.dashboardRoute,
                      (route) => false,
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.errorMessage ?? 'Failed to update profile',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(CaptainProfileProvider provider) {
    if (provider.selectedImageFile != null) {
      return Image.file(
        provider.selectedImageFile!,
        fit: BoxFit.cover,
        width: 125,
        height: 125,
      );
    } else if (provider.imageUrl != null && provider.imageUrl!.isNotEmpty) {
      if (provider.imageUrl!.startsWith('http')) {
        return Image.network(
          provider.imageUrl!,
          fit: BoxFit.cover,
          width: 125,
          height: 125,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60),
        );
      } else {
        return Image.file(
          File(provider.imageUrl!),
          fit: BoxFit.cover,
          width: 125,
          height: 125,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60),
        );
      }
    }
    return Icon(Icons.person_outline, size: 60, color: Colors.grey[300]);
  }
}
