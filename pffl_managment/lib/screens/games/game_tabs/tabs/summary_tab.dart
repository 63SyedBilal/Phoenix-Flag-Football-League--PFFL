import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pffl_managment/features/key_players/league_key_players_section.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_tabs_provider.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameTabsProvider>(context);
    final match = provider.match;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Game Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),

          _buildPerformanceCard(match.homeTeamLogo, match.awayTeamLogo),

          const SizedBox(height: 24),

          // Actions Section
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionsTimeline(),

          const SizedBox(height: 24),

          // Game Information
          const Text(
            'Game Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildGameInfoCard(match),

          const SizedBox(height: 24),

          // Upcoming Games Header
          _buildSectionHeader('Upcoming Games', 'View More', () {}),
          const SizedBox(height: 16),
          // RC Match Card
          _buildMatchCard("RC", "STA", "08/11", "04:05 AM PKT"),
          const SizedBox(height: 12),
          // STA Match Card
          _buildMatchCard("STA", "RC", "08/11", "04:05 AM PKT"),
          const SizedBox(height: 24),

        SponsorBannerScreen(),

          _FilteredLeaderboardSection(selectedTeam: _getSelectedTeam(provider.selectedTabIndex)),
          const SizedBox(height: 12),
          LeagueKeyPlayersSection(),
         SizedBox(height: 24),
          SponsorBannerScreen(),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(String homeLogo, String awayLogo) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTeamLogo(homeLogo),
            const Text(
              'Team Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
                color: Color(0xFF111827),
              ),
            ),
            _buildTeamLogo(awayLogo),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatRow('10', 'Catches', '14'),
        _buildStatRow('230', 'Catches Yards', '235'),
        _buildStatRow('8', 'Rushes', '8'),
        _buildStatRow('150', 'Rush Yards', '155'),
        _buildStatRow('20', 'Pass Attempts', '25'),
        _buildStatRow('8', 'Completions', '15'),
        _buildStatRow('4', 'Touchdowns', '11'),
        _buildStatRow('20', 'Flag Pulls', '28'),
        _buildStatRow('1', 'Safety', '0'),
        _buildStatRow('9', 'Conversion Points', '11'),
      ],
    );
  }

  Widget _buildStatRow(String val1, String label, String val2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              val1,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              fontFamily: 'Lato',
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              val2,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String url) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) =>
              Icon(Icons.shield, size: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildActionsTimeline() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 20,
          bottom: 20,
          child: Center(
            child: Container(width: 2, color: const Color(0xFFE5E7EB)),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionItem(
              "#17 - Michael Lee",
              "Slot Receiver",
              Icons.shield,
              "Half Time",
              true,
            ),
            _buildActionItem(
              "#17 - Michael Lee",
              "Slot Receiver",
              Icons.shield,
              "",
              true,
            ), // Icon only?
            _buildActionItem(
              "#17 - Michael Lee",
              "Slot Receiver",
              Icons.gps_fixed,
              "",
              true,
            ),
            _buildActionItem(
              "#10 - John Carter",
              "Slot Receiver",
              Icons.warning_amber_rounded,
              "Warning",
              false,
              color: Colors.amber,
            ),
            _buildActionItem(
              "#10 - John Carter",
              "Slot Receiver",
              Icons.sports_football,
              "Start",
              false,
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "View more",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String name,
    String role,
    IconData icon,
    String label,
    bool isLeft, {
    Color color = const Color(0xFF1F2937),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: isLeft
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato',
                        ),
                      ),
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 12),
        // ... existing code ...
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              if (label.isNotEmpty)
                               Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lato',
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                ),

            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: !isLeft
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato',
                        ),
                      ),
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoCard(match) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Game No 2: BS vs STA | League: Phoenix Winter 2025",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Format: 5v5 | Venue: Phoenix Turf Arena - Field 3",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Date: 12 January 2025 | Time: 6:30 PM",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Toss: BS won the toss and will play defense first.",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Color(0xFF111827),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                actionText,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Lato',
                  color: Color(0xFF4B5563),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFF4B5563),
              ),
            ],
          ),
        ),
      ],
    );
  }




  Widget _buildMatchCard(String team1, String team2, String date, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: const ClipOval(
                        child: ColoredBox(
                          color: Color(0xFFF3F4F6),
                          child: Icon(
                            Icons.sports_football,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      team1,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 10,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      team2,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: const ClipOval(
                        child: ColoredBox(
                          color: Color(0xFFF3F4F6),
                          child: Icon(
                            Icons.sports_football,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Game',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 12,
                height: 12,
                decoration:  BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSelectedTeam(int tabIndex) {
    // Based on the tab structure in game_details_screen.dart:
    // 0: Summary, 1: Leaderboard, 2: Players, 3: Officials
    // For now, we'll return an empty string to show all teams
    // In a more advanced implementation, you could map specific tabs to teams
    return '';
  }

  Widget _FilteredLeaderboardSection({required String selectedTeam}) {
    // This is a simplified version that shows only 2 lines for the selected team
    // In a real implementation, this would filter the actual leaderboard data
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Leaderboard', style: TextStyle(fontFamily: 'Lato', fontSize: 16)),
            const Spacer(),
            Text(
              'View Leaderboard',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 10,
                color: Color(0xff0F173E),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Color(0xff0F173E),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Header row with all columns
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xffe3ecfb),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 40,
                          child: Text(
                            'Rank',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 120,
                          child: Text(
                            'Team',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 30,
                          child: Text(
                            'W',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 30,
                          child: Text(
                            'D',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 30,
                          child: Text(
                            'L',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 30,
                          child: Text(
                            'OD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 30,
                          child: Text(
                            'PS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 30,
                          child: Text(
                            'PA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 30,
                          child: Text(
                            'PTA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Team rows - showing only 2 lines as requested
                  if (selectedTeam.isEmpty || selectedTeam == 'RC')
                    _buildLeaderboardRowFull('01', 'RC', '6', '0', '0', '0', '0', '0', '0'),
                  if (selectedTeam.isEmpty || selectedTeam == 'STA')
                    _buildLeaderboardRowFull('02', 'STA', '4', '0', '2', '0', '0', '0', '0'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRowFull(String rank, String team, String wins, String draws, String losses, String od, String ps, String pa, String pta) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              rank,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    team,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              wins,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              draws,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              losses,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              od,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              ps,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              pa,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              pta,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
