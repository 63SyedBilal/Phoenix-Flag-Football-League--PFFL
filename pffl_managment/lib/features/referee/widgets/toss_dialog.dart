import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

/// Toss Dialog Widget
/// Displays team selection and decision dropdown for toss
class TossDialog extends StatefulWidget {
  final MatchModel match;
  final Function(String winnerTeamId, String winnerSide) onConfirm;

  const TossDialog({
    super.key,
    required this.match,
    required this.onConfirm,
  });

  @override
  State<TossDialog> createState() => _TossDialogState();
}

class _TossDialogState extends State<TossDialog> {
  String? _selectedTeamId;
  String? _selectedDecision; // 'offense' or 'defense'
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final teamAId = widget.match.homeTeamId ?? '';
    final teamBId = widget.match.awayTeamId ?? '';
    final teamAName = widget.match.homeTeam;
    final teamBName = widget.match.awayTeam;
    final teamALogo = widget.match.homeTeamLogo;
    final teamBLogo = widget.match.awayTeamLogo;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Toss',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Select Toss Winner Section
              const Text(
                'Select Toss Winner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Team Selection Cards
              Row(
                children: [
                  Expanded(
                    child: _buildTeamCard(
                      teamId: teamAId,
                      teamName: teamAName,
                      teamLogo: teamALogo,
                      isSelected: _selectedTeamId == teamAId,
                      onTap: () {
                        setState(() {
                          _selectedTeamId = teamAId;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTeamCard(
                      teamId: teamBId,
                      teamName: teamBName,
                      teamLogo: teamBLogo,
                      isSelected: _selectedTeamId == teamBId,
                      onTap: () {
                        setState(() {
                          _selectedTeamId = teamBId;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Select Decision Section
              const Text(
                'Select Decision',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Decision Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDecision,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    hint: const Text(
                      'Select Decision',
                      style: TextStyle(color: Colors.grey),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'offense',
                        child: Text('Offensive'),
                      ),
                      DropdownMenuItem(
                        value: 'defense',
                        child: Text('Defensive'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDecision = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Close Button
                  OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Start Match Button
                  ElevatedButton(
                    onPressed: _isLoading || _selectedTeamId == null || _selectedDecision == null
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await widget.onConfirm(_selectedTeamId!, _selectedDecision!);
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A5F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Start Match',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard({
    required String teamId,
    required String teamName,
    required String teamLogo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Team Logo
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: teamLogo.isNotEmpty && teamLogo.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        teamLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultLogo(teamName, isSelected),
                      ),
                    )
                  : _buildDefaultLogo(teamName, isSelected),
            ),
            const SizedBox(width: 8),
            // Team Name
            Expanded(
              child: Text(
                teamName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLogo(String teamName, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFB91C1C),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
