import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/providers/create_team_provider.dart';

/// Team color input field widget with color picker (optional, not sent to API)
class TeamColorField extends StatelessWidget {
  const TeamColorField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, provider, _) {
        // Parse color from hex string if available
        Color? selectedColor;
        if (provider.teamColor != null && provider.teamColor!.isNotEmpty) {
          try {
            // Remove # if present
            String colorHex = provider.teamColor!.replaceAll('#', '');
            // Add # if not present
            if (!colorHex.startsWith('#')) {
              colorHex = '#$colorHex';
            }
            selectedColor = Color(
              int.parse(colorHex.replaceFirst('#', ''), radix: 16) + 0xFF000000,
            );
          } catch (e) {
            // Invalid color format, ignore
            selectedColor = null;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showColorPicker(context, provider, selectedColor),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: provider.teamColor ?? '',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tap to select color',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: selectedColor != null
                        ? Container(
                            margin: const EdgeInsets.all(8),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.color_lens,
                            color: Color(0xFF3B82F6),
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker(
    BuildContext context,
    CreateTeamProvider provider,
    Color? currentColor,
  ) {
    Color pickerColor = currentColor ?? Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Team Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              availableColors: const [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
                Colors.black,
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                // Convert color to hex string
                String hexColor =
                    '#${pickerColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                provider.setTeamColor(hexColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
