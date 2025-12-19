import 'package:flutter/material.dart';
import 'package:pffl_managment/core/models/user_model.dart';
import 'package:pffl_managment/core/widgets/user_avatar_widget.dart';
import 'package:pffl_managment/features/admin/provider/admin_user_provider/users_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:provider/provider.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Team info
                  Row(
                    children: [
                      // Team logo with dotted border
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFF000000,
                            ).withValues(alpha: 0.12),
                            width: 0.5,
                          ),
                        ),
                        child: CustomPaint(
                          size: const Size(48, 48),
                          painter: DottedBorderPainter(),
                          child: const Center(
                            child: Text(
                              'STA',
                              style: TextStyle(
                                fontFamily: 'Serotiva',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Team name and player count
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'STA',
                            style: TextStyle(
                              fontFamily: 'Serotiva',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '5/8',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(
                                0xFF111827,
                              ).withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Invite button
                  ElevatedButton.icon(
                    onPressed: () {
                      print('Invite button pressed');
                      print('Current route: ${ModalRoute.of(context)?.settings.name}');
                      
                      // Navigate to invite screen using named route constant
                      try {
                        final result = Navigator.pushNamed(context, AppRoutes.adminInvite);
                        print('Navigation attempted, result: $result');
                      } catch (e, stackTrace) {
                        // Print error for debugging
                        print('Error navigating to invite screen: $e');
                        print('Stack trace: $stackTrace');
                        // Show a snackbar to inform the user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Unable to open invite screen: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Invite',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Game format tags
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                children: [
                  // 7v7 tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF000000).withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      '7v7',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 5v5 tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF000000).withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      '5v5',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Team members list
            Expanded(
              child: Consumer<UsersProvider>(
                builder: (context, viewModel, child) {
                  // Filter to show only players and captains (team members)
                  final teamMembers = viewModel.allUsers
                      .where(
                        (user) =>
                            user.role == UserRole.player ||
                            user.role == UserRole.captain,
                      )
                      .toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: teamMembers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildTeamMemberCard(teamMembers[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF000000).withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // User avatar
          UserAvatarWidget(
            imageUrl: user.imageUrl,
            size: 48,
            borderWidth: 2,
            borderColor: const Color(0xFFF3F4F6),
          ),
          const SizedBox(width: 12),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and email
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 4),

                // Position and roles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Position
                    const Row(
                      children: [
                        Text(
                          'Position:',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Rusher +5 more',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),

                    // Tags
                    Row(
                      children: [
                        // Role tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user.role.colors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: user.role.colors.border,
                              width: 0.67,
                            ),
                          ),
                          child: Text(
                            user.role.displayName,
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: user.role.colors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Payment status tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F173E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Paid',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for dotted border
class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.12)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final double dashWidth = 3;
    final double dashSpace = 3;
    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final path = Path();
    final dashCount = (2 * 3.14159 * radius) / (dashWidth + dashSpace);

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = (i * (dashWidth + dashSpace)) / radius;
      final double endAngle = startAngle + (dashWidth / radius);

      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
