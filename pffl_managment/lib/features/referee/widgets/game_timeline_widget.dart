import 'package:flutter/material.dart';
import 'package:pffl_managment/features/referee/models/game_timeline_entry.dart';

/// Timeline widget that mirrors the provided static UI but renders dynamic data.
class GameTimelineWidget extends StatelessWidget {
  const GameTimelineWidget({
    super.key,
    required this.entries,
  });

  final List<GameTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: entries.map((entry) {
          if (entry.type == GameTimelineEntryType.milestone) {
            return _buildTimelineItem(entry);
          }
          return _buildPlayerAction(context, entry);
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(GameTimelineEntry entry) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Container(
                width: 2,
                color: const Color(0xFFE5E7EB),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    entry.icon,
                    color: entry.iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          if (entry.showAddBadge)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerAction(BuildContext context, GameTimelineEntry entry) {
    final isLeft = entry.isLeft;
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Container(
                width: 2,
                color: const Color(0xFFE5E7EB),
              ),
            ),
          ),
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: 35,
            width: MediaQuery.of(context).size.width / 2 - 36,
            child: Container(
              height: 2,
              color: const Color(0xFFE5E7EB),
            ),
          ),
          Row(
            children: [
              if (isLeft) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.playerName ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.position ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActionIcon(entry),
                const Expanded(child: SizedBox()),
              ] else ...[
                const Expanded(child: SizedBox()),
                _buildActionIcon(entry),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.playerName ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.position ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(GameTimelineEntry entry) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 2,
        ),
      ),
      child: Icon(
        entry.icon,
        color: entry.iconColor,
        size: 18,
      ),
    );
  }
}
