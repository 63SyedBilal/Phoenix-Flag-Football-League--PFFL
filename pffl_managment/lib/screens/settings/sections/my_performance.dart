import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/performance_provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';

/// My Performance section screen (Player only)
/// Displays comprehensive player performance statistics and metrics
class MyPerformanceScreen extends StatefulWidget {
  const MyPerformanceScreen({Key? key}) : super(key: key);

  @override
  State<MyPerformanceScreen> createState() => _MyPerformanceScreenState();
}

class _MyPerformanceScreenState extends State<MyPerformanceScreen> {
  @override
  void initState() {
    super.initState();
    // Load performance data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerformanceProvider>().loadPerformance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const ArrowBackButton(),
        title: const Text(
          'My Performance',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PerformanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to Load Performance',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.loadPerformance(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final performance = provider.performance;
          if (performance == null) {
            return const Center(
              child: Text(
                'No performance data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Performance Grade Card
                _buildGradeCard(provider),

                const SizedBox(height: 24),

                // Game Statistics
                _buildStatsSection(
                  'Game Statistics',
                  [
                    _buildStatItem('Games Played', performance.gamesPlayed.toString(), Icons.sports_soccer),
                    _buildStatItem('Wins', performance.wins.toString(), Icons.emoji_events, color: const Color(0xFF10B981)),
                    _buildStatItem('Losses', performance.losses.toString(), Icons.cancel, color: const Color(0xFFEF4444)),
                    _buildStatItem('Win Rate', '${provider.winPercentage.toStringAsFixed(1)}%', Icons.trending_up),
                  ],
                ),

                const SizedBox(height: 24),

                // Offensive Statistics
                _buildStatsSection(
                  'Offensive Statistics',
                  [
                    _buildStatItem('Touchdowns', performance.touchdowns.toString(), Icons.sports_football),
                    _buildStatItem('Catches', performance.catches.toString(), Icons.sports_handball),
                    _buildStatItem('Rushes', performance.rushes.toString(), Icons.directions_run),
                    _buildStatItem('Yards Gained', '${performance.yardsGained.toStringAsFixed(1)} yd', Icons.straighten),
                    _buildStatItem('Flag Pulls', performance.flagPulls.toString(), Icons.flag),
                  ],
                ),

                const SizedBox(height: 24),

                // Passing Statistics
                _buildStatsSection(
                  'Passing Statistics',
                  [
                    _buildStatItem('Pass Attempts', performance.passAttempts.toString(), Icons.send),
                    _buildStatItem('Completions', performance.completions.toString(), Icons.check_circle),
                    _buildStatItem('Completion %', '${performance.completionPercentage.toStringAsFixed(1)}%', Icons.percent),
                  ],
                ),

                const SizedBox(height: 24),

                // Special Teams & Defense
                _buildStatsSection(
                  'Special Teams & Defense',
                  [
                    _buildStatItem('Safety', performance.safety.toString(), Icons.shield),
                    _buildStatItem('Conversion Points', performance.conversionPoints.toString(), Icons.star),
                    _buildStatItem('Avg Points/Game', performance.averagePointsPerGame.toStringAsFixed(1), Icons.show_chart),
                  ],
                ),

                const SizedBox(height: 24),

                // Rankings & Position
                _buildStatsSection(
                  'Rankings & Position',
                  [
                    _buildStatItem('Current Ranking', '#${performance.ranking}', Icons.leaderboard),
                    _buildStatItem('Best Position', performance.bestPosition, Icons.person),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradeCard(PerformanceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Grade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Overall Rating',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  provider.performanceGrade,
                  style: TextStyle(
                    color: provider.gradeColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: provider.performance?.averagePointsPerGame != null
                ? (provider.performance!.averagePointsPerGame / 10).clamp(0.0, 1.0)
                : 0.0,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.performance?.averagePointsPerGame.toStringAsFixed(1) ?? '0.0'} pts/game average',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String title, List<Widget> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...stats,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFF3B82F6)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color ?? const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
