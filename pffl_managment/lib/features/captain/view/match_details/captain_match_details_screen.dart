import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/features/captain/providers/captain_match_provider.dart';
import 'package:provider/provider.dart';

class CaptainMatchDetailsScreen extends StatelessWidget {
  const CaptainMatchDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ScoreHeader(),
            const SizedBox(height: 24),
            const _MatchTabs(),
            const SizedBox(height: 24),
            Consumer<CaptainMatchProvider>(
              builder: (context, provider, child) {
                return const _GameSummary();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TeamLogoName(name: 'BS', logo: 'assets/images/team_logo_1.png'),
        Row(
          children: [
            Text(
              '30',
              style: AppTextStyles.displayMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '\\',
                style: AppTextStyles.displayMedium.copyWith(color: Colors.grey),
              ),
            ),
            Text(
              '27',
              style: AppTextStyles.displayMedium.copyWith(color: Colors.grey),
            ),
          ],
        ),
        _TeamLogoName(
          name: 'STA',
          logo: 'assets/images/team_logo_2.png',
          isRightAligned: true,
        ), // Replace with actual asset
      ],
    );
  }
}

class _TeamLogoName extends StatelessWidget {
  final String name;
  final String logo;
  final bool isRightAligned;

  const _TeamLogoName({
    required this.name,
    required this.logo,
    this.isRightAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isRightAligned) ...[
          _Logo(logo),
          const SizedBox(width: 8),
          Text(
            name,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        if (isRightAligned) ...[
          Text(
            name,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          _Logo(logo),
        ],
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  final String logo;
  const _Logo(this.logo);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: const Icon(Icons.shield, color: Colors.red), // Placeholder
    );
  }
}

class _MatchTabs extends StatelessWidget {
  const _MatchTabs();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TabButton(label: 'Summary', isSelected: true),
          _TabButton(label: 'Leaderboard'),
          _TabButton(label: 'Players'),
          _TabButton(label: 'Officials'),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TabButton({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isSelected
                ? BorderSide.none
                : const BorderSide(color: Colors.grey, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(label),
      ),
    );
  }
}

class _GameSummary extends StatelessWidget {
  const _GameSummary();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Summary',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const _TeamPerformance(),
        const SizedBox(height: 24),
        const _Actions(),
        const SizedBox(height: 24),
        const _GameInformation(),
        const SizedBox(height: 24),
        const _UpcomingGames(),
        const SizedBox(height: 24),
        const _Leaderboard(),
        const SizedBox(height: 24),
        const _KeyPlayers(),
      ],
    );
  }
}

class _TeamPerformance extends StatelessWidget {
  const _TeamPerformance();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.shield, color: Colors.red), // Placeholder
            Text('Team Performance', style: AppTextStyles.bodyLarge),
            const Icon(Icons.shield, color: Colors.yellow), // Placeholder
          ],
        ),
        const SizedBox(height: 16),
        _StatRow(label: 'Catches', leftValue: '10', rightValue: '14'),
        _StatRow(label: 'Catches Yards', leftValue: '230', rightValue: '235'),
        _StatRow(label: 'Rushes', leftValue: '8', rightValue: '8'),
        _StatRow(label: 'Rush Yards', leftValue: '150', rightValue: '155'),
        _StatRow(label: 'Pass Attempts', leftValue: '20', rightValue: '25'),
        _StatRow(label: 'Completions', leftValue: '8', rightValue: '15'),
        _StatRow(label: 'Touchdowns', leftValue: '4', rightValue: '11'),
        _StatRow(label: 'Flag Pulls', leftValue: '20', rightValue: '28'),
        _StatRow(label: 'Safety', leftValue: '1', rightValue: '0'),
        _StatRow(label: 'Conversion Points', leftValue: '9', rightValue: '11'),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String leftValue;
  final String rightValue;

  const _StatRow({
    required this.label,
    required this.leftValue,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(leftValue, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(rightValue, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const _Timeline(),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineEventRow(
          name: '#17 - Michael Lee',
          role: 'Slot Receiver',
          icon: Icons.shield,
          iconColor: const Color(0xFF1E3A5F),
        ),
        const _TimelineCenterText(text: 'Half Time'),
        _TimelineEventRow(
          name: '#17 - Michael Lee',
          role: 'Slot Receiver',
          icon: Icons.shield,
          iconColor: const Color(0xFF1E3A5F),
        ),
        _TimelineEventRow(
          name: '#17 - Michael Lee',
          role: 'Slot Receiver',
          icon: Icons.sync,
          iconColor: const Color(0xFF1E3A5F),
        ),
        _TimelineEventRow(
          name: '#10 - John Carter',
          role: 'Slot Receiver',
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFFFC107),
        ),
        _TimelineEventRow(
          name: '#10 - John Carter',
          role: 'Slot Receiver',
          icon: Icons.shield,
          iconColor: const Color(0xFF1E3A5F),
        ),
        const _TimelineCenterText(text: 'Start'),
      ],
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  final String name;
  final String role;
  final IconData icon;
  final Color iconColor;

  const _TimelineEventRow({
    required this.name,
    required this.role,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Left side - Player info (always on left)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          // Right side - Icon (always on right)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _TimelineCenterText extends StatelessWidget {
  final String text;

  const _TimelineCenterText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _GameInformation extends StatelessWidget {
  const _GameInformation();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Information',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Game No 2: BS vs STA  |  League: Phoenix Winter 2025'),
        const Text('Format: 5v5  |  Venue: Phoenix Turf Arena - Field 3'),
        const Text('Date: 12 January 2025  |  Time: 6:30 PM'),
        const Text('Toss: BS won the toss and will play offense first.'),
      ],
    );
  }
}

