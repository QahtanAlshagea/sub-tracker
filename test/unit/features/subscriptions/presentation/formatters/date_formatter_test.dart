import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/presentation/formatters/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    late AppLocalizations l10nAr;
    late AppLocalizations l10nEn;

    setUpAll(() async {
      l10nAr = await AppLocalizations.delegate.load(const Locale('ar'));
      l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('formatDate outputs standard ISO YYYY-MM-DD', () {
      final date = DateTime.utc(2026, 9, 25, 14, 30);
      expect(DateFormatter.formatDate(date), equals('2026-09-25'));
    });

    test('formatRemainingDays formats positive days remaining correctly', () {
      expect(
        DateFormatter.formatRemainingDays(5, l10nAr),
        equals('باقٍ 5 يوم'),
      );
      expect(
        DateFormatter.formatRemainingDays(5, l10nEn),
        equals('5 days left'),
      );
    });

    test('formatRemainingDays formats due today correctly', () {
      expect(
        DateFormatter.formatRemainingDays(0, l10nAr),
        equals('يستحق اليوم'),
      );
      expect(DateFormatter.formatRemainingDays(0, l10nEn), equals('Due today'));
    });

    test('formatRemainingDays formats overdue negative days correctly', () {
      expect(
        DateFormatter.formatRemainingDays(-3, l10nAr),
        equals('متأخر 3 يوم'),
      );
      expect(
        DateFormatter.formatRemainingDays(-3, l10nEn),
        equals('3 days overdue'),
      );
    });

    test('formatCycle formats billing cycle correctly', () {
      expect(
        DateFormatter.formatCycle(BillingCycle.monthly(), l10nAr),
        equals('شهرياً'),
      );
      expect(
        DateFormatter.formatCycle(BillingCycle.yearly(), l10nEn),
        equals('Yearly'),
      );
      expect(
        DateFormatter.formatCycle(BillingCycle.weekly(), l10nAr),
        equals('أسبوعياً'),
      );
      expect(
        DateFormatter.formatCycle(BillingCycle.custom(1), l10nEn),
        equals('Custom Cycle'),
      );
      expect(
        DateFormatter.formatCycle(BillingCycle.custom(45), l10nAr),
        equals('دورية مخصصة'),
      );
    });
  });
}
