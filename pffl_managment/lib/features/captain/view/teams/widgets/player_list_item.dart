import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/player_model.dart';
import '../../../providers/captain_team_provider.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/widgets/user_avatar_widget.dart';

class PlayerListItem extends StatelessWidget {
  final PlayerModel player;

  const PlayerListItem({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CaptainTeamProvider, AuthProvider>(
      builder: (context, teamProvider, authProvider, child) {
        final isCaptain = authProvider.userRole.toLowerCase() == 'captain';
        // Only allow removal if the current user is a captain and the player is not the captain
        final canRemove = isCaptain && !player.isCaptain;
        // Get actual payment status from provider
        final actualPaymentStatus = teamProvider.getPlayerPaymentStatus(player.id);
        print(
          '🔍 [PLAYER LIST DEBUG] Player: ${player.name}, isCaptain: ${player.isCaptain}',
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
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Player: ${player.name}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Player ID: ${player.id}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Image URL: "${player.imageUrl}"',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Has image: ${player.imageUrl != null}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Image not empty: ${player.imageUrl?.isNotEmpty ?? false}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Image starts with http: ${player.imageUrl?.startsWith('http') ?? false}',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Jersey number: "${player.number}"',
                  );
                  print(
                    '🖼️ [PLAYER IMAGE DEBUG] Position: "${player.position}"',
                  );
                  return UserAvatarWidget(
                    imageUrl: player.imageUrl,
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
                                  player.number.isNotEmpty
                                      ? '#${player.number} ${player.name}'
                                      : player.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lato',
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (player.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                              if (player.hasAlert) ...[
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
                        // Display status badge OR remove button
                        Row(
                          children: [
                            if (canRemove)
                              IconButton(
                                icon: const Icon(Icons.person_remove, color: Colors.red),
                                onPressed: () {
                                  // Trigger the remove player dialog/logic from CaptainTeamProvider
                                  _confirmRemovePlayer(context, player);
                                },
                                tooltip: 'Remove Player',
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: player.isCaptain
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  player.isCaptain ? 'Captain' : 'Player',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Lato',
                                    color: player.isCaptain
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
                                player.email,
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
                                      text: player.position.isNotEmpty
                                          ? player.position
                                          : 'Not set',
                                      style: TextStyle(
                                        color: player.position.isNotEmpty
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    if (player.additionalPositionsCount >
                                        0)
                                      TextSpan(
                                        text:
                                            ' +${player.additionalPositionsCount} more',
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
                            color: actualPaymentStatus
                                ? const Color(0xFF0F172A)
                                : Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            actualPaymentStatus ? 'Paid' : 'Unpaid',
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

  void _confirmRemovePlayer(BuildContext context, PlayerModel player) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Player Removal'),
          content: Text('Are you sure you want to remove ${player.name} from this team?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close confirmation dialog
                try {
                  await Provider.of<CaptainTeamProvider>(context, listen: false)
                      .removePlayer(context, player.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${player.name} has been removed.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to remove player: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}

