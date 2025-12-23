import 'package:flutter/material.dart';
import 'dart:math' as math;

enum DottedBorderShape { circle, rectangle }

class DottedBorderWidget extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final BorderRadius borderRadius;
  final double? width;
  final double? height;
  final DottedBorderShape shape;

  const DottedBorderWidget({
    super.key,
    required this.child,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.color = Colors.black,
    this.borderRadius = BorderRadius.zero,
    this.width,
    this.height,
    this.shape = DottedBorderShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width ?? double.infinity, height ?? double.infinity),
      painter: _DottedBorderPainter(
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        color: color,
        borderRadius: borderRadius,
        shape: shape,
      ),
      child: child,
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final BorderRadius borderRadius;
  final DottedBorderShape shape;

  _DottedBorderPainter({
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
    required this.borderRadius,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    if (shape == DottedBorderShape.circle) {
      _paintCircle(canvas, size, paint);
    } else {
      _paintRectangle(canvas, size, paint);
    }
  }

  void _paintCircle(Canvas canvas, Size size, Paint paint) {
    final double radius = math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final int dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final double angleIncrement = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      double startAngle = i * angleIncrement;
      double sweepAngle = (dashWidth / circumference) * 2 * math.pi;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _paintRectangle(Canvas canvas, Size size, Paint paint) {
    final Path path = Path();

    // Top border
    _addDashedLine(
      path,
      Offset(0, 0),
      Offset(size.width, 0),
      dashWidth,
      dashSpace,
    );

    // Right border
    _addDashedLine(
      path,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      dashWidth,
      dashSpace,
    );

    // Bottom border
    _addDashedLine(
      path,
      Offset(size.width, size.height),
      Offset(0, size.height),
      dashWidth,
      dashSpace,
    );

    // Left border
    _addDashedLine(
      path,
      Offset(0, size.height),
      Offset(0, 0),
      dashWidth,
      dashSpace,
    );

    canvas.drawPath(path, paint);
  }

  void _addDashedLine(
    Path path,
    Offset start,
    Offset end,
    double dashWidth,
    double dashSpace,
  ) {
    final double totalLength = (end - start).distance;
    final int dashCount = (totalLength / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final double startFraction = i * (dashWidth + dashSpace) / totalLength;
      final double endFraction =
          (i * (dashWidth + dashSpace) + dashWidth) / totalLength;

      final Offset dashStart = Offset.lerp(start, end, startFraction)!;
      final Offset dashEnd = Offset.lerp(start, end, endFraction)!;

      path.moveTo(dashStart.dx, dashStart.dy);
      path.lineTo(dashEnd.dx, dashEnd.dy);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
