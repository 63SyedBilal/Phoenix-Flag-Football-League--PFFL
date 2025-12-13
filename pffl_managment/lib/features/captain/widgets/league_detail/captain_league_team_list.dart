import 'package:flutter/material.dart';
import 'package:pffl_managment/features/captain/providers/captain_league_detail_provider.dart';
import 'package:provider/provider.dart';

class CaptainLeagueTeamList extends StatelessWidget {
  const CaptainLeagueTeamList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptainLeagueDetailProvider>(
      builder: (context, provider, child) {
        // For now, we'll create mock data since we don't have a method in the provider
        final teams = [
          {
            'id': '1',
            'name': 'My Team',
            'players': [
              {'name': 'John Smith', 'position': 'Quarterback'},
              {'name': 'Mike Johnson', 'position': 'Rusher'},
              {'name': 'Sarah Williams', 'position': 'Blocker'},
            ],
          },
          {
            'id': '2',
            'name': 'Iron Rangers',
            'players': [
              {'name': 'David Brown', 'position': 'Quarterback'},
              {'name': 'Lisa Garcia', 'position': 'Rusher'},
            ],
          },
        ];
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teams',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (teams.isEmpty)
                const Center(
                  child: Text(
                    'No teams data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Column(
                  children: teams.map((team) {
                    final isMyTeam = team['name'] == 'My Team';
                    return _buildTeamCard(context, team, isMyTeam, provider);
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamCard(BuildContext context, dynamic team, bool isMyTeam, CaptainLeagueDetailProvider provider) {
    final isExpanded = provider.isTeamExpanded(team['id']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => provider.toggleTeamExpansion(team['id']),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMyTeam ? const Color(0xFFDBEAFE) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isMyTeam ? const Color(0xFF3B82F6) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        team['name'].toString().substring(0, 1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isMyTeam ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      team['name'].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isMyTeam ? FontWeight.bold : FontWeight.normal,
                        color: isMyTeam ? const Color(0xFF3B82F6) : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Player',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Position',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List<Widget>.generate(
                    (team['players'] as List).length,
                    (index) {
                      final player = (team['players'] as List)[index];
                      return _buildPlayerRow(player);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(dynamic player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              player['name'],
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              player['position'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}