import 'dart:io';
import 'dart:math' as math; // 👈 dotted border ke liye

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

/// Profile image upload section widget - iOS style design
class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, _) {
        return Container(
          width: 120,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(context, provider),
                child: Stack(
                  children: [
 mustafa
                    // 🔴 Yahin dotted border hai, design same rakha
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
                          // Border.all hata diya, kyunki ab custom dotted use ho raha
                          color: Colors.grey[100],
                        ),


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

                    // 🔴 Yahin dotted border hai, design same rakha
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
                          // Border.all hata diya, kyunki ab custom dotted use ho raha
                          color: Colors.grey[100],
                        ),
 bilalphoenix
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
 mustafa


 bilalphoenix
                      ),
                    ),

                    // upload button bilkul same
                    Positioned(
 mustafa


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

 bilalphoenix
                      bottom: 0,
                      right: 25,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.file_upload_outlined,
                              size: 8,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Upload',
                              style: TextStyle(
                                fontSize: 7.93,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
 mustafa


bilalphoenix
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Profile Pic',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Submit this image if you think it’s readable or tap on re-upload button to upload another one',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
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

 mustafa


 bilalphoenix
/// Sirf circle ke around dotted border draw karne ke liye
class DottedCircleBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DottedCircleBorderPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // thoda rounded dots
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // dash settings
    const double dashLength = 3; // dot ki length
    const double gapLength = 3;  // dot ke beech ka gap

    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();

    final fullAngle = 2 * math.pi;
    final anglePerDash = fullAngle / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * anglePerDash;
      final sweepAngle =
          anglePerDash * (dashLength / (dashLength + gapLength));

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
 mustafa
}

}

 bilalphoenix
