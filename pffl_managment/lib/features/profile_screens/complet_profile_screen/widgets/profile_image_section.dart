import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

/// Profile image upload section widget
class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, _) {
        return Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(context, provider),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DottedBorder(
                      options: CircularDottedBorderOptions(
                        dashPattern: const [5, 5],
                        strokeWidth: 1,
                        color: Theme.of(context).brightness == Brightness.dark
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
                      left: 30,
                      child: GestureDetector(
                        onTap: () => _pickImage(context, provider),
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
              const SizedBox(height: 8),
              const Text(
                'Profile Pic',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Submit this image if you think it\'s readable or tap on re-\nupload button to upload another one',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    CompleteProfileProvider provider,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        provider.setProfileImage(result.files.single.path);
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
