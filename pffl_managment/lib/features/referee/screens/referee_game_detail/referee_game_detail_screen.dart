import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/referee/providers/referee_game_detail_provider.dart';

/// Referee Game Detail Screen
/// Shows game details with tabs and FAB actions
class RefereeGameDetailScreen extends StatelessWidget {
  final MatchModel match;

  const RefereeGameDetailScreen({
    super.key,
    required this.match,
  });

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
          appBar: _buildAppBar(context, provider),
          body: Stack(
            children: [
              Column(
                children: [
                  // Game Section
                  _buildGameSection(provider),
                  
                  // Tabs
                  _buildTabs(provider),
                  
                  // Tab Content
                  Expanded(
                    child: _buildTabContent(provider),
                  ),
                ],
              ),
              
              // FAB overlay when expanded
              if (provider.isFabExpanded)
                _buildFabOverlay(context, provider),
            ],
          ),
          floatingActionButton: _buildFab(context, provider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    RefereeGameDetailProvider provider,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'forfeit',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Forfeit Game',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'forfeit') {
              _showForfeitDialog(context, provider);
            }
          },
        ),
      ],
    );
  }

  Widget _buildGameSection(RefereeGameDetailProvider provider) {
    final match = provider.match;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Home Team
          _buildTeamInfo(
            logoPath: match?.homeTeamLogo ?? '',
            teamName: match?.homeTeam ?? 'BS',
            isHome: true,
          ),
          
          const SizedBox(width: 24),
          
          // Score
          Text(
            '${match?.homeScore ?? 0} \\ ${match?.awayScore ?? 0}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Away Team
          _buildTeamInfo(
            logoPath: match?.awayTeamLogo ?? '',
            teamName: match?.awayTeam ?? 'A',
            isHome: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo({
    required String logoPath,
    required String teamName,
    required bool isHome,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          child: ClipOval(
            child: logoPath.isNotEmpty && logoPath.startsWith('http')
                ? Image.network(
                    logoPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultLogo(teamName),
                  )
                : _buildDefaultLogo(teamName),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          teamName.length > 3 ? teamName.substring(0, 3).toUpperCase() : teamName.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo(String teamName) {
    return Container(
      color: const Color(0xFFB91C1C),
      child: Center(
        child: Text(
          teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(RefereeGameDetailProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTabButton(
            label: 'Game actions',
            isSelected: provider.selectedTabIndex == 0,
            onTap: () => provider.setSelectedTab(0),
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            label: 'Mark Attendance',
            isSelected: provider.selectedTabIndex == 1,
            onTap: () => provider.setSelectedTab(1),
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            label: 'Select Players',
            isSelected: provider.selectedTabIndex == 2,
            onTap: () => provider.setSelectedTab(2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(RefereeGameDetailProvider provider) {
    switch (provider.selectedTabIndex) {
      case 0:
        return _buildGameActionsTab(provider);
      case 1:
        return _buildMarkAttendanceTab(provider);
      case 2:
        return _buildSelectPlayersTab(provider);
      default:
        return _buildGameActionsTab(provider);
    }
  }

  Widget _buildGameActionsTab(RefereeGameDetailProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Actions header
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // Add action button
        Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.black54,
              size: 20,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action history list
        if (provider.gameActions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.sports_score_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    'No actions recorded yet',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          ...provider.gameActions.map((action) => _buildActionItem(action)),
      ],
    );
  }

  Widget _buildActionItem(Map<String, dynamic> action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A5F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  action['description'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAttendanceTab(RefereeGameDetailProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Mark Attendance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text(
                  'No players to mark attendance',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectPlayersTab(RefereeGameDetailProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Select Players',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.person_add_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text(
                  'No players to select',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOverlay(BuildContext context, RefereeGameDetailProvider provider) {
    return GestureDetector(
      onTap: provider.closeFab,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Game Complete
                _buildFabOption(
                  label: 'Game Complete',
                  icon: Icons.check_circle,
                  color: const Color(0xFF1E3A5F),
                  isCompleted: provider.isGameComplete,
                  onTap: () => provider.executeAction(GameAction.gameComplete),
                ),
                const SizedBox(height: 8),
                
                // Over Time
                _buildFabOption(
                  label: 'Over Time',
                  icon: Icons.access_time_filled,
                  color: const Color(0xFFEA580C),
                  isCompleted: provider.isOverTime,
                  onTap: () => provider.executeAction(GameAction.overTime),
                ),
                const SizedBox(height: 8),
                
                // Full Time Done
                _buildFabOption(
                  label: 'Full Time Done',
                  icon: Icons.check,
                  color: const Color(0xFF1E3A5F),
                  isCompleted: provider.isFullTimeDone,
                  onTap: () => provider.executeAction(GameAction.fullTimeDone),
                ),
                const SizedBox(height: 8),
                
                // Half Time Done
                _buildFabOption(
                  label: 'Half Time Done',
                  icon: Icons.check,
                  color: const Color(0xFFEA580C),
                  isCompleted: provider.isHalfTimeDone,
                  onTap: () => provider.executeAction(GameAction.halfTimeDone),
                ),
                const SizedBox(height: 8),
                
                // Toss
                _buildFabOption(
                  label: 'Toss',
                  icon: Icons.sports_football,
                  color: const Color(0xFF1E3A5F),
                  isCompleted: provider.isTossCompleted,
                  onTap: () => provider.executeAction(GameAction.toss),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFabOption({
    required String label,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCompleted ? color.withOpacity(0.7) : color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showForfeitDialog(BuildContext context, RefereeGameDetailProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forfeit Game'),
        content: const Text('Are you sure you want to forfeit this game? This action cannot be undone.'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Forfeit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

