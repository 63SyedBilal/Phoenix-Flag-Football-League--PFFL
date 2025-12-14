import 'package:flutter/material.dart';

class LeagueDetailHeader extends StatelessWidget {
  final String leagueName;
  final String subtitle;
  final VoidCallback onBackPressed;

  const LeagueDetailHeader({
    super.key,
    required this.leagueName,
    required this.subtitle,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CustomPaint(
                  size: const Size(40, 40),
                  painter: DottedBorderPainter(),
                  child: Center(
                    child: Image.asset('assets/images/image 5.png',fit: BoxFit.cover,),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leagueName,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Color(0xFFD1D5DB),fontSize: 16,fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final double dashWidth = 2;
    final double dashSpace = 2;
    final double radius = size.width / 2;

    double circumference = 2 * 3.141592653589793 * radius;
    int dashCount = (circumference / (dashWidth + dashSpace)).floor();

    double angleIncrement = (2 * 3.141592653589793) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      double startAngle = i * angleIncrement;
      double endAngle =
          startAngle + (dashWidth / circumference) * 2 * 3.141592653589793;

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}