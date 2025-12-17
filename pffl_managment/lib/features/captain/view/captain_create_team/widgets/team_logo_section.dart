import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/providers/create_team_provider.dart';

/// Team logo upload section widget
class TeamLogoSection extends StatelessWidget {
  const TeamLogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, provider, _) {
        return Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(context, provider),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        image: provider.teamLogoPath != null
                            ? DecorationImage(
                                image: FileImage(File(provider.teamLogoPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: provider.teamLogoPath == null
                            ? Colors.grey[100]
                            : null,
                      ),
                      child: provider.teamLogoPath == null
                          ? const Icon(
                              Icons.image,
                              size: 60,
                              color: Color(0xFFD1D5DB),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: -9,
                      left: 30,
                      child: GestureDetector(
                        onTap: () => _pickImage(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Upload',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
              const SizedBox(height: 12),
              const Text(
                'Team Logo (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Please upload your team\'s logo in this section to ensure that\nwe can represent your brand accurately.',
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
    CreateTeamProvider provider,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        provider.setTeamLogo(result.files.single.path);
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

