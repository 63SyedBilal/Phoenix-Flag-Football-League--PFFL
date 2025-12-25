class PaymentState {
  final String cardholderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String zipCode;
  final bool agreedToTerms;

  final String? cardholderNameError;
  final String? cardNumberError;
  final String? expiryDateError;
  final String? cvvError;
  final String? zipCodeError;
  final String? agreementError;
  final String? generalError;

  final bool isLoading;

  const PaymentState({
    this.cardholderName = '',
    this.cardNumber = '',
    this.expiryDate = '',
    this.cvv = '',
    this.zipCode = '',
    this.agreedToTerms = false,
    this.cardholderNameError,
    this.cardNumberError,
    this.expiryDateError,
    this.cvvError,
    this.zipCodeError,
    this.agreementError,
    this.generalError,
    this.isLoading = false,
  });

  bool get isFormValid {
    return cardholderNameError == null &&
        cardNumberError == null &&
        expiryDateError == null &&
        cvvError == null &&
        zipCodeError == null &&
        agreementError == null &&
        cardholderName.isNotEmpty &&
        cardNumber.isNotEmpty &&
        expiryDate.isNotEmpty &&
        cvv.isNotEmpty &&
        agreedToTerms;
  }

  PaymentState copyWith({
    String? cardholderName,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? zipCode,
    bool? agreedToTerms,
    String? cardholderNameError,
    String? cardNumberError,
    String? expiryDateError,
    String? cvvError,
    String? zipCodeError,
    String? agreementError,
    String? generalError,
    bool? isLoading,
    bool clearCardholderNameError = false,
    bool clearCardNumberError = false,
    bool clearExpiryDateError = false,
    bool clearCvvError = false,
    bool clearZipCodeError = false,
    bool clearAgreementError = false,
    bool clearGeneralError = false,
  }) {
    return PaymentState(
      cardholderName: cardholderName ?? this.cardholderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      zipCode: zipCode ?? this.zipCode,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      cardholderNameError: clearCardholderNameError
          ? null
          : (cardholderNameError ?? this.cardholderNameError),
      cardNumberError: clearCardNumberError
          ? null
          : (cardNumberError ?? this.cardNumberError),
      expiryDateError: clearExpiryDateError
          ? null
          : (expiryDateError ?? this.expiryDateError),
      cvvError: clearCvvError ? null : (cvvError ?? this.cvvError),
      zipCodeError: clearZipCodeError
          ? null
          : (zipCodeError ?? this.zipCodeError),
      agreementError: clearAgreementError
          ? null
          : (agreementError ?? this.agreementError),
      generalError: clearGeneralError
          ? null
          : (generalError ?? this.generalError),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
