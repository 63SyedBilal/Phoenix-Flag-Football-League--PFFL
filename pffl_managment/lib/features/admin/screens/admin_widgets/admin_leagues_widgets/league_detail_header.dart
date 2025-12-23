import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LeagueDetailHeader extends StatelessWidget {
  final String leagueName;
  final String subtitle;
  final VoidCallback onBackPressed;
  final String? logoUrl;

  const LeagueDetailHeader({
    super.key,
    required this.leagueName,
    required this.subtitle,
    required this.onBackPressed,
    this.logoUrl,
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
                child: ClipOval(
                  child: (logoUrl != null && logoUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: logoUrl!,
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFE5E7EB),
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => CustomPaint(
                            size: const Size(45, 45),
                            painter: DottedBorderPainter(),
                            child: const Center(
                              child: Icon(
                                Icons.sports,
                                size: 24,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )
                      : CustomPaint(
                          size: const Size(45, 45),
                          painter: DottedBorderPainter(),
                          child: const Center(
                            child: Icon(
                              Icons.sports,
                              size: 24,
                              color: Colors.black54,
                            ),
                          ),
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
