import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/referee/providers/referee_game_detail_provider.dart';
import 'package:pffl_managment/features/captain/model/player_model.dart';

/// Mark Attendance screen for referees
/// Allows marking which players are present for the match
class MarkAttendanceScreen extends StatefulWidget {
  final MatchModel match;

  const MarkAttendanceScreen({
    super.key,
    required this.match,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    
    // Set default team selection after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RefereeGameDetailProvider>(context, listen: false);
      
      // Select first team (home team) by default if not already selected
      if (provider.selectedAttendanceTeamId == null) {
        final defaultTeamId = _extractTeamId(widget.match.homeTeamId);
        if (defaultTeamId.isNotEmpty) {
          provider.setAttendanceTeam(defaultTeamId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefereeGameDetailProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Select Team heading
                  const Text(
                    'Select Team',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Team selection buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildTeamButton(
                          context,
                          provider,
                          teamId: _extractTeamId(widget.match.homeTeamId),
                          teamName: widget.match.homeTeam,
                          teamLogo: widget.match.homeTeamLogo,
                          teamColor: null,
                          isSelected: provider.selectedAttendanceTeamId == _extractTeamId(widget.match.homeTeamId),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTeamButton(
                          context,
                          provider,
                          teamId: _extractTeamId(widget.match.awayTeamId),
                          teamName: widget.match.awayTeam,
                          teamLogo: widget.match.awayTeamLogo,
                          teamColor: null,
                          isSelected: provider.selectedAttendanceTeamId == _extractTeamId(widget.match.awayTeamId),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Player list
                  if (provider.selectedAttendanceTeamId != null)
                    _buildPlayerList(context, provider)
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Text(
                              'Select a team to mark attendance',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Confirm button at bottom - always visible
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading 
                      ? null 
                      : () => _confirmAttendance(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirm Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _confirmAttendance(BuildContext context, RefereeGameDetailProvider provider) async {
    // Get attendance count
    final presentCount = provider.playerAttendance.values.where((v) => v == true).length;
    
    if (presentCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark at least one player as present'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance marked for $presentCount player(s)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTeamButton(
    BuildContext context,
    RefereeGameDetailProvider provider, {
    required String teamId,
    required String teamName,
    String? teamLogo,
    String? teamColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        // Fetch players for the selected team
        await provider.setAttendanceTeam(teamId);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Team logo or color indicator
            if (teamLogo != null && teamLogo.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  teamLogo,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildColorIndicator(teamColor, isSelected);
                  },
                ),
              )
            else
              _buildColorIndicator(teamColor, isSelected),
            
            const SizedBox(width: 8),
            
            // Team name
            Flexible(
              child: Text(
                teamName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorIndicator(String? teamColor, bool isSelected) {
    Color color;
    try {
      if (teamColor != null && teamColor.isNotEmpty) {
        // Remove # if present
        final colorHex = teamColor.replaceAll('#', '');
        color = Color(int.parse('FF$colorHex', radix: 16));
      } else {
        color = isSelected ? Colors.white : Colors.grey;
      }
    } catch (e) {
      color = isSelected ? Colors.white : Colors.grey;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.grey[300]!,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildPlayerList(BuildContext context, RefereeGameDetailProvider provider) {
    final selectedTeamId = provider.selectedAttendanceTeamId;
    
    if (selectedTeamId == null) {
      return const SizedBox.shrink();
    }
    
    // Show loading indicator while fetching players
    if (provider.isLoadingPlayers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Get players for the selected team from provider
    final List<PlayerModel> players = provider.getTeamPlayers(selectedTeamId);
    
    if (players.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'No players found for this team',
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: [
        // Header row with title and add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mark Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () {
                // Mark all as present
                for (var player in players) {
                  provider.markAttendance(player.id, true);
                }
              },
              tooltip: 'Mark all as present',
              icon: const Icon(Icons.done_all),
              color: Colors.green,
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Player list
        ...players.map((player) {
          final playerId = player.id;
          final isPresent = provider.isPlayerPresent(playerId);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                // Player avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: player.imageUrl != null && player.imageUrl!.isNotEmpty
                      ? Image.network(
                          player.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                      : _buildDefaultAvatar(),
                ),
                
                const SizedBox(width: 12),
                
                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${player.number} ${player.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Position: ${player.position}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Attendance buttons
                Row(
                  children: [
                    // Absent button
                    GestureDetector(
                      onTap: () => provider.markAttendance(playerId, false),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: !isPresent ? Colors.red[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !isPresent ? Colors.red : Colors.grey[300]!,
                            width: !isPresent ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          color: !isPresent ? Colors.red : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Present button
                    GestureDetector(
                      onTap: () => provider.markAttendance(playerId, true),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPresent ? Colors.green[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPresent ? Colors.green : Colors.grey[300]!,
                            width: isPresent ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          color: isPresent ? Colors.green : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  /// Extract team ID from team object or string
  String _extractTeamId(dynamic teamData) {
    if (teamData == null) return '';
    
    // If it's already a string, return it
    if (teamData is String) return teamData;
    
    // If it's a Map (team object), extract _id
    if (teamData is Map) {
      return teamData['_id']?.toString() ?? teamData['id']?.toString() ?? '';
    }
    
    // Fallback: convert to string
    return teamData.toString();
  }
}
