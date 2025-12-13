import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/features/admin/users/providers/users_provider.dart';
import 'package:provider/provider.dart';

class UserHeaderWidget extends StatelessWidget {
  const UserHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Users', style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Manage all platform users',
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const UserNotificationButton(),
        ],
      ),
    );
  }
}

class UserNotificationButton extends StatelessWidget {
  const UserNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersProvider>(
      builder: (context, viewModel, child) {
        return InkWell(
          onTap: () => viewModel.toggleNotifications(),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.12),
                width: 0.67,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: Color(0xFF364153),
                  ),
                ),
                if (viewModel.hasNotifications)
                  Positioned(
                    top: 8.67,
                    right: 12.67,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDB1F35),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UserInviteButton extends StatelessWidget {
  const UserInviteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<UsersProvider>().inviteUser();
      },
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add_outlined,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              'Invite',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
