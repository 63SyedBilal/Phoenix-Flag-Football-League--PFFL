import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';

/// League selection card widget for Free Agent active leagues screen
/// Matches the design from the provided image
class FreeAgentLeagueSelectionCard extends StatelessWidget {
  final LeagueCreationModel league;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSelectionToggle;
  final VoidCallback? onShowMore;

  const FreeAgentLeagueSelectionCard({
    super.key,
    required this.league,
    required this.isSelected,
    required this.onTap,
    required this.onSelectionToggle,
    this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            // Header row with icon, name, Active tag, and checkbox
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // League icon and name
                  Row(
                    children: [
                      _buildLeagueIcon(),
                      const SizedBox(width: 4),
                      Text(
                        league.leagueName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  // Active tag and checkbox
                  Row(
                    children: [
                      // Active status tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F173E),
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: const Center(
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Selection checkbox
                      GestureDetector(
                        onTap: onSelectionToggle,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0F173E)
                                  : const Color(
                                      0xFF000000,
                                    ).withValues(alpha: 0.5),
                              width: 2,
                            ),
                            color: isSelected
                                ? const Color(0xFF0F173E)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Format and League Fee row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Format:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        league.format,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 100),
                  const Text(
                    '|',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Text(
                        'League Fee:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${league.registrationFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Start Date and End Date row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Start Date:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${league.startDate.day} ${_getMonthName(league.startDate.month)} ${league.startDate.year}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 29),
                  const Text(
                    '|',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Text(
                        'End Date:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${league.endDate.day} ${_getMonthName(league.endDate.month)} ${league.endDate.year}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                height: 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF000000).withValues(alpha: 0.12),
                ),
              ),
            ),
            // Show more link
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: onShowMore ?? onTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Show more',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.brown,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build league icon - circular with logo or default icon with dotted border
  Widget _buildLeagueIcon() {
    final hasLogo = league.teamLogo != null && league.teamLogo!.isNotEmpty;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      child: hasLogo
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: league.teamLogo!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildDefaultIcon(),
                errorWidget: (context, url, error) => _buildDefaultIcon(),
              ),
            )
          : _buildDefaultIcon(),
    );
  }

  /// Build default icon with dotted border
  Widget _buildDefaultIcon() {
    return CustomPaint(
      size: const Size(30, 30),
      painter: DottedBorderPainter(),
      child: const Center(
        child: Icon(Icons.sports, size: 18, color: Colors.black),
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

/// Dotted border painter for league icon
class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 2;
    const double dashSpace = 2;
    final double radius = size.width / 2;

    final double circumference = 2 * 3.141592653589793 * radius;
    final int dashCount = (circumference / (dashWidth + dashSpace)).floor();

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
