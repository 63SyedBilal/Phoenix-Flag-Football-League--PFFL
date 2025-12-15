import 'package:flutter/material.dart';

class PlayersTab extends StatelessWidget {
  const PlayersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTeamSection(
                    'Blaze Squad',
                    [
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Resting'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Resting'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Resting'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTeamSection(
                    'Shadow Wolves',
                    [
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                      _PlayerData('#05', 'James Richardson', 'Center', 'Active'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(String teamName, List<_PlayerData> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            teamName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
        ),
        ...players.map((player) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildPlayerCard(player),
        )),
      ],
    );
  }

  Widget _buildPlayerCard(_PlayerData player) {
    final isActive = player.status == 'Active';
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF9CA3AF),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${player.number} ${player.name}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Position: ${player.position}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive 
                ? const Color(0xFF1E293B) 
                : const Color(0xFF9CA3AF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            player.status,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
   
}

class _PlayerData {
  final String number;
  final String name;
  final String position;
  final String status;

  _PlayerData(this.number, this.name, this.position, this.status);
}