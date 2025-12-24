import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

/// Profile image upload section widget - iOS style design
class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                foregroundPainter: DottedCircleBorderPainter(
                  color: const Color(0xFFD1D5DB),
                  strokeWidth: 1,
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                  ),
                  child: provider.profileImagePath != null
                      ? ClipOval(
                          child: Image.file(
                            File(provider.profileImagePath!),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFFD1D5DB),
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
        provider.setProfileImage(result.files.single.path!);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }
}

/// Dotted circle border painter
class DottedCircleBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DottedCircleBorderPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    const double dashLength = 3;
    const double gapLength = 3;

    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();

    final anglePerDash = 2 * math.pi / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * anglePerDash;
      final sweepAngle = anglePerDash * (dashLength / (dashLength + gapLength));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
