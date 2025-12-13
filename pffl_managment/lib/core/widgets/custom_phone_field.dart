import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';

class CustomPhoneField extends StatefulWidget {
  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<bool>? onInputValidated;
  final String? hintText;
  final PhoneNumber? initialValue;
  final TextStyle? style;
  final TextStyle? selectorTextStyle;
  final bool enabled;

  const CustomPhoneField({
    super.key,
    this.onInputChanged,
    this.onInputValidated,
    this.hintText,
    this.initialValue,
    this.style,
    this.selectorTextStyle,
    this.enabled = true,
  });

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _isFocused
              ? AppColors
                    .primary // Focused border color
              : AppColors.borderDefault, // Normal border color
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          InternationalPhoneNumberInput(
            onInputChanged: widget.onInputChanged,
            onInputValidated: widget.onInputValidated,
            selectorConfig: SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              showFlags: true,
              useEmoji: true,
              setSelectorButtonAsPrefixIcon: true,
              leadingPadding: 8,
              trailingSpace: false,
              useBottomSheetSafeArea: true,
            ),
            ignoreBlank: true,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle:
                widget.selectorTextStyle ?? theme.textTheme.bodyMedium,
            initialValue: widget.initialValue,
            hintText: widget.hintText,
            isEnabled: widget.enabled,
            inputDecoration: InputDecoration(
              prefixIconConstraints: BoxConstraints(minWidth: 40),
              prefixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textDisabled,
                fontSize: 12.0, // Reduced hint text size
              ),
            ),
            textStyle: widget.style ?? theme.textTheme.bodyMedium,
            textAlign: TextAlign.left,
            focusNode: _focusNode,
            textFieldController: _controller,
            formatInput: true, // Enable auto formatting
          ),

          // Arrow icon positioned next to the country selector
        ],
      ),
    );
  }
}
