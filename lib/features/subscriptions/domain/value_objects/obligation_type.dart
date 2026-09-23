/// Represents the classification/type of a recurring financial obligation.
///
/// Distinguishes between digital subscriptions, household utility bills,
/// property rent, and general recurring commitments.
/// Pure Dart value object with zero external dependencies.
enum ObligationType {
  /// Digital service or software subscription (e.g. Netflix, Spotify, ChatGPT).
  subscription,

  /// Recurring utility or service bill (e.g. Electricity, Water, Internet).
  bill,

  /// Residential or commercial rent payment.
  rent,

  /// General recurring financial obligation or installment.
  other;

  /// User-facing localized Arabic display label.
  String get displayNameArabic {
    switch (this) {
      case ObligationType.subscription:
        return 'اشتراك';
      case ObligationType.bill:
        return 'فاتورة';
      case ObligationType.rent:
        return 'إيجار';
      case ObligationType.other:
        return 'التزام آخر';
    }
  }

  /// User-facing English display label.
  String get displayNameEnglish {
    switch (this) {
      case ObligationType.subscription:
        return 'Subscription';
      case ObligationType.bill:
        return 'Bill';
      case ObligationType.rent:
        return 'Rent';
      case ObligationType.other:
        return 'Other';
    }
  }

  /// Safe deserialization from string with fallback to [ObligationType.subscription].
  static ObligationType fromString(String? raw) {
    if (raw == null) return ObligationType.subscription;
    switch (raw.trim().toLowerCase()) {
      case 'subscription':
        return ObligationType.subscription;
      case 'bill':
      case 'utility':
        return ObligationType.bill;
      case 'rent':
        return ObligationType.rent;
      case 'other':
      case 'obligation':
        return ObligationType.other;
      default:
        return ObligationType.subscription;
    }
  }
}
