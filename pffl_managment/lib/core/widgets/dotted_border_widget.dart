import 'package:flutter/material.dart';

class DottedBorderWidget extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final BorderRadius borderRadius;
  final double? width;
  final double? height;

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

  _DottedBorderPainter({
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

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
      final double endFraction = (i * (dashWidth + dashSpace) + dashWidth) / totalLength;

      final Offset dashStart = Offset.lerp(start, end, startFraction)!;
      final Offset dashEnd = Offset.lerp(start, end, endFraction)!;

      path.moveTo(dashStart.dx, dashStart.dy);
      path.lineTo(dashEnd.dx, dashEnd.dy);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}