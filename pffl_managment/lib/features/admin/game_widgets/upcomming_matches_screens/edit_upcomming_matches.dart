import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

class EditUpcommingGames extends StatefulWidget {
  final MatchModel? match; // Optional match to edit

  const EditUpcommingGames({super.key, this.match});

  @override
  State<EditUpcommingGames> createState() => _EditUpcommingGamesState();
}

class _EditUpcommingGamesState extends State<EditUpcommingGames> {
  late TextEditingController _leagueNameController;
  late TextEditingController _homeTeamController;
  late TextEditingController _awayTeamController;
  late TextEditingController _venueController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data or defaults
    _leagueNameController = TextEditingController(
      text: widget.match?.leagueName ?? ''
    );
    
    _homeTeamController = TextEditingController(
      text: widget.match?.homeTeam ?? ''
    );
    
    _awayTeamController = TextEditingController(
      text: widget.match?.awayTeam ?? ''
    );
    
    _venueController = TextEditingController(
      text: widget.match?.venue ?? ''
    );
    
    // Set default date/time or use existing
    _selectedDate = widget.match?.matchDateTime ?? DateTime.now();
    _selectedTime = widget.match?.matchDateTime != null 
        ? TimeOfDay.fromDateTime(widget.match!.matchDateTime!) 
        : TimeOfDay.now();
  }

  @override
  void dispose() {
    _leagueNameController.dispose();
    _homeTeamController.dispose();
    _awayTeamController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            widget.match == null ? 'Add New Game' : 'Edit Game',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // League Name Field
          _buildTextField(
            controller: _leagueNameController,
            label: 'League Name',
            hint: 'Enter league name',
          ),
          const SizedBox(height: 16),
          
          // Home Team Field
          _buildTextField(
            controller: _homeTeamController,
            label: 'Home Team',
            hint: 'Enter home team name',
          ),
          const SizedBox(height: 16),
          
          // Away Team Field
          _buildTextField(
            controller: _awayTeamController,
            label: 'Away Team',
            hint: 'Enter away team name',
          ),
          const SizedBox(height: 16),
          
          // Venue Field
          _buildTextField(
            controller: _venueController,
            label: 'Venue',
            hint: 'Enter venue (optional)',
          ),
          const SizedBox(height: 16),
          
          // Date Selection
          _buildDateSelector(
            context: context,
            label: 'Match Date',
            value: _formatDate(_selectedDate),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),
          
          // Time Selection
          _buildDateSelector(
            context: context,
            label: 'Match Time',
            value: _formatTime(_selectedTime),
            onTap: () => _selectTime(context),
          ),
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Here you would typically save the data
                    // For now, just close the dialog
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
                Icon(
                  Icons.calendar_today,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}