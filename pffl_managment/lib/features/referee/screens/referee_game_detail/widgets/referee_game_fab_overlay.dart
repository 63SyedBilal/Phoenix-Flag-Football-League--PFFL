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
    // Determine sequential flow states
    final isTossDone =
        provider.isTossCompleted ||
        provider.match?.status == MatchStatus.live ||
        provider.match?.status == MatchStatus.completed;

    // Toss: Enabled if NOT done
    final isTossEnabled = !isTossDone;

    // Half Time: Enabled if Toss done AND Half Time NOT done
    final isHalfTimeEnabled = isTossDone && !provider.isHalfTimeDone;

    // Full Time: Enabled if Half Time done AND Full Time NOT done
    final isFullTimeEnabled =
        provider.isHalfTimeDone && !provider.isFullTimeDone;

    // Over Time: Enabled if Full Time done AND Over Time NOT done AND Game NOT complete
    final isOverTimeEnabled =
        provider.isFullTimeDone &&
        !provider.isOverTime &&
        !provider.isGameComplete;

    // Game Complete: Enabled if Full Time done AND Game NOT complete
    final isGameCompleteEnabled =
        provider.isFullTimeDone && !provider.isGameComplete;

    const double buttonWidth = 200.0;

    return GestureDetector(
      onTap: provider.closeFab,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
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
                  isEnabled: isGameCompleteEnabled,
                  width: buttonWidth,
                  onTap: () =>
                      provider.executeAction(RefereeGameAction.gameComplete),
                ),
                const SizedBox(height: 8),
                _RefereeFabOption(
                  label: 'Over Time',
                  icon: Icons.access_time_filled,
                  color: const Color(0xFFEA580C),
                  isCompleted: provider.isOverTime,
                  isEnabled: isOverTimeEnabled,
                  width: buttonWidth,
                  onTap: () =>
                      provider.executeAction(RefereeGameAction.overTime),
                ),
                const SizedBox(height: 8),
                _RefereeFabOption(
                  label: 'Full Time Done',
                  icon: Icons.check,
                  color: const Color(0xFF1E3A5F),
                  isCompleted: provider.isFullTimeDone,
                  isEnabled: isFullTimeEnabled,
                  width: buttonWidth,
                  onTap: () =>
                      provider.executeAction(RefereeGameAction.fullTimeDone),
                ),
                const SizedBox(height: 8),
                _RefereeFabOption(
                  label: 'Half Time Done',
                  icon: Icons.check,
                  color: const Color(0xFFEA580C),
                  isCompleted: provider.isHalfTimeDone,
                  isEnabled: isHalfTimeEnabled,
                  width: buttonWidth,
                  onTap: () =>
                      provider.executeAction(RefereeGameAction.halfTimeDone),
                ),
                const SizedBox(height: 8),
                _RefereeFabOption(
                  label: 'Toss',
                  icon: Icons.sports_football,
                  color: const Color(0xFF1E3A5F),
                  isCompleted: isTossDone,
                  isEnabled: isTossEnabled,
                  width: buttonWidth,
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
    required this.isEnabled,
    required this.width,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final bool isEnabled;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Determine background color based on state
    final Color backgroundColor;
    if (isCompleted) {
      backgroundColor = color.withValues(alpha: 0.7);
    } else if (isEnabled) {
      backgroundColor = color;
    } else {
      backgroundColor = Colors.grey;
    }

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
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
