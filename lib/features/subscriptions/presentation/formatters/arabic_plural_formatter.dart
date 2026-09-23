/// Pure utility functions for authentic Arabic grammatical pluralization.
///
/// Complies with standard Arabic grammar (مفرد، مثنى، جمع قلة، تمييز مفرد منصوب).
class ArabicPluralFormatter {
  const ArabicPluralFormatter._();

  /// Formats payment counts according to Arabic grammar rules.
  ///
  /// Examples:
  /// - 0: 'لا توجد دفعات'
  /// - 1: 'دفعة واحدة'
  /// - 2: 'دفعتان'
  /// - 3..10: '3 دفعات' .. '10 دفعات'
  /// - 11+: '11 دفعة' .. '100 دفعة'
  static String formatPaymentsCount(int count) {
    if (count <= 0) return 'لا توجد دفعات';
    if (count == 1) return 'دفعة واحدة';
    if (count == 2) return 'دفعتان';
    if (count >= 3 && count <= 10) return '$count دفعات';
    return '$count دفعة';
  }

  /// Formats days remaining according to Arabic grammar rules.
  ///
  /// Examples:
  /// - 0: 'اليوم'
  /// - 1: 'يوم واحد'
  /// - 2: 'يومان'
  /// - 3..10: '5 أيام'
  /// - 11+: '15 يوماً'
  /// - negative: 'متأخر'
  static String formatDaysRemaining(int days) {
    if (days < 0) {
      final abs = days.abs();
      if (abs == 1) return 'متأخر منذ يوم واحد';
      if (abs == 2) return 'متأخر منذ يومين';
      if (abs >= 3 && abs <= 10) return 'متأخر منذ $abs أيام';
      return 'متأخر منذ $abs يوماً';
    }
    if (days == 0) return 'اليوم';
    if (days == 1) return 'غداً';
    if (days == 2) return 'خلال يومين';
    if (days >= 3 && days <= 10) return 'خلال $days أيام';
    return 'خلال $days يوماً';
  }
}
