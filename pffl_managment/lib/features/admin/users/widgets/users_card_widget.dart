import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/models/user_model.dart';
import 'package:pffl_managment/features/admin/users/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserCardWidget extends StatelessWidget {
  final UserModel user;

  const UserCardWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.67, 16.67, 16.67, 0.67),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.12),
          width: 0.67,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              UserAvatarWidget(imageUrl: user.imageUrl),
              const SizedBox(width: 12),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: AppTextStyles.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        UserMenuButton(user: user),
                      ],
                    ),
                    // Email
                    Text(user.email, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                    // Role and team badges
                    Row(
                      children: [
                        UserRoleBadge(role: user.role),
                        if (user.team.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(child: UserTeamBadge(team: user.team)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Status
                    UserStatusIndicator(status: user.status),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserAvatarWidget extends StatelessWidget {
  final String imageUrl;

  const UserAvatarWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF3F4F6), width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.person, size: 24),
          ),
        ),
      ),
    );
  }
}

class UserMenuButton extends StatelessWidget {
  final UserModel user;

  const UserMenuButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<UsersProvider>().showUserMenu(user);
      },
      child: Container(
        width: 26,
        height: 26,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [UserDotWidget(), UserDotWidget(), UserDotWidget()],
        ),
      ),
    );
  }
}

class UserDotWidget extends StatelessWidget {
  const UserDotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: Color(0xFF99A1AF),
        shape: BoxShape.circle,
      ),
    );
  }
}

class UserRoleBadge extends StatelessWidget {
  final UserRole role;

  const UserRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final colors = role.colors;

    return Container(
      height: 27.33,
      padding: const EdgeInsets.symmetric(horizontal: 10.67, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 0.67),
      ),
      child: Center(
        child: Text(role.displayName, style: AppTextStyles.labelSmall),
      ),
    );
  }
}

class UserTeamBadge extends StatelessWidget {
  final String team;

  const UserTeamBadge({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27.33,
      padding: const EdgeInsets.symmetric(horizontal: 10.67, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.12),
          width: 0.67,
        ),
      ),
      child: Text(
        team,
        style: AppTextStyles.labelSmall,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class UserStatusIndicator extends StatelessWidget {
  final UserStatus status;

  const UserStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserStatusIcon(status: status),
        const SizedBox(width: 6),
        Text(
          status.displayName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: status.color,
          ),
        ),
      ],
    );
  }
}

class UserStatusIcon extends StatelessWidget {
  final UserStatus status;

  const UserStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: CustomPaint(painter: UserStatusIconPainter(status: status)),
    );
  }
}

class UserStatusIconPainter extends CustomPainter {
  final UserStatus status;

  UserStatusIconPainter({required this.status});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = status.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.17
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (status == UserStatus.active) {
      // Checkmark icon
      final path = Path()
        ..moveTo(size.width * 0.375, size.height * 0.464)
        ..lineTo(size.width * 0.5, size.height * 0.583)
        ..lineTo(size.width * 0.917, size.height * 0.167);
      canvas.drawPath(path, paint);

      // Circle
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.464,
        paint,
      );
    } else if (status == UserStatus.invited) {
      // Mail icon - envelope
      final path = Path()
        ..moveTo(size.width * 0.917, size.height * 0.292)
        ..lineTo(size.width * 0.542, size.height * 0.53)
        ..cubicTo(
          size.width * 0.521,
          size.height * 0.545,
          size.width * 0.479,
          size.height * 0.545,
          size.width * 0.458,
          size.height * 0.53,
        )
        ..lineTo(size.width * 0.083, size.height * 0.292);
      canvas.drawPath(path, paint);

      // Envelope rectangle
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.083,
          size.height * 0.167,
          size.width * 0.833,
          size.height * 0.667,
        ),
        Radius.circular(size.width * 0.083),
      );
      canvas.drawRRect(rect, paint);
    } else {
      // Clock icon - pending
      // Circle
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.464,
        paint,
      );

      // Clock hands
      final handPath = Path()
        ..moveTo(size.width * 0.5, size.height * 0.25)
        ..lineTo(size.width * 0.5, size.height * 0.5)
        ..lineTo(size.width * 0.667, size.height * 0.583);
      canvas.drawPath(handPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
