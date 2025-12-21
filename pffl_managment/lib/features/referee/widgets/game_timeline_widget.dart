import 'package:flutter/material.dart';
import 'package:pffl_managment/features/referee/models/game_timeline_entry.dart';

/// Timeline widget that mirrors the provided static UI but renders dynamic data.
class GameTimelineWidget extends StatelessWidget {
  const GameTimelineWidget({
    super.key,
    required this.entries,
    this.onAddActionTap,
  });

  final List<GameTimelineEntry> entries;
  final VoidCallback? onAddActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Plus icon as the starting point of timeline
          if (onAddActionTap != null)
            SizedBox(
              height: 80,
              child: Stack(
                children: [
                  // Vertical line - starts from bottom of circle (only if there are entries)
                  if (entries.isNotEmpty)
                    Positioned(
                      top: 60, // Circle bottom (40px circle centered at 40px, so bottom is 40+20=60px)
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 2,
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  // Plus icon button - circle style like timeline entries
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: onAddActionTap,
                          child: Container(
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
                            child: const Icon(
                              Icons.add,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Timeline entries
          ...entries.asMap().entries.map((entryWithIndex) {
            final index = entryWithIndex.key;
            final entry = entryWithIndex.value;
            final isLast = index == entries.length - 1;
            if (entry.type == GameTimelineEntryType.milestone) {
              return _buildTimelineItem(entry, isLast: isLast);
            }
            return _buildPlayerAction(context, entry, isLast: isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(GameTimelineEntry entry, {bool isLast = false}) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          // Vertical line - from top to bottom, but circle will cover the center part
          if (!isLast)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 2,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
            )
          else
            // For last item, line only goes from top to circle center
            Positioned(
              top: 0,
              bottom: 40, // Circle center (40px from bottom)
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 2,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
            ),
          // Circle on top of line (white background covers line in center)
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
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      entry.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

  Widget _buildPlayerAction(BuildContext context, GameTimelineEntry entry, {bool isLast = false}) {
    final isLeft = entry.isLeft;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = (screenWidth - 32 - 16) / 2; // Container padding + icon space
    
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          // Vertical line - from top to bottom, but circle will cover the center part
          if (!isLast)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 2,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
            )
          else
            // For last item, line only goes from top to circle center
            Positioned(
              top: 0,
              bottom: 35, // Circle center (35px from bottom for 36px circle)
              left: 0,
              right: 0,
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
            width: availableWidth - 20, // Subtract some padding
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
                    padding: const EdgeInsets.only(right: 8, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            entry.playerName ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            entry.position ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActionIcon(entry),
                const SizedBox(width: 8),
              ] else ...[
                const SizedBox(width: 8),
                _buildActionIcon(entry),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            entry.playerName ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            entry.position ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
