import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/providers/create_team_provider.dart';

class TeamLogoSection extends StatelessWidget {
  const TeamLogoSection({super.key});

  Future<void> _pickImage(
    BuildContext context,
    CreateTeamProvider provider,
  ) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      final String? path = result?.files.single.path;
      if (path == null) return;

      final file = File(path);
      if (!await file.exists()) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Selected image could not be found')),
        );
        return;
      }

      provider.setTeamLogo(path);
    } catch (_) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, provider, _) {
        final theme = Theme.of(context);
        return Center(
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
                  width: 125,
                  height: 125,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Center(
                      child: provider.teamLogoPath != null
                          ? Image.file(
                              File(provider.teamLogoPath!),
                              fit: BoxFit.cover,
                              width: 125,
                              height: 125,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderIcon(theme);
                              },
                            )
                          : _buildPlaceholderIcon(theme),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -10,
                left: 40,
                child: GestureDetector(
                  onTap: () => _pickImage(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.darkScaffoldBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.88),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.upload, size: 10, color: Colors.white),
                        SizedBox(width: 2),
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
        );
      },
    );
  }

  Widget _buildPlaceholderIcon(ThemeData theme) {
    return Icon(
      Icons.image,
      size: 60,
      color: theme.brightness == Brightness.dark 
          ? Colors.grey[700] 
          : Colors.grey[300],
    );
  }
}