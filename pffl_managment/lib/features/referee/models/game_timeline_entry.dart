import 'package:flutter/material.dart';

/// Types of timeline entries shown in the referee game actions tab.
enum GameTimelineEntryType { milestone, player }

/// Domain model describing a single item rendered in the game timeline widget.
class GameTimelineEntry {
  const GameTimelineEntry._({
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.isStart = false,
    this.showAddBadge = false,
    this.playerName,
    this.position,
    this.isLeft = true,
  });

  const GameTimelineEntry.milestone({
    required String label,
    IconData icon = Icons.circle,
    Color iconColor = const Color(0xFF1E293B),
    bool showAddBadge = false,
    bool isStart = false,
  }) : this._(
          type: GameTimelineEntryType.milestone,
          label: label,
          icon: icon,
          iconColor: iconColor,
          showAddBadge: showAddBadge,
          isStart: isStart,
        );

  const GameTimelineEntry.player({
    required String playerName,
    required String position,
    IconData icon = Icons.sports_football,
    Color iconColor = const Color(0xFF1E293B),
    bool isLeft = true,
  }) : this._(
          type: GameTimelineEntryType.player,
          label: '',
          icon: icon,
          iconColor: iconColor,
          playerName: playerName,
          position: position,
          isLeft: isLeft,
        );

  final GameTimelineEntryType type;
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isStart;
  final bool showAddBadge;
  final String? playerName;
  final String? position;
  final bool isLeft;
}
