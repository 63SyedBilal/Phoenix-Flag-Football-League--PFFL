import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/captain/providers/captain_team_provider.dart'; // Import CaptainTeamProvider
import '../../../model/team_model.dart';
import '../../../model/player_model.dart';

// Extracted dialog for Transfer Leadership to keep TeamInfoSection stateless and under line limit
class TransferLeadershipDialog extends StatelessWidget {
  final TeamModel team;
  final Function(String newCaptainId) onTransferLeadership;

  const TransferLeadershipDialog({
    super.key,
    required this.team,
    required this.onTransferLeadership,
  });

  @override
  Widget build(BuildContext context) {
    final nonCaptainPlayers = team.players.where((p) => !p.isCaptain).toList();

    if (nonCaptainPlayers.isEmpty) {
      // This should ideally be handled before showing the dialog,
      // but as a fallback, we can show a message.
      return AlertDialog(
        title: const Text('No Players'),
        content: const Text('No players available to transfer leadership to.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    // Using a temporary ChangeNotifier to hold selected player for the dialog
    // This is a common pattern for stateless dialogs that need internal state.
    return ChangeNotifierProvider(
      create: (_) => _SelectedPlayerProvider(),
      builder: (dialogContext, child) {
        final selectedPlayerProvider = Provider.of<_SelectedPlayerProvider>(dialogContext);
        PlayerModel? selectedPlayer = selectedPlayerProvider.selectedPlayer;

        return AlertDialog(
          title: const Text(
            'Transfer Leadership',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a player to transfer captain role to:',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PlayerModel>(
                    value: selectedPlayer,
                    hint: const Text('Choose a player...'),
                    isExpanded: true,
                    items: nonCaptainPlayers.map((player) {
                      return DropdownMenuItem<PlayerModel>(
                        value: player,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: player.imageUrl != null
                                  ? NetworkImage(player.imageUrl!)
                                  : null,
                              child: player.imageUrl == null
                                  ? const Icon(Icons.person, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    player.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (player.position.isNotEmpty)
                                    Text(
                                      player.position,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (PlayerModel? player) {
                      selectedPlayerProvider.setSelectedPlayer(player);
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedPlayer == null
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      onTransferLeadership(selectedPlayer.id);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Transfer Captainship'), // Changed button text
            ),
          ],
        );
      },
    );
  }
}

// Simple ChangeNotifier to manage selected player state for the dialog
class _SelectedPlayerProvider extends ChangeNotifier {
  PlayerModel? _selectedPlayer;

  PlayerModel? get selectedPlayer => _selectedPlayer;

  void setSelectedPlayer(PlayerModel? player) {
    _selectedPlayer = player;
    notifyListeners();
  }
}

// Extracted dialog for Remove Player
class RemovePlayerDialog extends StatelessWidget {
  final TeamModel team;
  final Function(String playerId) onRemovePlayer;

  const RemovePlayerDialog({
    super.key,
    required this.team,
    required this.onRemovePlayer,
  });

  @override
  Widget build(BuildContext context) {
    final nonCaptainPlayers = team.players.where((p) => !p.isCaptain).toList();

    if (nonCaptainPlayers.isEmpty) {
      return AlertDialog(
        title: const Text('No Players'),
        content: const Text('No players available to remove.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text(
        'Remove Player',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select players to remove from the team:',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: nonCaptainPlayers.length,
              itemBuilder: (context, index) {
                final player = nonCaptainPlayers[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: player.imageUrl != null
                        ? NetworkImage(player.imageUrl!)
                        : null,
                    child: player.imageUrl == null
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: player.position.isNotEmpty
                      ? Text(
                          player.position,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confirmRemovePlayer(context, player, onRemovePlayer);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _confirmRemovePlayer(
      BuildContext context, PlayerModel player, Function(String) onRemovePlayerCallback) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: Text(
            'Are you sure you want to remove ${player.name} from the team?\n\nThey will be notified of their removal.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onRemovePlayerCallback(player.id);
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

class TeamInfoSection extends StatelessWidget {
  final TeamModel team;
  final String? selectedFormat;
  final Function(String)? onFormatChanged;

  const TeamInfoSection({
    super.key,
    required this.team,
    this.selectedFormat,
    this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isCaptain = authProvider.userRole.toLowerCase() == 'captain';

        print('🔍 [TEAM INFO DEBUG] User role: "${authProvider.userRole}"');
        print('🔍 [TEAM INFO DEBUG] Is captain: $isCaptain');
        print(
          '🔍 [TEAM INFO DEBUG] 3-dot icon will be ${isCaptain ? "visible" : "hidden"}',
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.none,
                        ),
                      ),
                      child: team.logoUrl != null && team.logoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                team.logoUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: const Icon(
                                      Icons.shield,
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.shield,
                                color: Colors.black,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${team.players.length}/${team.maxPlayers}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    // Only show 3-dot icon for captains
                    if (isCaptain)
                      // Use a Builder to get a context for the PopupMenuButton
                      Builder(builder: (menuContext) {
                        return IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showTeamActionsMenu(menuContext, team),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        );
                      }),
                  ],
                ),
              ],
            ),
            // Format selection (only show if format callbacks are provided)
            if (selectedFormat != null && onFormatChanged != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFormatBadge(
                    context,
                    label: '5v5',
                    isSelected: selectedFormat == '5v5',
                    onTap: () => onFormatChanged?.call('5v5'),
                  ),
                  const SizedBox(width: 8),
                  _buildFormatBadge(
                    context,
                    label: '7v7',
                    isSelected: selectedFormat == '7v7',
                    onTap: () => onFormatChanged?.call('7v7'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  void _showTeamActionsMenu(BuildContext context, TeamModel currentTeam) {
    showMenu(
      color: Colors.white,
      elevation: 0, // Remove elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFFD1D5DB), // Light brown border
          width: 1.5,
        ),
      ),
      context: context,
      position: const RelativeRect.fromLTRB(1000.0, 60.0, 0.0, 0.0), // Adjust position as needed
      items: [
        PopupMenuItem<String>(
          value: 'transfer_leadership',
          onTap: () {
            // Delay to allow menu to close before showing dialog
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _showTransferLeadershipDialog(context, currentTeam),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text(
              'Transfer Captainship',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Colors.black87,
              ),
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'remove_player',
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _showRemovePlayerDialog(context, currentTeam),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text(
              'Remove Player',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTransferLeadershipDialog(BuildContext context, TeamModel team) {
    final nonCaptainPlayers = team.players.where((p) => !p.isCaptain).toList();

    if (nonCaptainPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No players available to transfer leadership to.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return TransferLeadershipDialog(
          team: team,
          onTransferLeadership: (newCaptainId) async {
            try {
              await Provider.of<CaptainTeamProvider>(context, listen: false)
                  .transferLeadership(context, newCaptainId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Leadership transfer initiated.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _showRemovePlayerDialog(BuildContext context, TeamModel team) {
    final nonCaptainPlayers = team.players.where((p) => !p.isCaptain).toList();

    if (nonCaptainPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No players available to remove.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return RemovePlayerDialog(
          team: team,
          onRemovePlayer: (playerId) async {
            try {
              await Provider.of<CaptainTeamProvider>(context, listen: false)
                  .removePlayer(context, playerId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Player removal initiated.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildFormatBadge(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
