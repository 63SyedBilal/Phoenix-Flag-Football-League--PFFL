import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';

class SimpleDropdownList extends StatefulWidget {
  final String? selectedValue;
  final List<String> items;
  final Function(String) onSelected;
  final String? hintText;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double maxHeight;
  final TextStyle? hintStyle;

  const SimpleDropdownList({
    super.key,
    this.selectedValue,
    required this.items,
    required this.onSelected,
    this.hintText,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.maxHeight = 150.0,
    this.hintStyle,
  });

  @override
  State<SimpleDropdownList> createState() => _SimpleDropdownListState();
}

class _SimpleDropdownListState extends State<SimpleDropdownList> {
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!_isOpen) {
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
    final shouldAppearAbove =
        offset.dy + size.height + widget.maxHeight > screenHeight;

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
                            widget.onSelected(item);
                            _closeDropdown();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: widget.selectedValue == item
                                  ? const Color(0xFF3B82F6)
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.borderDefault.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: widget.selectedValue == item
                                          ? Colors.white
                                          : AppColors.textPrimary,
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
                  widget.selectedValue ?? (widget.hintText ?? ''),
                  style: widget.selectedValue != null
                      ? AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        )
                      : (widget.hintStyle ??
                            AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDisabled,
                            )),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SvgPicture.asset(
                'assets/icons/home_icons/arrowDounIcon.svg',
                width: 18,
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
