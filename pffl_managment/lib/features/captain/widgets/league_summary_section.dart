import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/providers/league_summary_provider.dart';

class LeagueSummarySection extends StatelessWidget {
  final String leagueId;

  const LeagueSummarySection({super.key, required this.leagueId});

  @override
  Widget build(BuildContext context) {
    final summaryProvider = Provider.of<LeagueSummaryProvider>(context);
    final isLoading = summaryProvider.isLoading(leagueId);
    final error = summaryProvider.getError(leagueId);
    final summary = summaryProvider.getCachedSummary(leagueId);

    // Fetch summary data when widget first builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (summary == null && !isLoading && error == null) {
        summaryProvider.getLeagueSummary(leagueId);
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'League Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 16),

          // Loading State
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )

          // Error State
          else if (error != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to load league summary: $error',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => summaryProvider.refreshSummary(leagueId),
                    icon: Icon(Icons.refresh, color: Colors.red.shade600),
                  ),
                ],
              ),
            )

          // Summary Data
          else if (summary != null)
            Column(
              children: [
                // League Info Row
                _buildInfoRow(
                  context,
                  'League Name',
                  summary.leagueName,
                  Icons.sports_soccer,
                ),
                const SizedBox(height: 12),

                // Teams and Matches Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        'Total Teams',
                        summary.totalTeams.toString(),
                        Icons.groups,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        'Total Matches',
                        summary.totalMatches.toString(),
                        Icons.sports,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dates Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        'Start Date',
                        DateFormat('MMM dd, yyyy').format(summary.startDate),
                        Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        'End Date',
                        DateFormat('MMM dd, yyyy').format(summary.endDate),
                        Icons.event,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Format and Status Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        'Match Format',
                        summary.matchFormat,
                        Icons.format_list_numbered,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatusRow(
                        context,
                        'League Status',
                        summary.leagueStatus,
                      ),
                    ),
                  ],
                ),

                // Captain's Team Section (if available)
                if (summary.captainTeam != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Team',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue.shade600, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                summary.captainTeam!.teamName,
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.group, color: Colors.blue.shade600, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${summary.captainTeam!.playerCount} Players',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                            if (summary.captainTeam!.position != null) ...[
                              const SizedBox(width: 16),
                              Icon(Icons.emoji_events, color: Colors.blue.shade600, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Position: ${summary.captainTeam!.position}',
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            )

          // No data state
          else
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Loading league summary...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'in_progress':
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_outline;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'upcoming':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 20, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
