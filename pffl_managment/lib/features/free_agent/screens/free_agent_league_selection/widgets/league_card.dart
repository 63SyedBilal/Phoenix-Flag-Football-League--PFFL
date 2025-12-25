import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/league_service.dart';

class LeagueCard extends StatelessWidget {
  final LeagueModel league;
  final bool isSelected;
  final VoidCallback onSelect;

  const LeagueCard({
    super.key,
    required this.league,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CustomPaint(
                    painter: DottedBorderPainter(
                      color: isSelected
                          ? const Color(0xFF0F173E)
                          : const Color(0xFF000000).withValues(alpha: 0.2),
                    ),
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: league.logo != null && league.logo!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: league.logo!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFE5E7EB),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildInitial(league.leagueName),
                              )
                            : _buildInitial(league.leagueName),
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
                        fontFamily: "Lato",
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F173E),
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Text(
                      league.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onSelect(),
                      shape: const CircleBorder(),
                      side: BorderSide(
                        color: const Color(0xFF000000).withValues(alpha: 0.2),
                      ),
                      activeColor: const Color(0xFF0F173E),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
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
                            fontFamily: "Lato",
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
                              fontFamily: "Lato",
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
                              fontFamily: "Lato",
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '\$${league.perPlayerLeagueFee.toStringAsFixed(0)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Lato",
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
                            fontFamily: "Lato",
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
                              fontFamily: "Lato",
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
                              fontWeight: FontWeight.w500,
                              fontFamily: "Lato",
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
                                fontWeight: FontWeight.w500,
                                fontFamily: "Lato",
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
                  color: const Color(0xFF000000).withValues(alpha: 0.12),
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
                      fontFamily: "Lato",
                      color: Color(0xFF000000),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.brown),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitial(String name) {
    return Center(
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
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
  final Color color;
  DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
      final double sweepAngle =
          (dashWidth / circumference) * 2 * 3.141592653589793;

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DottedBorderPainter oldDelegate) =>
      color != oldDelegate.color;
}
