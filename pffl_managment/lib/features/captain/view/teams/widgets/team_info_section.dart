import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import '../../../model/team_model.dart';
import '../../../model/player_model.dart';

class TeamInfoSection extends StatefulWidget {
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
  State<TeamInfoSection> createState() => _TeamInfoSectionState();
}

class _TeamInfoSectionState extends State<TeamInfoSection> {
  final GlobalKey _iconKey = GlobalKey();
  String? _selectedMenuItem;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if current user is a captain
        final isCaptain = authProvider.userRole.toLowerCase() == 'captain';

        // Debug logging to verify role-based logic
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
                      child:
                          widget.team.logoUrl != null &&
                              widget.team.logoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                widget.team.logoUrl!,
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
                      widget.team.name,
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
                      '${widget.team.players.length}/${widget.team.maxPlayers}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    // Only show 3-dot icon for captains
                    if (isCaptain)
                      IconButton(
                        key: _iconKey,
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showTeamActionsMenu(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
            // Format selection (only show if format callbacks are provided)
            if (widget.selectedFormat != null &&
                widget.onFormatChanged != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFormatBadge(
                    context,
                    label: '5v5',
                    isSelected: widget.selectedFormat == '5v5',
                    onTap: () => widget.onFormatChanged!('5v5'),
                  ),
                  const SizedBox(width: 8),
                  _buildFormatBadge(
                    context,
                    label: '7v7',
                    isSelected: widget.selectedFormat == '7v7',
                    onTap: () => widget.onFormatChanged!('7v7'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  void _showTeamActionsMenu(BuildContext context) {
    final RenderBox icon =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          icon.localToGlobal(const Offset(0, 30), ancestor: overlay),
          icon.localToGlobal(
            icon.size.bottomRight(const Offset(0, 30)),
            ancestor: overlay,
          ),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'transfer_leadership',
          onTap: () => Future.delayed(
            const Duration(milliseconds: 100),
            () => _showTransferLeadershipDialog(context),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _selectedMenuItem == 'transfer_leadership'
                  ? const Color(0xFFE8F4FD) // Light blue highlight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
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
          onTap: () => Future.delayed(
            const Duration(milliseconds: 100),
            () => _showRemovePlayerDialog(context),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _selectedMenuItem == 'remove_player'
                  ? const Color(0xFFE8F4FD) // Light blue highlight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
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

  void _showTransferLeadershipDialog(BuildContext context) {
    final nonCaptainPlayers = widget.team.players
        .where((p) => !p.isCaptain)
        .toList();

    if (nonCaptainPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No players available to transfer leadership to.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    PlayerModel? selectedPlayer;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          setState(() {
                            selectedPlayer = player;
                          });
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
                          _transferLeadership(context, selectedPlayer!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send Invitation'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRemovePlayerDialog(BuildContext context) {
    final nonCaptainPlayers = widget.team.players
        .where((p) => !p.isCaptain)
        .toList();

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
      builder: (BuildContext dialogContext) {
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
                          Navigator.of(dialogContext).pop();
                          _confirmRemovePlayer(context, player);
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _confirmRemovePlayer(BuildContext context, PlayerModel player) {
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
                _removePlayer(context, player);
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

  void _transferLeadership(BuildContext context, PlayerModel selectedPlayer) {
    // TODO: Implement leadership transfer logic
    // This should:
    // 1. Send notification to selected player: "This captain has offered you the captain role."
    // 2. Handle acceptance/rejection
    // 3. Update roles if accepted

    print(
      '🎯 [TRANSFER DEBUG] Transferring leadership to: ${selectedPlayer.name}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Leadership transfer invitation sent to ${selectedPlayer.name}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removePlayer(BuildContext context, PlayerModel player) {
    // TODO: Implement player removal logic
    // This should:
    // 1. Remove player from team
    // 2. Send notification: "You have been removed from this team."
    // 3. Update team state

    print('🎯 [REMOVE DEBUG] Removing player: ${player.name}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${player.name} has been removed from the team'),
        backgroundColor: Colors.orange,
      ),
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
