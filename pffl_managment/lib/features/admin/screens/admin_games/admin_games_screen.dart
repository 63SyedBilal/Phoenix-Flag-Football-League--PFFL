import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/game_list_card.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/create_games_screens/create_games_screen.dart';

class AdminGamesScreen extends StatelessWidget {
  final List<MatchModel> matches;
  final LeagueCreationModel? league;

  const AdminGamesScreen({super.key, required this.matches, this.league});

  @override
  Widget build(BuildContext context) {
    // In MongoDB, ObjectIds contain timestamp, so sorting by id gives creation order
    final sortedMatches = List<MatchModel>.from(matches);
    sortedMatches.sort((a, b) {
      // Primary sort: by creation order (using id)
      if (a.id != null && b.id != null) {
        // MongoDB ObjectIds are sortable by creation time
        return a.id!.compareTo(b.id!);
      }
      // Fallback: if one has id and other doesn't, prioritize the one with id
      if (a.id != null) return -1;
      if (b.id != null) return 1;

      // Secondary fallback: use matchDateTime if available
      if (a.matchDateTime != null && b.matchDateTime != null) {
        return a.matchDateTime!.compareTo(b.matchDateTime!);
      }
      if (a.matchDateTime != null) return -1;
      if (b.matchDateTime != null) return 1;

      return 0;
    });

    // Calculate total games from sorted matches list
    int totalGames = sortedMatches.length;
    for (final match in sortedMatches) {
      if (match.gameNumber != null && match.gameNumber!.isNotEmpty) {
        final total = _extractTotalFromGameNumber(
          match.gameNumber!,
          totalGames,
        );
        if (total > totalGames) {
          totalGames = total;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Games'),
        backgroundColor: Colors.white,
      ),
      body: sortedMatches.isEmpty
          ? const Center(
              child: Text(
                'No games scheduled yet',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: sortedMatches.length,
                itemBuilder: (context, index) {
                  // Calculate sequence number based on position (1-based)
                  // Games are sorted by creation order
                  final sequenceNumber = index + 1;
                  return GameListCard(
                    match: sortedMatches[index],
                    totalGames: totalGames,
                    sequenceNumber: sequenceNumber,
                  );
                },
              ),
            ),
      floatingActionButton: league != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateUpcomingGamesScreen(league: league!),
                  ),
                );
              },
              backgroundColor: const Color(0xFF0F172A),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  /// Extract total number from gameNumber string like "Game 8 of 12"
  int _extractTotalFromGameNumber(String gameNumber, int defaultTotal) {
    try {
      final parts = gameNumber.split(' of ');
      if (parts.length == 2) {
        return int.parse(parts[1]);
      }
    } catch (e) {
      // If parsing fails, return default
    }
    return defaultTotal;
  }
}
