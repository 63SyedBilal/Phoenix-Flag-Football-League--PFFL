import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/providers/phone_field_provider.dart';

/// Custom phone number input field widget using Provider for state management
class CustomPhoneField extends StatelessWidget {
  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<bool>? onInputValidated;
  final String? hintText;
  final PhoneNumber? initialValue;
  final TextStyle? style;
  final TextStyle? selectorTextStyle;
  final bool enabled;
  final String? errorText; // Error message to display below field

  const CustomPhoneField({
    super.key,
    this.onInputChanged,
    this.onInputValidated,
    this.hintText,
    this.initialValue,
    this.style,
    this.selectorTextStyle,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) {
        final provider = PhoneFieldProvider(initialValue: initialValue);
        provider.onInputChanged = onInputChanged;
        provider.onInputValidated = onInputValidated;
        return provider;
      },
      child: Consumer<PhoneFieldProvider>(
        builder: (context, provider, child) {
          // Update provider if initialValue changes from parent
          if (initialValue != null &&
              (provider.countryISOCode != initialValue?.countryISOCode ||
                  provider.controller.text != initialValue?.number)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.updateInitialValue(initialValue);
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: errorText != null
                        ? Colors.red
                        : (provider.isFocused
                              ? AppColors.primary
                              : AppColors.borderDefault),
                    width: errorText != null ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IntlPhoneField(
                  controller: provider.controller,
                  focusNode: provider.focusNode,
                  initialCountryCode: provider.countryISOCode,
                  initialValue: initialValue?.number,
                  enabled: enabled,
                  decoration: InputDecoration(
                    hintText: hintText ?? 'Enter phone number',
                    hintStyle:
                        style ??
                        theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDisabled,
                          fontSize: 12.0,
                        ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    errorStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      height: 1.0,
                    ),
                  ),
                  style:
                      style ??
                      theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.phone,
                  onChanged: (PhoneNumber phone) {
                    provider.handleInputChanged(phone);
                  },
                  onCountryChanged: (country) {
                    // Country changed - update provider
                    final phoneNumber = PhoneNumber(
                      countryCode: country.code,
                      countryISOCode: country.code,
                      number: provider.controller.text,
                    );
                    provider.handleInputChanged(phoneNumber);
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      provider.handleInputValidated(false);
                      return null; // Let errorText handle display
                    }
                    final isValid = phone.isValidNumber();
                    provider.handleInputValidated(isValid);
                    return null; // Let errorText handle display
                  },
                  disableLengthCheck: false,
                  showDropdownIcon: true,
                  dropdownIcon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  dropdownIconPosition: IconPosition.leading,
                  flagsButtonPadding: const EdgeInsets.only(left: 8),
                  invalidNumberMessage: null, // We handle errors via errorText
                ),
              ),
              // Show error message below field if provided
              if (errorText != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
