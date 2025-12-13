import 'package:flutter/material.dart';
import '../../../model/player_model.dart';

class PlayerListItem extends StatelessWidget {
  final PlayerModel player;

  const PlayerListItem({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
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
          CircleAvatar(
            radius: 24,
            backgroundImage: player.imageUrl != null
                ? AssetImage(player.imageUrl!)
                : null,
            backgroundColor: Colors.grey.shade200,
            child: player.imageUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
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
                              '#${player.number} ${player.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
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
                          color: player.isCaptain
                              ? const Color(0xFF92400E)
                              : const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.email,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            children: [
                              const TextSpan(text: 'Position: '),
                              TextSpan(
                                text: player.position,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              if (player.additionalPositionsCount > 0)
                                TextSpan(
                                  text:
                                      ' +${player.additionalPositionsCount} more',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: player.isPaid
                            ? const Color(0xFF0F172A)
                            : Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        player.isPaid ? 'Paid' : 'Unpaid',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
  }
}
