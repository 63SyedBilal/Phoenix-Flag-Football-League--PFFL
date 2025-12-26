import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/player_model.dart';
import '../../../providers/captain_team_provider.dart';
import '../../../../../core/providers/auth_provider.dart';

class PlayerListItem extends StatefulWidget {
  final PlayerModel player;

  const PlayerListItem({super.key, required this.player});

  @override
  State<PlayerListItem> createState() => _PlayerListItemState();
}

class _PlayerListItemState extends State<PlayerListItem> {
  String? _selectedMenuItem;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CaptainTeamProvider, AuthProvider>(
      builder: (context, teamProvider, authProvider, child) {
        final isCaptain = authProvider.userRole.toLowerCase() == 'captain';
        print('🔍 [PLAYER LIST DEBUG] User role: "${authProvider.userRole}"');
        print('🔍 [PLAYER LIST DEBUG] Is captain: $isCaptain');
        print(
          '🔍 [PLAYER LIST DEBUG] Player: ${widget.player.name}, isCaptain: ${widget.player.isCaptain}',
        );

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
                backgroundImage: widget.player.imageUrl != null
                    ? (widget.player.imageUrl!.startsWith('http') ||
                              widget.player.imageUrl!.startsWith('https')
                          ? NetworkImage(widget.player.imageUrl!)
                          : AssetImage(widget.player.imageUrl!)
                                as ImageProvider)
                    : null,
                backgroundColor: Colors.grey.shade200,
                child: widget.player.imageUrl == null
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
                                  '#${widget.player.number} ${widget.player.name}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.player.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                              if (widget.player.hasAlert) ...[
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.player.isCaptain
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.player.isCaptain ? 'Captain' : 'Player',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: widget.player.isCaptain
                                      ? const Color(0xFF92400E)
                                      : const Color(0xFF1E40AF),
                                ),
                              ),
                            ),
                            // Show 3-dot menu only for captains and only for non-captain players
                            if (isCaptain && !widget.player.isCaptain) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showPlayerActionsMenu(
                                  context,
                                  teamProvider,
                                ),
                                child: const Icon(
                                  Icons.more_vert,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
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
                              widget.player.email,
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
                                    text: widget.player.position,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (widget.player.additionalPositionsCount >
                                      0)
                                    TextSpan(
                                      text:
                                          ' +${widget.player.additionalPositionsCount} more',
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
                            color: widget.player.isPaid
                                ? const Color(0xFF0F172A)
                                : Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.player.isPaid ? 'Paid' : 'Unpaid',
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
      },
    );
  }

  void _showPlayerActionsMenu(
    BuildContext context,
    CaptainTeamProvider teamProvider,
  ) async {
    print(
      '🔍 [PLAYER LIST DEBUG] Showing 3-dot menu for player: ${widget.player.name}',
    );

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 0, // No elevation as per requirements
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFFD2B48C), // Light brown border
          width: 1.5,
        ),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'remove',
          child: Container(
            decoration: BoxDecoration(
              color: _selectedMenuItem == 'remove'
                  ? const Color(0xFFE8F4FD) // Light blue highlight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: const Row(
              children: [
                Icon(Icons.person_remove, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Remove Player'),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'transfer',
          child: Container(
            decoration: BoxDecoration(
              color: _selectedMenuItem == 'transfer'
                  ? const Color(0xFFE8F4FD) // Light blue highlight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: const Row(
              children: [
                Icon(Icons.swap_horiz, size: 18, color: Colors.blue),
                SizedBox(width: 8),
                Text('Transfer Leadership'),
              ],
            ),
          ),
        ),
      ],
    );

    if (result != null) {
      setState(() {
        _selectedMenuItem = result;
      });

      switch (result) {
        case 'remove':
          print('🎯 [REMOVE DEBUG] Remove player action selected');
          _showRemovePlayerDialog(context, teamProvider);
          break;
        case 'transfer':
          print('🎯 [TRANSFER DEBUG] Transfer leadership action selected');
          _showTransferLeadershipDialog(context, teamProvider);
          break;
      }
    }
  }

  void _showRemovePlayerDialog(
    BuildContext context,
    CaptainTeamProvider teamProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove ${widget.player.name} from the team?',
            ),
            const SizedBox(height: 8),
            const Text(
              'This player will receive a notification and become available for other teams.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removePlayer(context, teamProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showTransferLeadershipDialog(
    BuildContext context,
    CaptainTeamProvider teamProvider,
  ) {
    final team = teamProvider.team;
    if (team == null) return;

    final nonCaptainPlayers = team.players.where((p) => !p.isCaptain).toList();

    if (nonCaptainPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No players available for leadership transfer'),
        ),
      );
      return;
    }

    PlayerModel? selectedPlayer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Transfer Leadership'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select a player to transfer captain role to:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<PlayerModel>(
                initialValue: selectedPlayer,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select player...',
                ),
                items: nonCaptainPlayers.map((player) {
                  return DropdownMenuItem<PlayerModel>(
                    value: player,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: player.imageUrl != null
                              ? (player.imageUrl!.startsWith('http') ||
                                        player.imageUrl!.startsWith('https')
                                    ? NetworkImage(player.imageUrl!)
                                    : AssetImage(player.imageUrl!)
                                          as ImageProvider)
                              : null,
                          backgroundColor: Colors.grey.shade200,
                          child: player.imageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                player.position,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (player) {
                  setState(() {
                    selectedPlayer = player;
                  });
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'The selected player will receive an invitation to become captain.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedPlayer != null
                  ? () {
                      Navigator.of(context).pop();
                      _transferLeadership(
                        context,
                        teamProvider,
                        selectedPlayer!,
                      );
                    }
                  : null,
              child: const Text('Send Invitation'),
            ),
          ],
        ),
      ),
    );
  }

  void _removePlayer(BuildContext context, CaptainTeamProvider teamProvider) {
    print('🎯 [REMOVE DEBUG] Removing player: ${widget.player.name}');
    teamProvider
        .removePlayer(widget.player.id)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.player.name} has been removed from the team',
              ),
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove player: $error')),
          );
        });
  }

  void _transferLeadership(
    BuildContext context,
    CaptainTeamProvider teamProvider,
    PlayerModel newCaptain,
  ) {
    print('🎯 [TRANSFER DEBUG] Transferring leadership to: ${newCaptain.name}');
    print('🎯 [TRANSFER DEBUG] Player ID: ${newCaptain.id}');

    teamProvider
        .transferLeadership(newCaptain.id)
        .then((_) {
          print('✅ [TRANSFER DEBUG] Transfer completed successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Leadership transfer invitation sent to ${newCaptain.name}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        })
        .catchError((error) {
          print('❌ [TRANSFER DEBUG] Transfer failed: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to transfer leadership: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }
}
