import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';

/// Provider for managing improved phone field state
class ImprovedPhoneFieldProvider extends ChangeNotifier {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  Country _selectedCountry;
  bool _isFocused = false;

  // Callbacks
  ValueChanged<PhoneNumber>? onInputChanged;
  ValueChanged<bool>? onInputValidated;

  ImprovedPhoneFieldProvider({String initialCountryCode = 'US'})
    : _selectedCountry = countries.firstWhere(
        (c) => c.code == initialCountryCode,
        orElse: () => countries.firstWhere((c) => c.code == 'US'),
      ) {
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  // Getters
  FocusNode get focusNode => _focusNode;
  TextEditingController get controller => _controller;
  Country get selectedCountry => _selectedCountry;
  bool get isFocused => _isFocused;
  String get dialCode => '+${_selectedCountry.dialCode}';
  String get flagEmoji => _countryCodeToEmoji(_selectedCountry.code);

  void _onFocusChange() {
    _isFocused = _focusNode.hasFocus;
    notifyListeners();
  }

  /// Convert country code to flag emoji
  String _countryCodeToEmoji(String countryCode) {
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  /// Update selected country
  void updateCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
    _notifyPhoneChange();
  }

  /// Handle phone number input changes
  void handleNumberChanged(String number) {
    notifyListeners();
    _notifyPhoneChange();
  }

  void _notifyPhoneChange() {
    final phoneNumber = PhoneNumber(
      countryCode: '+${_selectedCountry.dialCode}',
      countryISOCode: _selectedCountry.code,
      number: _controller.text,
    );
    onInputChanged?.call(phoneNumber);

    // Validate
    final isValid =
        _controller.text.isNotEmpty &&
        _controller.text.length >= _selectedCountry.minLength &&
        _controller.text.length <= _selectedCountry.maxLength;
    onInputValidated?.call(isValid);
  }

  /// Get complete phone number
  PhoneNumber get phoneNumber => PhoneNumber(
    countryCode: '+${_selectedCountry.dialCode}',
    countryISOCode: _selectedCountry.code,
    number: _controller.text,
  );

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}

/// Improved phone number field with:
/// - Country flag icon
/// - Country code displayed
/// - Divider between code and input
/// - Consistent size across countries
/// - No character counter
/// - Numbers only input
/// - Error messages below field
class ImprovedPhoneField extends StatelessWidget {
  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<bool>? onInputValidated;
  final String? hintText;
  final String initialCountryCode;
  final bool enabled;
  final String? errorText;

  const ImprovedPhoneField({
    super.key,
    this.onInputChanged,
    this.onInputValidated,
    this.hintText,
    this.initialCountryCode = 'US',
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) {
        final provider = ImprovedPhoneFieldProvider(
          initialCountryCode: initialCountryCode,
        );
        provider.onInputChanged = onInputChanged;
        provider.onInputValidated = onInputValidated;
        return provider;
      },
      child: Consumer<ImprovedPhoneFieldProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Phone field container
              Container(
                height: 52, // Fixed height for consistency
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
                child: Row(
                  children: [
                    // Country selector button
                    _buildCountrySelector(context, provider, theme),

                    // Divider
                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.borderDefault,
                    ),

                    // Phone number input
                    Expanded(child: _buildPhoneInput(context, provider, theme)),
                  ],
                ),
              ),

              // Error message below field
              if (errorText != null) ...[
                const SizedBox(height: 6),
                Text(
                  errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCountrySelector(
    BuildContext context,
    ImprovedPhoneFieldProvider provider,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: enabled ? () => _showCountryPicker(context, provider) : null,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(6),
        bottomLeft: Radius.circular(6),
      ),
      child: Container(
        width: 90, // Fixed width for consistency
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag emoji
            Text(provider.flagEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            // Country code
            Expanded(
              child: Text(
                provider.dialCode,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(
    BuildContext context,
    ImprovedPhoneFieldProvider provider,
    ThemeData theme,
  ) {
    return TextField(
      controller: provider.controller,
      focusNode: provider.focusNode,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Numbers only
        LengthLimitingTextInputFormatter(15), // Max length without counter
      ],
      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText ?? 'Enter phone number',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textDisabled,
          fontSize: 14,
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
        counterText: '', // Disable character counter
      ),
      onChanged: (value) {
        provider.handleNumberChanged(value);
      },
    );
  }

  void _showCountryPicker(
    BuildContext context,
    ImprovedPhoneFieldProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCountry: provider.selectedCountry,
        onCountrySelected: (country) {
          provider.updateCountry(country);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Provider for country picker search state
class _CountryPickerProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Country> _filteredCountries = countries;

  List<Country> get filteredCountries => _filteredCountries;

  _CountryPickerProvider() {
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    filterCountries(searchController.text);
  }

  void filterCountries(String query) {
    if (query.isEmpty) {
      _filteredCountries = countries;
    } else {
      _filteredCountries = countries.where((country) {
        return country.name.toLowerCase().contains(query.toLowerCase()) ||
            country.dialCode.contains(query) ||
            country.code.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}

/// Country picker bottom sheet using Provider
class _CountryPickerSheet extends StatelessWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  String _countryCodeToEmoji(String countryCode) {
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _CountryPickerProvider(),
      child: Consumer<_CountryPickerProvider>(
        builder: (context, pickerProvider, child) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select Country',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: pickerProvider.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Country list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: pickerProvider.filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = pickerProvider.filteredCountries[index];
                        final isSelected = country.code == selectedCountry.code;

                        return ListTile(
                          leading: Text(
                            _countryCodeToEmoji(country.code),
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            country.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Text(
                            '+${country.dialCode}',
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          onTap: () => onCountrySelected(country),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
