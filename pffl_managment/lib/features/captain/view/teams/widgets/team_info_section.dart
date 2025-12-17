import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import '../../../model/team_model.dart';

class TeamInfoSection extends StatelessWidget {
  final TeamModel team;
  final String? selectedFormat;
  final Function(String)? onFormatChanged;
  final GlobalKey _iconKey = GlobalKey();

  TeamInfoSection({
    super.key,
    required this.team,
    this.selectedFormat,
    this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.none,
                    ),
                  ),
                  child: team.logoUrl != null && team.logoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            team.logoUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                backgroundColor: Colors.white,
                                child: const Icon(Icons.shield, color: Colors.black),
                              );
                            },
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.shield, color: Colors.black),
                        ),
                ),
                const SizedBox(width: 12),
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${team.players.length}/${team.maxPlayers}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  key: _iconKey,
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Show popup menu with options
                    final RenderBox icon = _iconKey.currentContext!.findRenderObject() as RenderBox;
                    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                    
                    showMenu(
                    color: AppColors.lightAppBarBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      context: context,
                      position: RelativeRect.fromRect(
                        Rect.fromPoints(
                          icon.localToGlobal(const Offset(0, 30), ancestor: overlay), // Shift down by 30 pixels
                          icon.localToGlobal(icon.size.bottomRight(const Offset(0, 30)), ancestor: overlay), // Shift down by 30 pixels
                        ),
                        Offset.zero & overlay.size,
                      ),
                      items: [
                        PopupMenuItem(
                          onTap: () {
                            // Show dialog when Transfer Leadership is selected
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      title: const Text('Transfer Leadership'),
                                      
                                      children: <Widget>[
                                        const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Text('Transfer leadership functionality to be implemented'),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Close'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: const Text('Transfer Leadership'),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            // Show dialog when Remove Player is selected
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      title: const Text('Remove Player'),
                                      children: <Widget>[
                                        const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Text('Remove player functionality to be implemented'),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Close'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: const Text('Remove Player'),
                          ),
                        ),
                      ],
                      elevation: 8,
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        // Format selection (only show if format callbacks are provided)
        if (selectedFormat != null && onFormatChanged != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFormatBadge(
                context,
                label: '5v5',
                isSelected: selectedFormat == '5v5',
                onTap: () => onFormatChanged!('5v5'),
              ),
              const SizedBox(width: 8),
              _buildFormatBadge(
                context,
                label: '7v7',
                isSelected: selectedFormat == '7v7',
                onTap: () => onFormatChanged!('7v7'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFormatBadge(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}