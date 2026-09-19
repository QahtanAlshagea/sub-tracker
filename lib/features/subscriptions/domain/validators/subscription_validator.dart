import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../failures/subscription_failures.dart';
import '../value_objects/billing_cycle.dart';

/// Pure domain validation rules for Subscriptions.
/// Implements BR-01, BR-02, BR-03, BR-04, BR-06, BR-10 and EC-01..EC-04.
/// Pure Dart — zero dependencies on Flutter or persistence.
class SubscriptionValidator {
  const SubscriptionValidator._();

  /// Maximum allowed characters for subscription name (BR-01).
  static const int maxNameLength = 60;

  /// Maximum allowed minor units (BR-03: 999,999,999.99 * 100).
  static const int maxPriceMinorUnits = 99999999999;

  /// Maximum allowed characters for notes (BR-06, EC-04-1).
  static const int maxNotesLength = 500;

  /// Maximum allowed characters for payment method description.
  static const int maxPaymentMethodLength = 50;

  /// Minimum and maximum days for custom billing cycle (BR-04).
  static const int minCustomCycleDays = 1;
  static const int maxCustomCycleDays = 3650;

  /// Minimum and maximum days for reminder lead time (BR-10).
  static const int minReminderLeadDays = 0;
  static const int maxReminderLeadDays = 30;

