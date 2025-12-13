import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';

class UserStatusBarWidget extends StatelessWidget {
  const UserStatusBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('9:41', style: AppTextStyles.bodyLarge),
          Row(
            children: [
              SizedBox(
                width: 18,
                height: 12,
                child: CustomPaint(painter: UserSignalPainter()),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.wifi, size: 17, color: Colors.black),
              const SizedBox(width: 8),
              SizedBox(
                width: 25,
                height: 13,
                child: CustomPaint(painter: UserBatteryPainter()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserSignalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.33;

    // Draw signal bars
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height),
      Offset(size.width * 0.25, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height),
      Offset(size.width * 0.5, size.height * 0.75),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height),
      Offset(size.width * 0.75, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UserBatteryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.33;

    // Battery outline
    final rect = Rect.fromLTWH(0, 0, size.width * 0.8, size.height);
    canvas.drawRect(rect, paint);

    // Battery cap
    final capRect = Rect.fromLTWH(
      size.width * 0.8,
      size.height * 0.25,
      size.width * 0.2,
      size.height * 0.5,
    );
    canvas.drawRect(capRect, paint);

    // Battery fill
    paint.style = PaintingStyle.fill;
    final fillRect = Rect.fromLTWH(
      1.33,
      1.33,
      (size.width * 0.8 - 2.66) * 0.7,
      size.height - 2.66,
    );
    canvas.drawRect(fillRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
