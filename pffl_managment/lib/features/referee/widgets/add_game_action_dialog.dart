import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/profile_service.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Add Game Action Dialog
/// Allows referee to add game actions (Touchdown, Extra Points, etc.) to a match
class AddGameActionDialog extends StatefulWidget {
  final MatchModel match;
  final Function(String teamId, String playerId, String actionType) onAddAction;

  const AddGameActionDialog({
    super.key,
    required this.match,
    required this.onAddAction,
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
    {'type': 'Extra Point from 5-yard line', 'score': '+1', 'backendType': 'Extra Point from 5-yard line'},
    {'type': 'Extra Point from 12-yard line', 'score': '+2', 'backendType': 'Extra Point from 12-yard line'},
    {'type': 'Extra Point from 20-yard line', 'score': '+3', 'backendType': 'Extra Point from 20-yard line'},
  ];
  
  // Team A and Team B players
  List<Map<String, dynamic>> _teamAPlayers = [];
  List<Map<String, dynamic>> _teamBPlayers = [];
  
  bool _isLoading = false;
  bool _isLoadingPlayers = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadPlayersForTeam(String team) async {
    if (widget.match.id == null) return;
    
    setState(() {
      _isLoadingPlayers = true;
    });

    try {
      // Get authenticated Dio instance
      final dio = await AuthService.getWorkingDio();
      final response = await dio.get('/match/${widget.match.id}');
      
      if (response.statusCode == 200) {
        final matchData = response.data['data'] as Map<String, dynamic>;
        final teamData = team == 'A' 
            ? matchData['teamA'] as Map<String, dynamic>?
            : matchData['teamB'] as Map<String, dynamic>?;
        
        if (teamData != null) {
          final playersArray = teamData['players'] as List<dynamic>? ?? [];
          
          // Filter active players
          final activePlayers = playersArray.where((p) {
            return p['isActive'] == true;
          }).toList();
          
          // Fetch player profiles
          final playersList = <Map<String, dynamic>>[];
          for (var playerObj in activePlayers) {
            final playerIdValue = playerObj['playerId'];
            String playerId;
            String firstName = '';
            String lastName = '';
            String email = '';
            
            if (playerIdValue is String) {
              playerId = playerIdValue;
            } else if (playerIdValue is Map) {
              playerId = playerIdValue['_id']?.toString() ?? '';
              firstName = playerIdValue['firstName'] ?? '';
              lastName = playerIdValue['lastName'] ?? '';
              email = playerIdValue['email'] ?? '';
            } else {
              continue;
            }
            
            // Fetch profile for jersey number and position
            String? jerseyNumber;
            String? position;
            String? image;
            
            try {
              final profile = await ProfileService.getProfile(playerId);
              if (profile != null) {
                jerseyNumber = profile['jerseyNumber']?.toString();
                position = profile['position']?.toString();
                image = profile['image']?.toString();
              }
            } catch (e) {
              print('Error fetching profile for $playerId: $e');
            }
            
            playersList.add({
              'id': playerId,
              'name': firstName.isNotEmpty && lastName.isNotEmpty
                  ? '$firstName $lastName'
                  : email.isNotEmpty ? email : 'Player $playerId',
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
        }
      }
    } catch (e) {
      print('Error loading players: $e');
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
    return team == 'A' 
        ? (widget.match.homeTeamId ?? '')
        : (widget.match.awayTeamId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Add Game Action',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Select Team Section
            _buildTeamSelection(),
            const SizedBox(height: 24),
            
            // Action Type Section
            _buildActionTypeSection(),
            const SizedBox(height: 24),
            
            // Player Selection Section
            if (_selectedTeam != null && _selectedActionType != null)
              SizedBox(
                height: 300,
                child: _buildPlayerSelection(),
              ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTeamButton('A', _getTeamName('A'), _getTeamSide('A')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTeamButton('B', _getTeamName('B'), _getTeamSide('B')),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isOffensive ? const Color(0xFF1E3A5F) : const Color(0xFFF59E0B))
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? (isOffensive ? const Color(0xFF1E3A5F) : const Color(0xFFF59E0B))
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Team logo placeholder
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isOffensive ? Colors.red : Colors.yellow,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '($side)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hint: const Text(
                'Select Action Type',
                style: TextStyle(color: Colors.grey),
              ),
              items: _actionTypes.map((action) {
                return DropdownMenuItem<String>(
                  value: action['type'] as String,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        action['type'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        action['score'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                    ],
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _isLoadingPlayers
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : players.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'No active players available for this team',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: players.length,
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
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF1E3A5F)
                                    : const Color(0xFFE5E7EB),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Player avatar
                                Container(
                                  width: 40,
                                  height: 40,
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
                                      : const Icon(Icons.person, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player['jerseyNumber'] != null && player['jerseyNumber'].toString().isNotEmpty
                                            ? '#${player['jerseyNumber']} ${player['name'] ?? 'Unknown Player'}'
                                            : player['name'] ?? 'Unknown Player',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (player['position'] != null)
                                        Text(
                                          'Position: ${player['position']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Radio button
                                Radio<String>(
                                  value: player['id'],
                                  groupValue: _selectedPlayerId,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPlayerId = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF1E3A5F),
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
          onPressed: _isLoading || _selectedTeam == null || 
                    _selectedActionType == null || _selectedPlayerId == null
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
    if (_selectedTeam == null || _selectedActionType == null || _selectedPlayerId == null) {
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
