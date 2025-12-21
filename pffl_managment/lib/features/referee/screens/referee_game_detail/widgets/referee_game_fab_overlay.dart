import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/referee/models/referee_game_action.dart';
import 'package:pffl_managment/features/referee/providers/referee_game_detail_provider.dart';

class RefereeGameFabOverlay extends StatelessWidget {
  const RefereeGameFabOverlay({
    super.key,
    required this.provider,
    required this.onTossTap,
  });

  final RefereeGameDetailProvider provider;
  final VoidCallback onTossTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: provider.closeFab,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _RefereeFabOption(
                  label: 'Game Complete',
                  icon: Icons.check_circle,
                  color: const Color(0xFF1E3A5F),
                  isCompleted: provider.isGameComplete,
                  onTap: () =>
                      provider.executeAction(RefereeGameAction.gameComplete),
                ),
                const SizedBox(height: 8),
                _RefereeFabOption(
                  label: 'Over Time',
                  icon: Icons.access_time_filled,
                  color: const Color(0xFFEA580C),
                  isCompleted: provider.isOverTime,
                  onTap: () =>
                      provider.executeAction(RefereeGameAction.overTime),
                ),
                const SizedBox(height: 8),
                _RefereeFabOption(
                  label: 'Full Time Done',
                  icon: Icons.check,
                  color: const Color(0xFF1E3A5F),
                  isCompleted: provider.isFullTimeDone,
                  onTap: () =>
                      provider.executeAction(RefereeGameAction.fullTimeDone),
                ),
                const SizedBox(height: 8),
                _RefereeFabOption(
                  label: 'Half Time Done',
                  icon: Icons.check,
                  color: const Color(0xFFEA580C),
                  isCompleted: provider.isHalfTimeDone,
                  onTap: () =>
                      provider.executeAction(RefereeGameAction.halfTimeDone),
                ),
                const SizedBox(height: 8),
                _RefereeFabOption(
                  label: 'Toss',
                  icon: Icons.sports_football,
                  color: const Color(0xFF1E3A5F),
                  isCompleted: provider.isTossCompleted ||
                      provider.match?.status == MatchStatus.live ||
                      provider.match?.status == MatchStatus.completed,
                  onTap: onTossTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RefereeFabOption extends StatelessWidget {
  const _RefereeFabOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCompleted ? color.withOpacity(0.7) : color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