  /// Validates subscription name according to BR-01 and EC-01-1..EC-01-4.
  static Result<String> validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Error(SubscriptionValidationFailure.emptyName());
    }
    // Count user-perceived characters / unicode code points
    if (trimmed.runes.length > maxNameLength) {
      return Error(SubscriptionValidationFailure.nameTooLong());
    }
    return Success(trimmed);
  }

  /// Validates subscription price according to BR-02, BR-03, and EC-02-1.
  static Result<int> validatePrice(
    int priceMinorUnits, {
    required bool isTrial,
  }) {
    if (priceMinorUnits < 0) {
      return Error(SubscriptionValidationFailure.negativePrice());
    }
    if (priceMinorUnits == 0 && !isTrial) {
      return Error(SubscriptionValidationFailure.zeroPriceNonTrial());
    }
    if (priceMinorUnits > maxPriceMinorUnits) {
      return Error(SubscriptionValidationFailure.priceTooHigh());
    }
    return Success(priceMinorUnits);
  }

  /// Validates ISO 4217 3-letter currency code.
  static Result<String> validateCurrencyCode(String currencyCode) {
    final trimmed = currencyCode.trim();
    final regex = RegExp(r'^[A-Z]{3}$');
    if (!regex.hasMatch(trimmed)) {
      return Error(SubscriptionValidationFailure.invalidCurrencyCode());
    }
    return Success(trimmed);
  }

  /// Validates custom cycle days (BR-04, EC-03-1, EC-03-2).
  static Result<int> validateCustomDays(int? days) {
    if (days == null ||
        days < minCustomCycleDays ||
        days > maxCustomCycleDays) {
      return Error(SubscriptionValidationFailure.invalidCustomCycleDays());
    }
    return Success(days);
  }

  /// Validates billing cycle invariants according to BR-04 and EC-03-1..EC-03-2.
  static Result<BillingCycle> validateBillingCycle(BillingCycle cycle) {
    if (cycle.type == CycleType.custom) {
      final daysResult = validateCustomDays(cycle.customDays);
      if (daysResult.isFailure) {
        return Error(daysResult.failureOrNull!);
      }
    }
    return Success(cycle);
  }

  /// Validates notes according to BR-06 and EC-04-1.
  static Result<String?> validateNotes(String? notes) {
    if (notes == null) return const Success(null);
    final trimmed = notes.trim();
    if (trimmed.runes.length > maxNotesLength) {
      return Error(SubscriptionValidationFailure.notesTooLong());
    }
    return Success(trimmed.isEmpty ? null : trimmed);
  }

  /// Validates renewal URL format according to BR-06 and EC-04-2.
  static Result<String?> validateRenewalUrl(String? url) {
    if (url == null) return const Success(null);
    final trimmed = url.trim();
    if (trimmed.isEmpty) return const Success(null);

    final uri = Uri.tryParse(trimmed);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;

    if (!isValid) {
      return Error(SubscriptionValidationFailure.invalidUrl());
    }
    return Success(trimmed);
  }

  /// Validates payment method description according to EC-04-4.
  /// Prevents users from storing sensitive credit card numbers.
  static Result<String?> validatePaymentMethodDesc(String? desc) {
    if (desc == null) return const Success(null);
    final trimmed = desc.trim();
    if (trimmed.isEmpty) return const Success(null);

    if (trimmed.runes.length > maxPaymentMethodLength) {
      return Error(SubscriptionValidationFailure.paymentMethodDescTooLong());
    }

    if (containsCreditCardNumber(trimmed)) {
      return Error(SubscriptionValidationFailure.creditCardDetected());
    }

    return Success(trimmed);
  }

  /// Validates reminder configuration according to BR-10 and EC-03-4.
  static Result<void> validateReminderSettings({
    required bool reminderEnabled,
    required int reminderLeadDays,
    required int reminderTimeHour,
    required int reminderTimeMinute,
    required BillingCycle cycle,
  }) {
    if (!reminderEnabled) {
      return const Success(null);
    }

    if (reminderLeadDays < minReminderLeadDays ||
        reminderLeadDays > maxReminderLeadDays) {
      return Error(SubscriptionValidationFailure.invalidReminderLeadDays());
    }

    if (reminderTimeHour < 0 ||
        reminderTimeHour > 23 ||
        reminderTimeMinute < 0 ||
        reminderTimeMinute > 59) {
      return Error(SubscriptionValidationFailure.invalidReminderTime());
    }

    // EC-03-4: If cycle is daily (1 day), reminder lead days cannot exceed cycle duration
    final cycleDays = cycle.approximateDays;
    if (cycleDays <= 1 && reminderLeadDays > 1) {
      return Error(SubscriptionValidationFailure.leadDaysExceedCycle());
    }

    return const Success(null);
  }

  /// Validates an entire [Subscription] entity.
  static Result<void> validateSubscription(Subscription subscription) {
    final nameResult = validateName(subscription.name);
    if (nameResult.isFailure) return Error(nameResult.failureOrNull!);

    final priceResult = validatePrice(
      subscription.price.minorUnits,
      isTrial: subscription.isTrial,
    );
    if (priceResult.isFailure) return Error(priceResult.failureOrNull!);

    final currencyResult = validateCurrencyCode(
      subscription.price.currencyCode,
    );
    if (currencyResult.isFailure) return Error(currencyResult.failureOrNull!);

    final cycleResult = validateBillingCycle(subscription.cycle);
    if (cycleResult.isFailure) return Error(cycleResult.failureOrNull!);

    final notesResult = validateNotes(subscription.notes);
    if (notesResult.isFailure) return Error(notesResult.failureOrNull!);

    final urlResult = validateRenewalUrl(subscription.renewalUrl);
    if (urlResult.isFailure) return Error(urlResult.failureOrNull!);

    final paymentResult = validatePaymentMethodDesc(
      subscription.paymentMethodDesc,
    );
    if (paymentResult.isFailure) return Error(paymentResult.failureOrNull!);

    final reminderResult = validateReminderSettings(
      reminderEnabled: subscription.reminderEnabled,
      reminderLeadDays: subscription.reminderLeadDays,
      reminderTimeHour: subscription.reminderTimeHour,
      reminderTimeMinute: subscription.reminderTimeMinute,
      cycle: subscription.cycle,
    );
    if (reminderResult.isFailure) return Error(reminderResult.failureOrNull!);

    if (subscription.originalAnchorDay < 1 ||
        subscription.originalAnchorDay > 31) {
      return Error(SubscriptionValidationFailure.invalidAnchorDay());
    }

    return const Success(null);
  }

  /// Helper to convert Arabic-Indic and Eastern Arabic digits to ASCII digits (EC-02-4).
  static String normalizeDigits(String input) {
    const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
    const easternArabic = '۰۱۲۳۴۵۶۷۸۹';
    const western = '0123456789';

    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final idxArabic = arabicIndic.indexOf(char);
      if (idxArabic != -1) {
        buffer.write(western[idxArabic]);
        continue;
      }
      final idxEastern = easternArabic.indexOf(char);
      if (idxEastern != -1) {
        buffer.write(western[idxEastern]);
        continue;
      }
      buffer.write(char);
    }
    return buffer.toString();
  }

  /// Scans a text string for 13-19 digit card numbers (EC-04-4).
  static bool containsCreditCardNumber(String input) {
    // Normalise any Arabic-Indic digits first
    final normalized = normalizeDigits(input);

    // Look for 13 to 19 digits potentially grouped by spaces or hyphens
    final cardRegex = RegExp(r'(?:\d[ -]?){13,19}');
    for (final match in cardRegex.allMatches(normalized)) {
      final candidate = match.group(0)!.replaceAll(RegExp(r'[\s-]'), '');
      if (candidate.length >= 13 && candidate.length <= 19) {
        return true;
      }
    }
    return false;
  }

  /// Checks whether a numeric string satisfies the Luhn algorithm checksum.
  static bool passesLuhn(String digits) {
    int sum = 0;
    bool alternate = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }
}
