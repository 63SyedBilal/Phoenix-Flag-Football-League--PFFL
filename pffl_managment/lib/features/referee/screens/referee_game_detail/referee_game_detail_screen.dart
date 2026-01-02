import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/referee/providers/referee_game_detail_provider.dart';
import 'package:pffl_managment/features/referee/screens/referee_game_detail/widgets/referee_game_actions_tab.dart';
import 'package:pffl_managment/features/referee/screens/referee_game_detail/widgets/referee_game_app_bar.dart';
import 'package:pffl_managment/features/referee/screens/referee_game_detail/widgets/referee_game_fab_overlay.dart';
import 'package:pffl_managment/features/referee/screens/referee_game_detail/widgets/referee_game_tab_bar.dart';
import 'package:pffl_managment/features/referee/screens/referee_game_detail/widgets/referee_game_team_header.dart';
import 'package:pffl_managment/features/referee/widgets/toss_dialog.dart';
import 'package:pffl_managment/features/referee/widgets/start_game_dialog.dart';
import 'package:pffl_managment/features/referee/widgets/add_game_action_dialog.dart';
import 'package:pffl_managment/features/referee/widgets/mark_attendance_screen.dart';
import 'package:pffl_managment/features/referee/widgets/select_players_screen.dart';

class RefereeGameDetailScreen extends StatelessWidget {
  final MatchModel match;

  const RefereeGameDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RefereeGameDetailProvider()..initializeWithMatch(match),
      child: const _RefereeGameDetailView(),
    );
  }
}

class _RefereeGameDetailView extends StatelessWidget {
  const _RefereeGameDetailView();

  @override
  Widget build(BuildContext context) {
    return Consumer<RefereeGameDetailProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: RefereeGameAppBar(
            onForfeitTap: () => _showForfeitDialog(context, provider),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  RefereeGameTeamHeader(match: provider.match),
                  RefereeGameTabBar(
                    selectedIndex: provider.selectedTabIndex,
                    onTabSelected: provider.setSelectedTab,
                  ),
                  Expanded(child: _buildTabContent(context, provider)),
                ],
              ),
              if (provider.isFabExpanded)
                RefereeGameFabOverlay(
                  provider: provider,
                  onTossTap: () => _showTossDialog(context, provider),
                ),
            ],
          ),
          floatingActionButton: provider.selectedTabIndex == 0
              ? _buildFab(context, provider)
              : null,
        );
      },
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) {
    final match = provider.match;

    if (match == null) {
      return const Center(child: Text('Match data not available'));
    }

    switch (provider.selectedTabIndex) {
      case 0:
        return RefereeGameActionsTab(
          provider: provider,
          onAddActionTap: () => _showAddGameActionDialog(context, provider),
        );
      case 1:
        return MarkAttendanceScreen(match: match);
      case 2:
        return SelectPlayersScreen(match: match);
      default:
        return RefereeGameActionsTab(
          provider: provider,
          onAddActionTap: () => _showAddGameActionDialog(context, provider),
        );
    }
  }

  Widget _buildFab(BuildContext context, RefereeGameDetailProvider provider) {
    return FloatingActionButton(
      onPressed: provider.toggleFab,
      backgroundColor: const Color(0xFF1E3A5F),
      child: Icon(
        provider.isFabExpanded ? Icons.close : Icons.add,
        color: Colors.white,
      ),
    );
  }

  void _showTossDialog(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) {
    if (provider.match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match data not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TossDialog(
        match: provider.match!,
        onConfirm: (winnerTeamId, winnerSide) async {
          try {
            await provider.completeToss(winnerTeamId, winnerSide);

            if (context.mounted) {
              Navigator.of(context).pop();
            }

            // Show the Start Game dialog after toss is completed
            if (context.mounted) {
              _showStartGameDialog(context);
            }
          } catch (e) {
            // Error is already handled in provider, just show snackbar
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showStartGameDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const StartGameDialog(),
    );
  }

  void _showAddGameActionDialog(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) {
    if (provider.match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match data not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!provider.isTossCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the Toss before adding game actions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prepare selected players data for the dialog
    // Convert PlayerModel list to Map format expected by dialog
    final selectedPlayersByTeam = <String, List<Map<String, dynamic>>>{};

    // Helper function to extract team ID
    String? extractTeamId(dynamic teamIdData) {
      if (teamIdData == null) return null;
      if (teamIdData is String) return teamIdData;
      if (teamIdData is Map) {
        return teamIdData['_id']?.toString() ?? teamIdData['id']?.toString();
      }
      return teamIdData.toString();
    }

    // Get team IDs
    final teamAId = extractTeamId(provider.match!.homeTeamId);
    final teamBId = extractTeamId(provider.match!.awayTeamId);

    if (teamAId != null && teamAId.isNotEmpty) {
      final selectedPlayers = provider.getSelectedPlayersForTeam(teamAId);
      selectedPlayersByTeam[teamAId] = selectedPlayers
          .map(
            (player) => {
              'id': player.id,
              'name': player.name,
              'jerseyNumber': player.number,
              'position': player.position,
              'image': player.imageUrl,
              'email': player.email,
            },
          )
          .toList();
    }

    if (teamBId != null && teamBId.isNotEmpty) {
      final selectedPlayers = provider.getSelectedPlayersForTeam(teamBId);
      selectedPlayersByTeam[teamBId] = selectedPlayers
          .map(
            (player) => {
              'id': player.id,
              'name': player.name,
              'jerseyNumber': player.number,
              'position': player.position,
              'image': player.imageUrl,
              'email': player.email,
            },
          )
          .toList();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddGameActionDialog(
        match: provider.match!,
        selectedPlayersByTeam: selectedPlayersByTeam,
        onAddAction: (teamId, playerId, actionType) async {
          try {
            await provider.addGameAction(
              teamId: teamId,
              playerId: playerId,
              actionType: actionType,
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Game action added successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showForfeitDialog(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forfeit Game'),
        content: const Text(
          'Are you sure you want to forfeit this game? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.forfeitGame();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Game has been forfeited'),
                    backgroundColor: Color(0xFF1E3A5F),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Forfeit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
