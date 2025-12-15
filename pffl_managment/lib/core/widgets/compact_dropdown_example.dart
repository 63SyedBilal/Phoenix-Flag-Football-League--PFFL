import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/compact_dropdown_menu.dart';

class CompactDropdownExample extends StatefulWidget {
  const CompactDropdownExample({super.key});

  @override
  State<CompactDropdownExample> createState() => _CompactDropdownExampleState();
}

class _CompactDropdownExampleState extends State<CompactDropdownExample> {
  String? _selectedValue;
  int? _selectedNumber;
  String? _selectedLongItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compact Dropdown Menu Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compact Dropdown Menu Examples',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Simple string dropdown
            const Text('Select an option:'),
            const SizedBox(height: 8),
            SimpleCompactDropdownMenu<String>(
              value: _selectedValue,
              items: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
              onChanged: (value) {
                setState(() {
                  _selectedValue = value;
                });
              },
              hintText: 'Choose an option',
            ),
            const SizedBox(height: 20),
            
            // Number dropdown
            const Text('Select a number:'),
            const SizedBox(height: 8),
            SimpleCompactDropdownMenu<int>(
              value: _selectedNumber,
              items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
              onChanged: (value) {
                setState(() {
                  _selectedNumber = value;
                });
              },
              hintText: 'Choose a number',
            ),
            const SizedBox(height: 20),
            
            // Long items dropdown
            const Text('Select a long item:'),
            const SizedBox(height: 8),
            SimpleCompactDropdownMenu<String>(
              value: _selectedLongItem,
              items: [
                'This is a very long item that might overflow',
                'Another long item with lots of text content',
                'Yet another long item that demonstrates text truncation',
                'Short item',
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLongItem = value;
                });
              },
              hintText: 'Choose a long item',
              maxHeight: 150.0, // Smaller max height
            ),
            const SizedBox(height: 20),
            
            // Display selected values
            if (_selectedValue != null || _selectedNumber != null || _selectedLongItem != null) ...[
              const Text(
                'Selected Values:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_selectedValue != null)
                Text('String: $_selectedValue'),
              if (_selectedNumber != null)
                Text('Number: $_selectedNumber'),
              if (_selectedLongItem != null)
                Text('Long Item: $_selectedLongItem'),
            ],
          ],
        ),
      ),
    );
  }
}