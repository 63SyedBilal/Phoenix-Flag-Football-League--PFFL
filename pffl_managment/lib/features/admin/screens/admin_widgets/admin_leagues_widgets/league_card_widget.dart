import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';

class LeagueCardWidget extends StatelessWidget {
  final LeagueCreationModel league;
  final VoidCallback onTap;

  const LeagueCardWidget({
    super.key,
    required this.league,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF000000).withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ClipOval(
                            child: league.teamLogo.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: league.teamLogo,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: const Color(0xFFE5E7EB),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        CustomPaint(
                                          size: const Size(30, 30),
                                          painter: DottedBorderPainter(),
                                          child: const Center(
                                            child: Icon(
                                              Icons.sports,
                                              size: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                  )
                                : CustomPaint(
                                    size: const Size(30, 30),
                                    painter: DottedBorderPainter(),
                                    child: const Center(
                                      child: Icon(
                                        Icons.sports,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            league.leagueName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F173E),
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Text(
                      league.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Lato',
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Format | League Fee
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Format:',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            league.format,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 10,
                    color: const Color(0xFF111827),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'League Fee:',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '\$${league.registrationFee.toStringAsFixed(0)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Start Date | End Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date:',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${league.startDate.day} ${_getMonthName(league.startDate.month)} ${league.startDate.year}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 10,
                    color: const Color(0xFF111827),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'End Date:',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${league.endDate.day} ${_getMonthName(league.endDate.month)} ${league.endDate.year}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                height: 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF000000).withOpacity(0.12),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Show more',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lato',
                      color: Color(0xFF000000),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF111827),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 2;
    const double dashSpace = 2;
    final double radius = size.width / 2;

    final double circumference = 2 * 3.141592653589793 * radius;
    final int dashCount = (circumference / (dashWidth + dashSpace))
        .floor()
        .clamp(1, 1000000);

    final double angleIncrement = (2 * 3.141592653589793) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = i * angleIncrement;
      final double endAngle =
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
