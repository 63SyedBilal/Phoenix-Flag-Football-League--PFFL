import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/user_service.dart' as user_service;
import 'package:pffl_managment/core/widgets/user_avatar_widget.dart';
import 'package:pffl_managment/features/admin/provider/admin_user_provider/users_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:provider/provider.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
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
                      print(
                        'Current route: ${ModalRoute.of(context)?.settings.name}',
                      );

                      // Navigate to invite screen using named route constant
                      try {
                        Navigator.pushNamed(context, AppRoutes.adminInvite);
                      } catch (e) {
                        // Print error for debugging
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
                  final teamMembers = viewModel.backendUsers
                      .where(
                        (user) =>
                            user.role == 'player' || user.role == 'captain',
                      )
                      .toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: teamMembers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildTeamMemberCard(context, teamMembers[index]);
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

  Widget _buildTeamMemberCard(
    BuildContext context,
    user_service.UserModel user,
  ) {
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
          // User avatar with jersey number overlay
          Stack(
            children: [
              UserAvatarWidget(
                imageUrl: user.profileImage,
                size: 48,
                borderWidth: 2,
                borderColor: const Color(0xFFF3F4F6),
              ),
              // Jersey number overlay
              if (user.jerseyNumber != null)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      user.jerseyNumber.toString(),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and email
                Text(
                  user.displayName,
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
                    Expanded(child: _buildPositionDisplay(context, user)),

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
                            color: _getRoleColors(user.role).background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getRoleColors(user.role).border,
                              width: 0.67,
                            ),
                          ),
                          child: Text(
                            _getRoleDisplayName(user.role),
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getRoleColors(user.role).text,
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

  Widget _buildPositionDisplay(
    BuildContext context,
    user_service.UserModel user,
  ) {
    // Get positions from user data
    final positions = _getUserPositions(user);

    if (positions.isEmpty) {
      return const Row(
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
            'Not set',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF999999),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Text(
          'Position:',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            onTap: positions.length > 1
                ? () => _showAllPositions(context, user, positions)
                : null,
            child: Text(
              positions.length == 1
                  ? positions.first
                  : '${positions.first} +${positions.length - 1} more',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
                decoration: positions.length > 1
                    ? TextDecoration.underline
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getUserPositions(user_service.UserModel user) {
    // Get positions from user model
    if (user.position == null || user.position!.isEmpty) return [];
    return user.position!
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  void _showAllPositions(
    BuildContext context,
    user_service.UserModel user,
    List<String> positions,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            '${user.displayName} - All Positions',
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...positions
                    .map(
                      (position) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              position,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        );
      },
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

// Helper methods for role colors and display names
class _RoleColors {
  final Color background;
  final Color border;
  final Color text;

  _RoleColors({
    required this.background,
    required this.border,
    required this.text,
  });
}

_RoleColors _getRoleColors(String role) {
  switch (role.toLowerCase()) {
    case 'player':
      return _RoleColors(
        background: const Color(0xFFDBEAFE), // blue-100
        border: const Color(0xFFBFDBFE), // blue-200
        text: const Color(0xFF1E3A8A), // blue-900
      );
    case 'captain':
      return _RoleColors(
        background: const Color(0xFFFEF3C7), // amber-100
        border: const Color(0xFFFDE68A), // amber-200
        text: const Color(0xFF78350F), // amber-900
      );
    case 'referee':
      return _RoleColors(
        background: const Color(0xFFEDE9FE), // violet-100
        border: const Color(0xFFDDD6FE), // violet-200
        text: const Color(0xFF4C1D95), // violet-900
      );
    case 'stat-keeper':
    case 'statkeeper':
      return _RoleColors(
        background: const Color(0xFFD1FAE5), // emerald-100
        border: const Color(0xFFA7F3D0), // emerald-200
        text: const Color(0xFF064E3B), // emerald-900
      );
    default:
      return _RoleColors(
        background: const Color(0xFFF3F4F6), // gray-100
        border: const Color(0xFFE5E7EB), // gray-200
        text: const Color(0xFF374151), // gray-700
      );
  }
}

String _getRoleDisplayName(String role) {
  switch (role.toLowerCase()) {
    case 'player':
      return 'Player';
    case 'captain':
      return 'Captain';
    case 'referee':
      return 'Referee';
    case 'stat-keeper':
    case 'statkeeper':
      return 'Stat Keeper';
    default:
      return role
          .split('-')
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : word,
          )
          .join(' ');
  }
}
