import 'package:flutter/material.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/features/referee/screens/referee_game_detail/referee_game_detail_screen.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

/// Helper class for game navigation
/// Provides reusable navigation logic for game cards
class GameNavigationHelper {
  /// Navigate to game detail screen by fetching match data
  /// This is the proper click handler for Assign Card / Game Card
  /// 
  /// Usage:
  /// ```dart
  /// SharedGameCard(
  ///   game: game,
  ///   onTap: () => GameNavigationHelper.navigateToGameDetail(context, game),
  /// )
  /// ```
  static Future<void> navigateToGameDetail(
    BuildContext context,
    GameModel game,
  ) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Fetch match details by ID
      final match = await MatchService.getMatchById(game.id);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to game detail screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RefereeGameDetailScreen(match: match),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load game details: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Navigate to game detail screen using MatchModel directly
  /// Use this when you already have the MatchModel
  static void navigateToGameDetailFromMatch(
    BuildContext context,
    MatchModel match,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefereeGameDetailScreen(match: match),
      ),
    );
  }
}
