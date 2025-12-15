import 'package:flutter/material.dart';
import '../models/inviteable_user_model.dart';
import '../providers/captain_invite_provider.dart';

/// Individual user card widget
class InviteUserCard extends StatelessWidget {
  final InviteableUserModel user;
  final CaptainInviteProvider provider;

  const InviteUserCard({
    super.key,
    required this.user,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      user.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Color(0xFF9CA3AF),
                          size: 28,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Color(0xFF9CA3AF),
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                if (user.positionDisplayText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Position: ${user.positionDisplayText}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Invite button
          GestureDetector(
            onTap: user.isInviting || user.isInvited
                ? null
                : () => provider.inviteUser(user.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: user.isInvited
                    ? Colors.white
                    : const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: user.isInvited
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF3B82F6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.isInviting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: user.isInvited ? Colors.grey[600] : Colors.white,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    user.isInviting
                        ? 'Inviting...'
                        : (user.isInvited ? 'Invited' : 'Invite'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: user.isInvited ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

