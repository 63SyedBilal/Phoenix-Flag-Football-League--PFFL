import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/utils/date_formatter.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';
import 'package:pffl_managment/core/widgets/dotted_border_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:provider/provider.dart';

class Step1TeamInfoWidget extends StatelessWidget {
  const Step1TeamInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Format', style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.setFormatPlayers(5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: viewModel.formatPlayers == 5
                          ? AppColors.primary
                          : AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: viewModel.formatPlayers == 5
                            ? AppColors.primary
                            : AppColors.borderDefault,
                        width: viewModel.formatPlayers == 5 ? 0 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '5v5',
                        style: TextStyle(
                          fontSize: 14,
                          color: viewModel.formatPlayers == 5
                              ? AppColors.buttonText
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.setFormatPlayers(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: viewModel.formatPlayers == 7
                          ? AppColors.primary
                          : AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: viewModel.formatPlayers == 7
                            ? AppColors.primary
                            : AppColors.borderDefault,
                        width: viewModel.formatPlayers == 7 ? 0 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '7v7',
                        style: TextStyle(
                          fontSize: 14,
                          color: viewModel.formatPlayers == 7
                              ? AppColors.buttonText
                              : AppColors.textDisabled,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('League Name', style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          CustomTextField(
            controller: viewModel.leagueNameController,
            hintText: 'Enter League Name',
            errorText: viewModel.leagueNameError,
            onChanged: (text) {
              viewModel.setLeagueName(text);
              viewModel.setLeagueNameText(text);
            },
          ),
          const SizedBox(height: 18),
          const Text('Upload Logo', style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          DottedBorderWidget(
            strokeWidth: 1.5,
            dashWidth: 5.0,
            dashSpace: 3.0,
            color: viewModel.logoError != null ? Colors.red : AppColors.borderDefault,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: double.infinity,
              height: 150, // Set a fixed height for the container
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.backgroundWhite,
              ),
              child: viewModel.uploadedLogoPath.isEmpty
                  ? GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;
                          final path =
                              file.path ?? 'assets/images/logos/default_logo.png';
                          viewModel.setUploadedLogo(path);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Tap below to upload\nyour league logo.',
                            style: AppTextStyles.labelLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(14.87),
                            ),
                            child: Container(
                              width: 60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.upload,
                                    size: 16,
                                    color: AppColors.buttonText,
                                  ),
                                  SizedBox(width: 8),
                                  const Text(
                                    'Upload',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.backgroundWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;
                          final path =
                              file.path ?? 'assets/images/logos/default_logo.png';
                          viewModel.setUploadedLogo(path);
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(viewModel.uploadedLogoPath),
                              fit: BoxFit.cover, // Changed back to cover to fill entire container
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.backgroundWhite,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.textDisabled,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary,
                                  borderRadius: BorderRadius.circular(14.87),
                                ),
                                child: const Icon(
                                  Icons.upload,
                                  size: 16,
                                  color: AppColors.buttonText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          // Logo error message
          if (viewModel.logoError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                children: [
                  SvgIcons.infoFill(size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      viewModel.logoError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Date', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: viewModel.startDateError != null 
                              ? Colors.red 
                              : AppColors.borderDefault,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: viewModel.startDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: Colors.white,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                  dialogBackgroundColor: Colors.white,
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) viewModel.setStartDate(picked);
                        },
                        child: AbsorbPointer(
                          child: CustomTextField(
                            hintText: DateFormatter.format(viewModel.startDate),
                            suffixIcon: const Icon(
                              AppIcons.calendar,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Start Date error below container
                    if (viewModel.startDateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            SvgIcons.infoFill(size: 14, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                viewModel.startDateError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Date', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: viewModel.endDateError != null 
                              ? Colors.red 
                              : AppColors.borderDefault,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDefault.withValues(
                              alpha: 0.05,
                            ),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                viewModel.endDate ??
                                DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: Colors.white,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                  dialogBackgroundColor: Colors.white,
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) viewModel.setEndDate(picked);
                        },
                        child: AbsorbPointer(
                          child: CustomTextField(
                            hintText: viewModel.endDate != null
                                ? DateFormatter.formatDate(viewModel.endDate!)
                                : '',
                            suffixIcon: const Icon(
                              AppIcons.calendar,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // End Date error below container
                    if (viewModel.endDateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            SvgIcons.infoFill(size: 14, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                viewModel.endDateError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Minimum Players Required', style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          SimpleDropdownList(
            selectedValue: viewModel.minPlayers > 0 ? viewModel.minPlayers.toString() : null,
            items: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'],
            onSelected: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null) viewModel.setMinPlayers(intValue);
            },
            hintText: 'Select minimum players',
            maxHeight: 200.0,
          ),
          // Min players error message
          if (viewModel.minPlayersError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                children: [
                  SvgIcons.infoFill(size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      viewModel.minPlayersError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
         
          const Text(
            'Per Player League Fee',
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 4),
          CustomTextField(
            controller: viewModel.perPlayerFeeController,
            keyboardType: TextInputType.number,
            hintText: '\$250',
            errorText: viewModel.perPlayerFeeError,
            onChanged: (text) {
              viewModel.setPerPlayerFeeText(text);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