class _UpcomingGames extends StatelessWidget {
  const _UpcomingGames();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Games',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View More >')),
          ],
        ),
        const SizedBox(height: 8),
        _UpcomingGameCard(
          home: 'BS',
          away: 'STB',
          time: 'Tomorrow\n01:05 AM PKT',
        ),
        const SizedBox(height: 8),
        _UpcomingGameCard(
          home: 'GEO',
          away: 'STA',
          time: '06/11\n10:05 AM PKT',
        ),
        const SizedBox(height: 16),
        // Banner placeholder
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'KFC Banner Placeholder',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingGameCard extends StatelessWidget {
  final String home;
  final String away;
  final String time;

  const _UpcomingGameCard({
    required this.home,
    required this.away,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.red),
              const SizedBox(width: 8),
              Text(home, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.blue),
              const SizedBox(width: 8),
              Text(away, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Leaderboard',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View Leaderboard >'),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(flex: 1, child: Text('Rank')),
                  Expanded(flex: 4, child: Text('Team')),
                  Expanded(flex: 1, child: Text('W')),
                  Expanded(flex: 1, child: Text('D')),
                  Expanded(flex: 1, child: Text('L')),
                ],
              ),
              const Divider(),
              _LeaderboardRow(
                rank: '01',
                team: 'Shadow Wolves',
                w: '6',
                d: '0',
                l: '0',
              ),
              _LeaderboardRow(
                rank: '04',
                team: 'Blaze Squad',
                w: '0',
                d: '0',
                l: '6',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final String rank;
  final String team;
  final String w;
  final String d;
  final String l;

  const _LeaderboardRow({
    required this.rank,
    required this.team,
    required this.w,
    required this.d,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(rank)),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                const Icon(Icons.shield, size: 16),
                const SizedBox(width: 4),
                Text(team),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(w)),
          Expanded(flex: 1, child: Text(d)),
          Expanded(flex: 1, child: Text(l)),
        ],
      ),
    );
  }
}

class _KeyPlayers extends StatelessWidget {
  const _KeyPlayers();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Players',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PlayerCard(
                name: 'Andrew\nBrooks',
                tds: '12',
                color: const Color(0xFF1E2A44),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PlayerCard(
                name: 'Malik\nCarter',
                tds: '09',
                color: const Color(0xFF000000),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Banner placeholder
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'KFC Banner Placeholder',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String name;
  final String tds;
  final Color color;

  const _PlayerCard({
    required this.name,
    required this.tds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: tds,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ' TDs',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Placeholder for player image
          const CircleAvatar(backgroundColor: Colors.grey, radius: 20),
        ],
      ),
    );
  }
}
