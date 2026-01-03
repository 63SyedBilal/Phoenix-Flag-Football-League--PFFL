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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Column(
        children: [
          
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
                      Provider.of<StatKeeperNavigationProvider>(
                        context,
                        listen: false,
                      ).setIndex(0);
                    }
                  },
                  height: 48,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton.primary(
                  text: provider.isReadOnly ? 'Read Only' : 'Update Now',
                  onPressed: provider.isReadOnly
                      ? () {}
                      : () {
                          if (provider.validateInputs()) {
                            provider.updateNow(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a team and enter valid data',
                                ),
                              ),
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
  final String? matchId;

  const StatAddScreen({super.key, this.matchId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = StatAddProvider();
        provider.initialize(matchId);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
          child: ChangeNotifierProvider(
            create: (_) {
              final provider = StatAddProvider();
              provider.initialize(matchId);
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
      constraints: const BoxConstraints(maxWidth: 800),
      margin: isDialog ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _HeaderSection(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  if (provider.isReadOnly)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            color: Colors.amber.shade800,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This match is completed and stats are locked.',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _buildLabel('Select Game'),
                  const SizedBox(height: 8),
                
                  if (provider.isLoadingMatches)
                    const Center(child: CircularProgressIndicator())
                  else
                    SimpleDropdownList(hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    )
                    ,
                      selectedValue: provider.selectedMatchId != null
                          ? provider.assignedMatches
                                .where((m) => m.id == provider.selectedMatchId)
                                .map(
                                  (m) =>
                                      '${m.homeTeam} vs ${m.awayTeam} (${m.date})',
                                )
                                .firstOrNull
                          : null,
                      items: provider.matchOptions,
                      onSelected: (String val) {
                        if (!provider.isReadOnly)
                          provider.setSelectedMatch(val);
                      },
                      hintText: 'Select Game',
                    ),
                  const SizedBox(height: 20),

                  _buildLabel('Select Team'),
                  const SizedBox(height: 8),
                  if (provider.isLoadingTeams)
                    const Center(child: CircularProgressIndicator())
                  else
                    SimpleDropdownList( 
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      selectedValue: provider.selectedTeam,
                      items: provider.teams,
                      onSelected: (String val) {
                        if (!provider.isReadOnly) provider.setSelectedTeam(val);
                      },
                      hintText: 'Select Team',
                    ),
                  const SizedBox(height: 20),

                  _buildLabel('Select Player'),
                  const SizedBox(height: 8),
                  if (provider.isLoadingPlayers)
                    const Center(child: CircularProgressIndicator())
                  else
                    SimpleDropdownList(
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      selectedValue: provider.selectedPlayer,
                      items: provider.players,
                      onSelected: (String val) {
                        if (!provider.isReadOnly)
                          provider.setSelectedPlayer(val);
                      },
                      hintText: 'Select Player',
                    ),
                  const SizedBox(height: 24),

                  _buildStatRow(
                    'Catches',
                    'Catches Yards',
                    provider.catchesController,
                    provider.catchesYardsController,
                    provider.isReadOnly,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'Rushes',
                    'Rushes Yards',
                    provider.rushesController,
                    provider.rushesYardsController,
                    provider.isReadOnly,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'Pass Attempts',
                    'Pass Yards',
                    provider.passAttemptsController,
                    provider.passYardsController,
                    provider.isReadOnly,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'Completions',
                    'TD\'s',
                    provider.completionsController,
                    provider.tdsController,
                    provider.isReadOnly,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'Flag Pull',
                    'Sack',
                    provider.flagPullController,
                    provider.sackController,
                    provider.isReadOnly,
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    'INT',
                    'Safety',
                    provider.intController,
                    provider.safetyController,
                    provider.isReadOnly,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Conversion Points'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: provider.conversionPointsController,
                    hintText: 'Enter here',
                    keyboardType: TextInputType.number,
                    enabled: !provider.isReadOnly,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _ActionButtons(provider: provider, isDialog: isDialog),
        ],
      ),
    );

    if (isDialog) return content;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(child: Center(child: content)),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        fontFamily: 'La',
      ),
    );
  }

  Widget _buildStatRow(
    String label1,
    String label2,
    TextEditingController controller1,
    TextEditingController controller2,
    bool readOnly,
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
                enabled: !readOnly,
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
                enabled: !readOnly,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Edit Game Stats',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'Serotiva',
            ),
          ),
          Text(
            'Stats helps you to analyze game in smooth\nor better way',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}