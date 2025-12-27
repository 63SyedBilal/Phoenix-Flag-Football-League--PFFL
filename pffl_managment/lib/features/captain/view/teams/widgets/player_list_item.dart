import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/player_model.dart';
import '../../../providers/captain_team_provider.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/widgets/user_avatar_widget.dart';

class PlayerListItem extends StatefulWidget {
  final PlayerModel player;

  const PlayerListItem({super.key, required this.player});

  @override
  State<PlayerListItem> createState() => _PlayerListItemState();
}

class _PlayerListItemState extends State<PlayerListItem> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<CaptainTeamProvider, AuthProvider>(
      builder: (context, teamProvider, authProvider, child) {
        final isCaptain = authProvider.userRole.toLowerCase() == 'captain';
        print('🔍 [PLAYER LIST DEBUG] User role: "${authProvider.userRole}"');
        print('🔍 [PLAYER LIST DEBUG] Is captain: $isCaptain');
        print(
          '🔍 [PLAYER LIST DEBUG] Player: ${widget.player.name}, isCaptain: ${widget.player.isCaptain}',
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Debug logging for image URL
              Builder(
                builder: (context) {
                  print('🖼️ [PLAYER IMAGE DEBUG] ==================');
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Player: ${widget.player.name}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Player ID: ${widget.player.id}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Image URL: "${widget.player.imageUrl}"',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Has image: ${widget.player.imageUrl != null}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Image not empty: ${widget.player.imageUrl?.isNotEmpty ?? false}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Image starts with http: ${widget.player.imageUrl?.startsWith('http') ?? false}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Jersey number: "${widget.player.number}"',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Position: "${widget.player.position}"',
                  );
                  print('🖼️ [PLAYER IMAGE DEBUG] ==================');
                  return UserAvatarWidget(
                    imageUrl: widget.player.imageUrl,
                    size: 48,
                    borderWidth: 2,
                    borderColor: const Color(0xFFF3F4F6),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.player.number.isNotEmpty
                                      ? '#${widget.player.number} ${widget.player.name}'
                                      : widget.player.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lato',
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.player.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                              if (widget.player.hasAlert) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.access_time_filled,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.player.isCaptain
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.player.isCaptain ? 'Captain' : 'Player',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lato',
                                  color: widget.player.isCaptain
                                      ? const Color(0xFF92400E)
                                      : const Color(0xFF1E40AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.player.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Position: '),
                                    TextSpan(
                                      text: widget.player.position.isNotEmpty
                                          ? widget.player.position
                                          : 'Not set',
                                      style: TextStyle(
                                        color: widget.player.position.isNotEmpty
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    if (widget.player.additionalPositionsCount >
                                        0)
                                      TextSpan(
                                        text:
                                            ' +${widget.player.additionalPositionsCount} more',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF0F173E),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.player.isPaid
                                ? const Color(0xFF0F172A)
                                : Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.player.isPaid ? 'Paid' : 'Unpaid',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
