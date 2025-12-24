import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class LeagueSelectionScreen extends StatefulWidget {
  const LeagueSelectionScreen({super.key});

  @override
  State<LeagueSelectionScreen> createState() => _LeagueSelectionScreenState();
}

class _LeagueSelectionScreenState extends State<LeagueSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FreeAgentOnboardingProvider>(
        context,
        listen: false,
      ).fetchActiveLeagues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ArrowBackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<FreeAgentOnboardingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get Ready for\nUpcoming Leagues!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select upcoming leagues and pay in advance to confirm your spot.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Select League',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: provider.availableLeagues.isEmpty
                        ? const Center(
                            child: Text('No active leagues available.'),
                          )
                        : ListView.builder(
                            itemCount: provider.availableLeagues.length,
                            itemBuilder: (context, index) {
                              final league = provider.availableLeagues[index];
                              return _LeagueCard(
                                league: league,
                                isSelected:
                                    provider.selectedLeague?.id == league.id,
                                onSelect: () => provider.selectLeague(league),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: provider.selectedLeague != null
                        ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.freeAgentPaymentOption,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                    ),
                    child: const Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Skip to dashboard
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/free-agent/dashboard',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LeagueCard extends StatelessWidget {
  final LeagueModel league;
  final bool isSelected;
  final VoidCallback onSelect;

  const _LeagueCard({
    required this.league,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: league.logo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(league.logo!, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Text(
                            league.leagueName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        league.leagueName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Format: ${league.format}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Start Date', _formatDate(league.startDate)),
                _buildInfoColumn('End Date', _formatDate(league.endDate)),
                _buildInfoColumn(
                  'League Fee',
                  '\$${league.perPlayerLeagueFee.toStringAsFixed(0)}',
                  isFee: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Show more',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isFee = false}) {
    return Column(
      crossAxisAlignment: isFee
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isFee ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: isFee ? const Color(0xFF0F172A) : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
