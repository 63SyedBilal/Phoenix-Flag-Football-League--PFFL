import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/profile_service.dart';

/// Add Game Action Dialog
/// Allows referee to add game actions (Touchdown, Extra Points, etc.) to a match
/// Only shows players that were selected in the Select Players screen
class AddGameActionDialog extends StatefulWidget {
  final MatchModel match;
  final Function(String teamId, String playerId, String actionType) onAddAction;
  final Map<String, List<Map<String, dynamic>>>?
  selectedPlayersByTeam; // teamId -> List of player data

  const AddGameActionDialog({
    super.key,
    required this.match,
    required this.onAddAction,
    this.selectedPlayersByTeam,
  });

  @override
  State<AddGameActionDialog> createState() => _AddGameActionDialogState();
}

class _AddGameActionDialogState extends State<AddGameActionDialog> {
  // Selected team (A or B)
  String? _selectedTeam;

  // Selected action type
  String? _selectedActionType;

  // Selected player ID
  String? _selectedPlayerId;

  // Action types with scores - matching backend ACTION_SCORES
  // Note: Backend has "Extra Point from 20-yard line" as +2, but UI shows +3 per design
  // Keeping UI as +3 to match design, backend will handle the actual score
  final List<Map<String, dynamic>> _actionTypes = [
    {'type': 'Touchdown (TD)', 'score': '+6', 'backendType': 'Touchdown'},
    {
      'type': 'Extra Point from 5-yard line',
      'score': '+1',
      'backendType': 'Extra Point from 5-yard line',
    },
    {
      'type': 'Extra Point from 12-yard line',
      'score': '+2',
      'backendType': 'Extra Point from 12-yard line',
    },
    {
      'type': 'Extra Point from 20-yard line',
      'score': '+3',
      'backendType': 'Extra Point from 20-yard line',
    },
  ];

  // Team A and Team B players
  List<Map<String, dynamic>> _teamAPlayers = [];
  List<Map<String, dynamic>> _teamBPlayers = [];

  bool _isLoading = false;
  bool _isLoadingPlayers = false;

