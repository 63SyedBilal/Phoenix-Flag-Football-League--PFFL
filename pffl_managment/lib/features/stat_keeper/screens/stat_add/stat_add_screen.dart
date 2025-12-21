import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/stat_keeper_navigation_provider.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_add_provider.dart';

class _ActionButtons extends StatelessWidget {
  final StatAddProvider provider;
  final bool isDialog;

  const _ActionButtons({required this.provider, this.isDialog = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Column(
        children: [
          // Reset to Default button
          CustomButton.secondary(
            text: 'Reset to Default',
            onPressed: provider.resetToDefault,
            height: 48,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton.secondary(
                  text: 'Cancel',
                  onPressed: () {
                    provider.clearForm();
                    if (isDialog) {
                      Navigator.of(context).pop();
                    } else {
                      // Navigate back to Home (index 0) or Stats (index 3)
                      Provider.of<StatKeeperNavigationProvider>(
                        context,
                        listen: false,
                      ).setIndex(0);
                    }
                  },
                  height: 48,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton.primary(
                  text: 'Update Now',
                  onPressed: () {
                    if (provider.validateInputs()) {
                      provider.updateNow(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a team and enter at least one stat')),
                      );
                    }
                  },
                  height: 48,
                  isLoading: provider.isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatAddScreen extends StatelessWidget {
  const StatAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = StatAddProvider();
        // For the full screen, we might need to get match ID from route or provider
        // For now, initialize without match ID (will show empty dropdowns)
        return provider;
      },
      child: const _StatAddScreenContent(),
    );
  }

  static void showAsDialog(BuildContext context, {String? matchId}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: ChangeNotifierProvider(
            create: (_) {
              final provider = StatAddProvider();
              if (matchId != null) {
                provider.initialize(matchId);
              }
              return provider;
            },
            child: const _StatAddScreenContent(isDialog: true),
          ),
        ),
      ),
    );
  }
}

class _StatAddScreenContent extends StatelessWidget {
  const _StatAddScreenContent({this.isDialog = false});

  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatAddProvider>();

    final content = Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: isDialog ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          const _HeaderSection(),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Team Selection
                  _buildLabel('Select Team'),
                  const SizedBox(height: 8),
                  if (provider.isLoadingTeams)
                    const Center(child: CircularProgressIndicator())
                  else
                    SimpleDropdownList(
                      selectedValue: provider.selectedTeam,
                      items: provider.teams,
                      onSelected: provider.setSelectedTeam,
                      hintText: 'Select Team',
                    ),
                  const SizedBox(height: 20),

                  // Player Selection
                  _buildLabel('Select Player'),
                  const SizedBox(height: 8),
                  if (provider.isLoadingPlayers)
                    const Center(child: CircularProgressIndicator())
                  else
                    SimpleDropdownList(
                      selectedValue: provider.selectedPlayer,
                      items: provider.players,
                      onSelected: provider.setSelectedPlayer,
                      hintText: 'Select Player',
                    ),
                  const SizedBox(height: 24),

                  // Stat Fields
                  _buildStatRow(
                    'Catches',
                    'Catches Yards',
                    provider.catchesController,
                    provider.catchesYardsController,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'Rushes',
                    'Rushes Yards',
                    provider.rushesController,
                    provider.rushesYardsController,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'Pass Attempts',
                    'Pass Yards',
                    provider.passAttemptsController,
                    provider.passYardsController,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'Completions',
                    'TD\'s',
                    provider.completionsController,
                    provider.tdsController,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'Flag Pull',
                    'Sack',
                    provider.flagPullController,
                    provider.sackController,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'INT',
                    'Safety',
                    provider.intController,
                    provider.safetyController,
                  ),
                  const SizedBox(height: 16),

                  // Conversion Points (full width)
                  _buildLabel('Conversion Points'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: provider.conversionPointsController,
                    hintText: 'Enter here',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action Buttons
          _ActionButtons(provider: provider, isDialog: isDialog),
        ],
      ),
    );

    if (isDialog) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: content,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStatRow(
    String label1,
    String label2,
    TextEditingController controller1,
    TextEditingController controller2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(label1),
              const SizedBox(height: 8),
              CustomTextField(
                controller: controller1,
                hintText: 'Enter here',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(label2),
              const SizedBox(height: 8),
              CustomTextField(
                controller: controller2,
                hintText: 'Enter here',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Add Game Stats',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stats helps you to analyze game in smooth\nor better way',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
