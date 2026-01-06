import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/notification/provider/admin_notification_provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';
import 'package:intl/intl.dart';

class AdminStatsApprovalScreen extends StatefulWidget {
  final String matchId;
  final String notificationId;

  const AdminStatsApprovalScreen({
    super.key,
    required this.matchId,
    required this.notificationId,
  });

  @override
  State<AdminStatsApprovalScreen> createState() =>
      _AdminStatsApprovalScreenState();
}

class _AdminStatsApprovalScreenState extends State<AdminStatsApprovalScreen> {
  bool _isApproving = false;
  bool _isRejecting = false;
  bool _isLoadingMatch = true;
  MatchModel? _match;
  bool _isTeamAExpanded = true;
  bool _isTeamBExpanded = false;
  bool _isGameDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
  }

  Future<void> _fetchMatchDetails() async {
    try {
      final match = await MatchService.getMatchById(widget.matchId);
      if (mounted) {
        setState(() {
          _match = match;
          _isLoadingMatch = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMatch = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching match details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMatch) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Could not load match details')),
      );
    }

    final homeStats =
        _match!.homeTeamStats ??
        TeamStatModel(
          teamName: _match!.homeTeam,
          teamLogo: _match!.homeTeamLogo,
        );
    final awayStats =
        _match!.awayTeamStats ??
        TeamStatModel(
          teamName: _match!.awayTeam,
          teamLogo: _match!.awayTeamLogo,
        );
    final dateStr = _match!.matchDateTime != null
        ? DateFormat('dd MMM yyyy').format(_match!.matchDateTime!)
        : _match!.date;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Draft Stats Submitted for Approval',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A statkeeper has submitted stats for approval. Please review the details below.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildExpandableTile(
              'View Game Details',
              isOpen: _isGameDetailsExpanded,
              onTap: () => setState(
                () => _isGameDetailsExpanded = !_isGameDetailsExpanded,
              ),
              content: _buildGameDetails(),
            ),
            const SizedBox(height: 16),
            _buildExpandableTile(
              '${_match!.homeTeam} Team Stats',
              isOpen: _isTeamAExpanded,
              onTap: () => setState(() => _isTeamAExpanded = !_isTeamAExpanded),
              content: _buildStatList(homeStats),
            ),
            const SizedBox(height: 16),
            _buildExpandableTile(
              '${_match!.awayTeam} Team Stats',
              isOpen: _isTeamBExpanded,
              onTap: () => setState(() => _isTeamBExpanded = !_isTeamBExpanded),
              content: _buildStatList(awayStats),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isApproving || _isRejecting
                        ? null
                        : () => _handleReject(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF111827)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isRejecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Send Back',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isApproving || _isRejecting
                        ? null
                        : () => _handleApprove(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F173E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isApproving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Approved',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableTile(
    String title, {
    required bool isOpen,
    required VoidCallback onTap,
    Widget? content,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
        if (isOpen && content != null) content,
        if (!isOpen) const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildGameDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildStatRow('League', _match!.leagueName),
          _buildStatRow('Venue', _match!.venue ?? 'N/A'),
          _buildStatRow('Format', _match!.format ?? 'N/A'),
          _buildStatRow('Status', _match!.status?.name.toUpperCase() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildStatList(TeamStatModel stats) {
    return Column(
      children: [
        _buildStatRow('Catches', '${stats.catches}'),
        _buildStatRow('Catches Yrds', '${stats.catchesYards}'),
        _buildStatRow('Rushes', '${stats.rushes}'),
        _buildStatRow('Rushes Yrds', '${stats.rushesYards}'),
        _buildStatRow('Pass Attempts', '${stats.passAttempts}'),
        _buildStatRow('Pass Yrds', '${stats.passYards}'),
        _buildStatRow('Completions', '${stats.completions}'),
        _buildStatRow('TD\'s', '${stats.tds}'),
        _buildStatRow('Flag Pull', '${stats.flagPull}'),
        _buildStatRow('Sack', '${stats.sack}'),
        _buildStatRow('INT', '${stats.interceptions}'),
        _buildStatRow('Safety', '${stats.safety}'),
        _buildStatRow('Conversion Points', '${stats.conversionPoints}'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove() async {
    setState(() => _isApproving = true);
    final provider = Provider.of<AdminNotificationProvider>(
      context,
      listen: false,
    );
    final success = await provider.approveStats(
      widget.notificationId,
      matchId: widget.matchId,
    );
    if (mounted) {
      setState(() => _isApproving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stats approved successfully')),
        );
      }
    }
  }

  Future<void> _handleReject() async {
    setState(() => _isRejecting = true);
    final provider = Provider.of<AdminNotificationProvider>(
      context,
      listen: false,
    );
    final success = await provider.rejectStats(
      widget.notificationId,
      matchId: widget.matchId,
    );
    if (mounted) {
      setState(() => _isRejecting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stats sent back for correction')),
        );
      }
    }
  }
}
