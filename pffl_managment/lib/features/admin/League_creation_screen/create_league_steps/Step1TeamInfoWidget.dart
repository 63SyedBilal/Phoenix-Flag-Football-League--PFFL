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
import 'package:pffl_managment/core/providers/calendar_provider.dart';
import 'package:pffl_managment/features/admin/screens/calendar_screen.dart';

class Step1TeamInfoWidget extends StatefulWidget {
  const Step1TeamInfoWidget({super.key});

  @override
  State<Step1TeamInfoWidget> createState() => _Step1TeamInfoWidgetState();
}

class _Step1TeamInfoWidgetState extends State<Step1TeamInfoWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateLeagueViewModel>(context);
    final calendarProvider = Provider.of<CalendarProvider>(
      context,
      listen: false,
    );

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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
            TextFormField(
              controller: viewModel.leagueNameController,
              decoration: InputDecoration(
                hintText: 'Enter League Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: AppColors.backgroundWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'League name is required';
                }
                if (value.trim().length < 3) {
                  return 'League name must be at least 3 characters';
                }
                if (value.trim().length > 50) {
                  return 'League name must be less than 50 characters';
                }
                return null;
              },
              onChanged: (text) {
                viewModel.setLeagueName(text);
                viewModel.setLeagueNameText(text);
                // Clear validation errors on change
                _formKey.currentState?.validate();
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Upload Logo (Optional)',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 4),
            _buildImageUploadSection(viewModel),
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
                          onTap: () {
                            calendarProvider.setSelectionType(
                              DateSelectionType.startDate,
                              viewModel.startDate,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: viewModel,
                                  child: const CalendarScreen(),
                                ),
                              ),
                            );
                          },
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: TextEditingController(
                                text: viewModel.startDate != null
                                    ? DateFormatter.format(viewModel.startDate)
                                    : '',
                              ),
                              hintText: 'Select Date',
                              readOnly: true,
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
                          onTap: () {
                            calendarProvider.setSelectionType(
                              DateSelectionType.endDate,
                              viewModel.endDate,
                              minDate: viewModel
                                  .startDate, // Enforce End Date > Start Date
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: viewModel,
                                  child: const CalendarScreen(),
                                ),
                              ),
                            );
                          },
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: TextEditingController(
                                text: viewModel.endDate != null
                                    ? DateFormatter.format(viewModel.endDate)
                                    : '',
                              ),
                              hintText: 'Select Date',
                              readOnly: true,
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
            const Text(
              'Minimum Players Required',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 4),
            SimpleDropdownList(
              selectedValue: viewModel.minPlayers > 0
                  ? viewModel.minPlayers.toString()
                  : null,
              items: [
                '1',
                '2',
                '3',
                '4',
                '5',
                '6',
                '7',
                '8',
                '9',
                '10',
                '11',
                '12',
                '13',
                '14',
                '15',
              ],
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
            TextFormField(
              controller: viewModel.perPlayerFeeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '\$250',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: AppColors.backgroundWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                prefixText: '\$',
                prefixStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Per player fee is required';
                }
                final fee = double.tryParse(value.trim());
                if (fee == null) {
                  return 'Please enter a valid number';
                }
                if (fee <= 0) {
                  return 'Fee must be greater than 0';
                }
                if (fee > 10000) {
                  return 'Fee must be less than \$10,000';
                }
                return null;
              },
              onChanged: (text) {
                viewModel.setPerPlayerFeeText(text);
                // Clear validation errors on change
                _formKey.currentState?.validate();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(CreateLeagueViewModel viewModel) {
    return DottedBorderWidget(
      strokeWidth: 1.5,
      dashWidth: 5.0,
      dashSpace: 3.0,
      color: viewModel.logoError != null ? Colors.red : AppColors.borderDefault,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColors.backgroundWhite,
        ),
        child: _isUploadingImage
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Selecting image...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            : viewModel.uploadedLogoPath.isEmpty
            ? GestureDetector(
                onTap: () => _pickImageFromFilePicker(viewModel),
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
                onTap: () => _pickImageFromFilePicker(viewModel),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(viewModel.uploadedLogoPath),
                        fit: BoxFit.cover,
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
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            viewModel.setUploadedLogo('');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _pickImageFromFilePicker(CreateLeagueViewModel viewModel) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Validate file size (max 10MB)
          final fileSize = await File(file.path!).length();
          if (fileSize > 10 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image size must be less than 10MB'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            return;
          }

          // Validate file extension
          final extension = file.extension?.toLowerCase();
          if (extension == null ||
              ![
                'jpg',
                'jpeg',
                'png',
                'gif',
                'bmp',
                'webp',
              ].contains(extension)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please select a valid image file (JPG, PNG, GIF, BMP, WebP)',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            return;
          }

          viewModel.setUploadedLogo(file.path!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image selected successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }
}
