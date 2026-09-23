import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/presentation/formatters/arabic_plural_formatter.dart';

void main() {
  group('ArabicPluralFormatter Tests', () {
    test('formatPaymentsCount obeys Arabic plural rules', () {
      expect(
        ArabicPluralFormatter.formatPaymentsCount(0),
        equals('لا توجد دفعات'),
      );
      expect(
        ArabicPluralFormatter.formatPaymentsCount(-1),
        equals('لا توجد دفعات'),
      );
      expect(
        ArabicPluralFormatter.formatPaymentsCount(1),
        equals('دفعة واحدة'),
      );
      expect(ArabicPluralFormatter.formatPaymentsCount(2), equals('دفعتان'));
      expect(ArabicPluralFormatter.formatPaymentsCount(3), equals('3 دفعات'));
      expect(ArabicPluralFormatter.formatPaymentsCount(5), equals('5 دفعات'));
      expect(ArabicPluralFormatter.formatPaymentsCount(10), equals('10 دفعات'));
      expect(ArabicPluralFormatter.formatPaymentsCount(11), equals('11 دفعة'));
      expect(ArabicPluralFormatter.formatPaymentsCount(25), equals('25 دفعة'));
      expect(
        ArabicPluralFormatter.formatPaymentsCount(100),
        equals('100 دفعة'),
      );
    });

    test('formatDaysRemaining obeys Arabic grammar rules', () {
      expect(ArabicPluralFormatter.formatDaysRemaining(0), equals('اليوم'));
      expect(ArabicPluralFormatter.formatDaysRemaining(1), equals('غداً'));
      expect(
        ArabicPluralFormatter.formatDaysRemaining(2),
        equals('خلال يومين'),
      );
      expect(
        ArabicPluralFormatter.formatDaysRemaining(5),
        equals('خلال 5 أيام'),
      );
      expect(
        ArabicPluralFormatter.formatDaysRemaining(14),
        equals('خلال 14 يوماً'),
      );
      expect(
        ArabicPluralFormatter.formatDaysRemaining(-1),
        equals('متأخر منذ يوم واحد'),
      );
      expect(
        ArabicPluralFormatter.formatDaysRemaining(-2),
        equals('متأخر منذ يومين'),
      );
      expect(
        ArabicPluralFormatter.formatDaysRemaining(-4),
        equals('متأخر منذ 4 أيام'),
      );
      expect(
        ArabicPluralFormatter.formatDaysRemaining(-12),
        equals('متأخر منذ 12 يوماً'),
      );
    });
  });
}
