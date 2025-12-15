import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';

class CompactDropdownMenu<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? suffixIcon;
  final bool enabled;
  final double maxHeight;
  final String Function(T)? itemLabelBuilder;

  const CompactDropdownMenu({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.suffixIcon,
    this.enabled = true,
    this.maxHeight = 200.0,
    this.itemLabelBuilder,
  });

  @override
  State<CompactDropdownMenu> createState() => _CompactDropdownMenuState<T>();
}

class _CompactDropdownMenuState<T> extends State<CompactDropdownMenu<T>> {
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!_isOpen && widget.enabled) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    if (!_isOpen) {
      _isOpen = true;
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _closeDropdown() {
    if (_isOpen) {
      _isOpen = false;
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Calculate if dropdown should appear above or below
    final screenHeight = MediaQuery.of(context).size.height;
    final shouldAppearAbove = offset.dy + size.height + widget.maxHeight > screenHeight;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop to close when tapping outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown menu positioned appropriately
          Positioned(
            left: offset.dx,
            width: size.width,
            top: shouldAppearAbove 
                ? offset.dy - widget.maxHeight - 5 
                : offset.dy + size.height + 5,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(maxHeight: widget.maxHeight),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: widget.borderColor ?? AppColors.borderDefault,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.map((item) {
                        return GestureDetector(
                          onTap: () {
                            widget.onChanged(item.value);
                            _closeDropdown();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.borderDefault.withValues(alpha: 0.5),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (widget.value == item.value) ...[
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                ] else ...[
                                  const SizedBox(width: 24), // Space for alignment
                                ],
                                Expanded(
                                  child: Text(
                                    widget.itemLabelBuilder?.call(item.value as T) ??
                                        item.value.toString(),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _fieldKey,
      onTap: _toggleDropdown,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.borderDefault,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: widget.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.value != null
                      ? (widget.itemLabelBuilder?.call(widget.value as T) ??
                          widget.value.toString())
                      : (widget.hintText ?? ''),
                  style: widget.value != null
                      ? AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        )
                      : AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDisabled,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              widget.suffixIcon ??
                  Icon(
                    _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simplified version for direct usage with just values
class SimpleCompactDropdownMenu<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? suffixIcon;
  final bool enabled;
  final double maxHeight;
  final String Function(T)? itemLabelBuilder;

  const SimpleCompactDropdownMenu({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.suffixIcon,
    this.enabled = true,
    this.maxHeight = 200.0,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CompactDropdownMenu<T>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabelBuilder?.call(item) ?? item.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      hintText: hintText,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      suffixIcon: suffixIcon,
      enabled: enabled,
      maxHeight: maxHeight,
      itemLabelBuilder: itemLabelBuilder,
    );
  }
}