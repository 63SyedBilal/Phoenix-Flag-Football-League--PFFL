import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:provider/provider.dart';

class LeagueLeaderboardSection extends StatelessWidget {
  const LeagueLeaderboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeagueDetailProvider>();
    final standings = provider.getLeaderboard();
    if (standings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Leaderboard',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Color(0xff0F173E),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lato',
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  provider.selectTab(2);
                },
                child: Row(
                  children: [
                    Text(
                      'View Leaderboard',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Color(0xff0F173E),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 8.72,
                      color: Color(0xff0F173E),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.25),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Column(
                  children: [
                    // Header row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xffe3ecfb), // Light gray background
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6.25),
                          topRight: Radius.circular(6.25),
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
                              'PD',
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
                            width: 40,
                            child: Text(
                              'PTS',
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
                    // Team rows
                    ...standings.map(
                      (standing) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(
                                0xFFE5E7EB,
                              ).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${standing.rank.toString().padLeft(2, '0')}',
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
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200],
                                    ),
                                    child: ClipOval(
                                      child: standing.teamLogo.isNotEmpty
                                          ? Image.network(
                                              standing.teamLogo,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.group,
                                                    size: 14,
                                                  ),
                                            )
                                          : const Icon(Icons.group, size: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      standing.teamName,
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
                                standing.wins.toString(),
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
                                standing.draws.toString(),
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
                                standing.losses.toString(),
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
                                standing.pointsDifference.toString(),
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
                                standing.pointsScored.toString(),
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
                                standing.pointsAgainst.toString(),
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
                              width: 40,
                              child: Text(
                                ((standing.wins * 3) + standing.draws)
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