  @override
  void initState() {
    super.initState();
    // Set default team selection (Team A) and load players immediately
    _selectedTeam = 'A';
    // Load players for default team after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayersForTeam('A');
    });
  }

  Future<void> _loadPlayersForTeam(String team) async {
    setState(() {
      _isLoadingPlayers = true;
    });

    try {
      // Get team ID
      final teamId = _getTeamId(team);
      if (teamId.isEmpty) {
        setState(() {
          _isLoadingPlayers = false;
        });
        return;
      }

      // Use selected players if available, otherwise show empty list
      final selectedPlayers = widget.selectedPlayersByTeam?[teamId] ?? [];

      // Convert selected players to the format needed for display
      final playersList = <Map<String, dynamic>>[];

      for (var playerData in selectedPlayers) {
        final playerId =
            playerData['id']?.toString() ?? playerData['_id']?.toString() ?? '';
        if (playerId.isEmpty) continue;

        // Use provided data or fetch profile if needed
        String? jerseyNumber =
            playerData['jerseyNumber']?.toString() ??
            playerData['number']?.toString();
        String? position = playerData['position']?.toString();
        String? image =
            playerData['image']?.toString() ??
            playerData['imageUrl']?.toString() ??
            playerData['profilePictureUrl']?.toString();
        String? name = playerData['name']?.toString();

        // If name is not provided, try to construct it
        if (name == null || name.isEmpty) {
          final firstName = playerData['firstName']?.toString() ?? '';
          final lastName = playerData['lastName']?.toString() ?? '';
          final email = playerData['email']?.toString() ?? '';

          if (firstName.isNotEmpty && lastName.isNotEmpty) {
            name = '$firstName $lastName';
          } else if (email.isNotEmpty) {
            name = email;
          } else {
            name =
                'Player ${playerId.substring(playerId.length > 4 ? playerId.length - 4 : 0)}';
          }
        }

        // Fetch profile if jersey number or position is missing
        if ((jerseyNumber == null || jerseyNumber.isEmpty) ||
            (position == null || position.isEmpty)) {
          try {
            final profile = await ProfileService.getProfile(playerId);
            if (profile != null) {
              jerseyNumber ??= profile['jerseyNumber']?.toString();
              position ??= profile['position']?.toString();
              image ??= profile['image']?.toString();
            }
          } catch (e) {
          }
        }

        playersList.add({
          'id': playerId,
          'name': name,
          'jerseyNumber': jerseyNumber ?? '',
          'position': position ?? '',
          'image': image,
        });
      }

      setState(() {
        if (team == 'A') {
          _teamAPlayers = playersList;
        } else {
          _teamBPlayers = playersList;
        }
        _isLoadingPlayers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPlayers = false;
      });
    }
  }

  String _getTeamName(String team) {
    if (team == 'A') {
      return widget.match.homeTeam;
    } else {
      return widget.match.awayTeam;
    }
  }

  String _getTeamSide(String team) {
    // Try to get side from match data if available
    // For now, we'll use a placeholder - this should be updated when match model includes side info
    return team == 'A' ? 'Offensive' : 'Defensive';
  }

  String _getTeamId(String team) {
    dynamic teamIdData = team == 'A'
        ? widget.match.homeTeamId
        : widget.match.awayTeamId;

    if (teamIdData == null) return '';

    // If it's already a string, return it
    if (teamIdData is String) return teamIdData;

    // If it's a Map (team object), extract _id
    if (teamIdData is Map) {
      return teamIdData['_id']?.toString() ??
          teamIdData['id']?.toString() ??
          '';
    }

    // Fallback: convert to string
    return teamIdData.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Add Game Action',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Select Team Section
                    _buildTeamSelection(),
                    const SizedBox(height: 12),

                    // Action Type Section
                    _buildActionTypeSection(),
                    const SizedBox(height: 12),

                    // Player Selection Section
                    if (_selectedTeam != null) _buildPlayerSelection(),
                  ],
                ),
              ),
            ),

            // Action Buttons - Fixed at bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Team',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTeamButton(
                'A',
                _getTeamName('A'),
                _getTeamSide('A'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTeamButton(
                'B',
                _getTeamName('B'),
                _getTeamSide('B'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamButton(String team, String teamName, String side) {
    final isSelected = _selectedTeam == team;
    final isOffensive = side == 'Offensive';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTeam = team;
          _selectedPlayerId = null; // Reset player selection
        });
        // Load players for selected team
        _loadPlayersForTeam(team);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isOffensive
                    ? const Color(0xFF1E3A5F)
                    : const Color(0xFFF59E0B))
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isOffensive
                      ? const Color(0xFF1E3A5F)
                      : const Color(0xFFF59E0B))
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Team logo placeholder - smaller
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isOffensive ? Colors.red : Colors.yellow,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    teamName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '($side)',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Action Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedActionType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hint: const Text(
                'Select Action Type',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              style: const TextStyle(fontSize: 12, color: Colors.black),
              items: _actionTypes.map((action) {
                return DropdownMenuItem<String>(
                  value: action['type'] as String,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            action['type'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          action['score'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActionType = value;
                  _selectedPlayerId = null; // Reset player selection
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSelection() {
    final players = _selectedTeam == 'A' ? _teamAPlayers : _teamBPlayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Player',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200, // Fixed height instead of Expanded
          child: _isLoadingPlayers
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : players.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No players selected for this team',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please select players in the "Select Players" screen first',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: players.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 0),
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isSelected = _selectedPlayerId == player['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlayerId = player['id'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E3A5F).withValues(alpha: 0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFFE5E7EB),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Player avatar - smaller
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: player['image'] != null
                                  ? ClipOval(
                                      child: Image.network(
                                        player['image'],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    player['jerseyNumber'] != null &&
                                            player['jerseyNumber']
                                                .toString()
                                                .isNotEmpty
                                        ? '#${player['jerseyNumber']} ${player['name'] ?? 'Unknown Player'}'
                                        : player['name'] ?? 'Unknown Player',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF1E3A5F)
                                          : Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (player['position'] != null)
                                    Text(
                                      player['position'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Radio button - smaller
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1E3A5F)
                                      : const Color(0xFFE5E7EB),
                                  width: 2,
                                ),
                                color: isSelected
                                    ? const Color(0xFF1E3A5F)
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed:
              _isLoading ||
                  _selectedTeam == null ||
                  _selectedActionType == null ||
                  _selectedPlayerId == null
              ? null
              : _handleAddAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A5F),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Add Actions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleAddAction() async {
    if (_selectedTeam == null ||
        _selectedActionType == null ||
        _selectedPlayerId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get team ID
      final teamId = _getTeamId(_selectedTeam!);

      if (teamId.isEmpty) {
        throw Exception('Team ID not found');
      }

      // Get backend action type
      final actionTypeMap = _actionTypes.firstWhere(
        (action) => action['type'] == _selectedActionType,
      );
      final backendActionType = actionTypeMap['backendType'] as String;

      // Call the callback
      widget.onAddAction(teamId, _selectedPlayerId!, backendActionType);

      if (mounted) {
        Navigator.of(context).pop();
        // Reset dialog state
        setState(() {
          _selectedTeam = null;
          _selectedActionType = null;
          _selectedPlayerId = null;
          _teamAPlayers = [];
          _teamBPlayers = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game action added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

