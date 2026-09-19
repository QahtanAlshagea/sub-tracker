import '../../domain/value_objects/billing_cycle.dart';
import '../../domain/value_objects/due_date.dart';
import '../../domain/value_objects/money.dart';

/// Due date urgency classification for visual badges and alerts.
enum DueDateUrgency {
  /// The renewal date has already passed.
  overdue,

  /// The renewal date is within 3 days or today (EC-05-2).
  urgent,

  /// The renewal date is more than 3 days in the future.
  normal,
}

/// Central formatters for dates, currencies, recurrence cycles, and indicators.
abstract final class SubscriptionFormatters {
  /// Normalizes Arabic-Indic numerals (٠-٩) and commas to standard Western digits (0-9) and dot.
  /// Strictly satisfies [EC-02-4].
  static String normalizeNumerals(String input) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String output = input.replaceAll('،', '.').replaceAll(',', '.');
    for (int i = 0; i < 10; i++) {
      output = output.replaceAll(arabicIndic[i], western[i]);
    }
    return output;
  }

  /// Formats a [Money] value object into a localized display string.
  /// (e.g. "$ 9.99" or "1,200.00 ر.س").
  static String formatMoney(Money money) {
    final double major = money.amountMinorUnits / 100.0;
    final String majorFormatted = formatNumberWithCommas(major);
    final String symbol = getCurrencySymbol(money.currencyCode);

    return '$majorFormatted $symbol'.trim();
  }

  /// Returns localized currency symbol or ISO code.
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'YER':
        return 'ر.ي';
      case 'KWD':
        return 'د.ك';
      case 'EGP':
        return 'ج.م';
      default:
        return currencyCode;
    }
  }

  /// Formats a double into a string with 2 decimal places and thousands grouping.
  static String formatNumberWithCommas(double number) {
    final parts = number.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final buffer = StringBuffer();
    final len = integerPart.length;

    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }

    return '${buffer.toString()}.$decimalPart';
  }

  /// Formats [BillingCycle] into Arabic representation.
  static String formatCycle(BillingCycle cycle) {
    switch (cycle.type) {
      case CycleType.monthly:
        return 'شهرياً';
      case CycleType.yearly:
        return 'سنوياً';
      case CycleType.weekly:
        return 'أسبوعياً';
      case CycleType.custom:
        final days = cycle.customDays ?? 30;
        return 'كل $days يوم';
    }
  }

  /// Formats a cycle prefix for pricing (e.g. "/ شهرياً").
  static String formatCycleSuffix(BillingCycle cycle) {
    switch (cycle.type) {
      case CycleType.monthly:
        return '/ شهر';
      case CycleType.yearly:
        return '/ سنة';
      case CycleType.weekly:
        return '/ أسبوع';
      case CycleType.custom:
        final days = cycle.customDays ?? 30;
        return '/ $days يوم';
    }
  }

  /// Calculates calendar days remaining until [dueDate] from [referenceDate].
  static int calculateDaysRemaining(
    DueDate dueDate, [
    DateTime? referenceDate,
  ]) {
    final now = (referenceDate ?? DateTime.now()).toUtc();
    final todayMidnight = DateTime.utc(now.year, now.month, now.day);
    final dueMidnight = DateTime.utc(
      dueDate.date.year,
      dueDate.date.month,
      dueDate.date.day,
    );

    return dueMidnight.difference(todayMidnight).inDays;
  }

  /// Determines urgency level based on days remaining.
  static DueDateUrgency getUrgency(DueDate dueDate, [DateTime? referenceDate]) {
    final days = calculateDaysRemaining(dueDate, referenceDate);
    if (days < 0) return DueDateUrgency.overdue;
    if (days <= 3) return DueDateUrgency.urgent;
    return DueDateUrgency.normal;
  }

  /// Formats the remaining days until due date into user-friendly Arabic text.
  static String formatDueRemaining(DueDate dueDate, [DateTime? referenceDate]) {
    final days = calculateDaysRemaining(dueDate, referenceDate);

    if (days < 0) {
      final absDays = days.abs();
      if (absDays == 1) return 'متأخر منذ يوم';
      if (absDays == 2) return 'متأخر منذ يومين';
      if (absDays <= 10) return 'متأخر منذ $absDays أيام';
      return 'متأخر منذ $absDays يوماً';
    }

    if (days == 0) return 'يستحق اليوم';
    if (days == 1) return 'يستحق غداً';
    if (days == 2) return 'يستحق بعد يومين';
    if (days <= 10) return 'متبقي $days أيام';
    return 'متبقي $days يوماً';
  }

  /// Formats DateTime into standard YYYY/MM/DD.
  static String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }
}
