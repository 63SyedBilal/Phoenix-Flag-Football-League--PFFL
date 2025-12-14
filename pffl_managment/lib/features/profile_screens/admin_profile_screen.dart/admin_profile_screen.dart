import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_phone_field.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/features/profile_screens/admin_profile_screen.dart/providers/admin_profile_provider.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ChangeNotifierProvider(
      create: (_) => AdminProfileProvider()..initialize(),
      child: _AdminProfileScreenContent(theme: theme),
    );
  }
}

class _AdminProfileScreenContent extends StatefulWidget {
  final ThemeData theme;
  
  const _AdminProfileScreenContent({required this.theme});

  @override
  State<_AdminProfileScreenContent> createState() => _AdminProfileScreenContentState();
}

class _AdminProfileScreenContentState extends State<_AdminProfileScreenContent> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeControllers(AdminProfileProvider provider) {
    if (!_controllersInitialized) {
      _firstNameController = TextEditingController(text: provider.firstName);
      _lastNameController = TextEditingController(text: provider.lastName);
      _emailController = TextEditingController(text: provider.email);
      _controllersInitialized = true;
    } else {
      // Update controller values if provider values changed
      if (_firstNameController.text != provider.firstName) {
        _firstNameController.text = provider.firstName;
      }
      if (_lastNameController.text != provider.lastName) {
        _lastNameController.text = provider.lastName;
      }
      if (_emailController.text != provider.email) {
        _emailController.text = provider.email;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProfileProvider>(
      builder: (context, provider, _) {
        _initializeControllers(provider);

        return Scaffold(
          backgroundColor: AppColors.lightAppBarBackground,
          appBar: AppBar(leading: ArrowBackButton()),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Profile',
                    style: widget.theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your personal details & update\nyour player information.',
                    style: widget.theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              withData: false,
                            );
                            
                            if (result != null && result.files.isNotEmpty) {
                              final file = result.files.first;
                              if (file.path != null) {
                                provider.selectImage(File(file.path!));
                              }
                            }
                          },
                          child: DottedBorder(
                            options: CircularDottedBorderOptions(
                              dashPattern: [5, 5],
                              strokeWidth: 1,
                              color: widget.theme.brightness == Brightness.dark
                                  ? Colors.white70
                                  : const Color.fromRGBO(0, 0, 0, 0.4),
                            ),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: ClipOval(
                                child: _buildAvatar(provider),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -9,
                          left: 29,
                          child: GestureDetector(
                            onTap: () async {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                withData: false,
                              );
                              
                              if (result != null && result.files.isNotEmpty) {
                                final file = result.files.first;
                                if (file.path != null) {
                                  provider.selectImage(File(file.path!));
                                }
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
                        ),
                      ],
                    ),
                  ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Profile Pic',
                  textAlign: TextAlign.center,
                  style: widget.theme.textTheme.labelLarge,
                ),
              ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("First Name", style: widget.theme.textTheme.labelLarge),
                            const SizedBox(height: 4),
                            CustomTextField(
                              hintText: 'First Name',
                              controller: _firstNameController,
                              onChanged: (value) {
                                provider.updateFirstName(value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Last Name", style: widget.theme.textTheme.labelLarge),
                            const SizedBox(height: 4),
                            CustomTextField(
                              hintText: 'Last Name',
                              controller: _lastNameController,
                              onChanged: (value) {
                                provider.updateLastName(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text("Email Address", style: widget.theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  CustomTextField(
                    hintText: 'Email Address',
                    controller: _emailController,
                    onChanged: (value) {
                      provider.updateEmail(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phone Number", style: widget.theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      CustomPhoneField(
                        hintText: 'Enter your phone number',
                        initialValue: provider.phone.isNotEmpty
                            ? _parsePhoneNumber(provider.phone)
                            : null,
                        onInputChanged: (PhoneNumber number) {
                          // Store the full phone number with country code
                          final fullNumber = number.phoneNumber ?? '';
                          provider.updatePhone(fullNumber);
                        },
                        onInputValidated: (bool isValid) {
                          // Optional: You can add validation feedback here
                          if (!isValid && provider.phone.isNotEmpty) {
                            // Phone number is invalid
                          }
                        },
                      ),
                    ],
                  ),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 30),
                  
                  CustomButton(
                    width: double.infinity,
                    textColor: AppColors.lightAppBarBackground,
                    text: provider.isLoading ? 'Saving...' : 'Save',
                    isLoading: provider.isLoading,
                    onPressed: () {
                      provider.saveProfile().then((success) {
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushNamed(context, AppRoutes.adminDashboard);
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
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(AdminProfileProvider provider) {
    if (provider.selectedImageFile != null) {
      return Image.file(
        provider.selectedImageFile!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    } else if (provider.imageUrl != null && provider.imageUrl!.isNotEmpty) {
      if (provider.imageUrl!.startsWith('http')) {
        return Image.network(
          provider.imageUrl!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 60);
          },
        );
      } else {
        return Image.file(
          File(provider.imageUrl!),
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 60);
          },
        );
      }
    }
    return const Icon(Icons.person, size: 60);
  }

  /// Parse phone number string to PhoneNumber object
  /// Handles various formats: +1234567890, 1234567890, etc.
  PhoneNumber? _parsePhoneNumber(String phoneString) {
    if (phoneString.isEmpty) return null;
    
    try {
      // Remove any spaces, dashes, or parentheses
      final cleaned = phoneString.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      
      // If it starts with +, it includes country code
      if (cleaned.startsWith('+')) {
        // Try to detect country from the number
        if (cleaned.length >= 11 && cleaned.startsWith('+1')) {
          // US number
          return PhoneNumber(
            phoneNumber: cleaned.substring(2), // Remove +1
            isoCode: 'US',
            dialCode: '+1',
          );
        } else {
          // For other countries, try to extract country code
          // Default: try to parse with first 1-3 digits as country code
          // For simplicity, default to US if we can't determine
          return PhoneNumber(
            phoneNumber: cleaned.substring(1), // Remove +
            isoCode: 'US',
            dialCode: '+1',
          );
        }
      } else {
        // Assume US number if no country code
        return PhoneNumber(
          phoneNumber: cleaned,
          isoCode: 'US',
          dialCode: '+1',
        );
      }
    } catch (e) {
      // If parsing fails, return null to let the field handle it
      return null;
    }
  }
}