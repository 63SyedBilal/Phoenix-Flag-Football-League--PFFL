class PaymentValidators {
  static String? validateCardholderName(String value) {
    if (value.isEmpty) return 'Cardholder name is required';
    return null;
  }

  static String? validateCardNumber(String value) {
    if (value.isEmpty) return 'Card number is required';
    if (value.replaceAll(' ', '').length < 16) return 'Invalid card number';
    return null;
  }

  static String? validateExpiryDate(String value) {
    if (value.isEmpty) return 'Expiry date is required';
    if (!value.contains('/') || value.length < 5)
      return 'Invalid expiry date (MM/YY)';
    return null;
  }

  static String? validateCvv(String value) {
    if (value.isEmpty) return 'CVV is required';
    if (value.length < 3) return 'Invalid CVV';
    return null;
  }

  static String? validateZipCode(String value) {
    if (value.isEmpty) return 'ZIP/Postal code is required';
    if (value.length < 5) return 'Invalid ZIP/Postal Code';
    return null;
  }

  static String? validateAgreement(bool value) {
    if (!value) return 'You must agree to the Terms & Privacy';
    return null;
  }
}
