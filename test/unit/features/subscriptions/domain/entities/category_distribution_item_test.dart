import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category_distribution_item.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group(
    'CategoryDistributionItem & CategoryDistributionResult Entity Tests',
    () {
      test(
        'CategoryDistributionItem assertions, equality, hashCode and toString',
        () {
          final item1 = CategoryDistributionItem(
            categoryId: 'cat-1',
            categoryName: 'Entertainment',
            colorValue: 0xFF112233,
            iconCode: 'movie',
            totalMonthlyEquivalent: const Money(
              amountMinorUnits: 5000,
              currencyCode: 'USD',
            ),
            percentage: 50.0,
            subscriptionsCount: 2,
            isUncategorized: false,
          );

          final item2 = CategoryDistributionItem(
            categoryId: 'cat-1',
            categoryName: 'Entertainment',
            colorValue: 0xFF112233,
            iconCode: 'movie',
            totalMonthlyEquivalent: const Money(
              amountMinorUnits: 5000,
              currencyCode: 'USD',
            ),
            percentage: 50.0,
            subscriptionsCount: 2,
            isUncategorized: false,
          );

          final itemDiff = CategoryDistributionItem(
            categoryId: 'cat-2',
            categoryName: 'Utilities',
            colorValue: 0xFF445566,
            iconCode: 'bolt',
            totalMonthlyEquivalent: const Money(
              amountMinorUnits: 2500,
              currencyCode: 'USD',
            ),
            percentage: 25.0,
            subscriptionsCount: 1,
            isUncategorized: false,
          );

          expect(item1, equals(item2));
          expect(item1.hashCode, equals(item2.hashCode));
          expect(item1, isNot(equals(itemDiff)));
          expect(item1 == Object(), isFalse);
          expect(
            item1.toString(),
            contains('CategoryDistributionItem(Entertainment'),
          );

          expect(
            () => CategoryDistributionItem(
              categoryId: 'cat-err',
              categoryName: 'Error',
              colorValue: 0,
              totalMonthlyEquivalent: Money.zero('USD'),
              percentage: 150.0,
              subscriptionsCount: 1,
            ),
            throwsA(isA<AssertionError>()),
          );

          expect(
            () => CategoryDistributionItem(
              categoryId: 'cat-err',
              categoryName: 'Error',
              colorValue: 0,
              totalMonthlyEquivalent: Money.zero('USD'),
              percentage: 50.0,
              subscriptionsCount: -1,
            ),
            throwsA(isA<AssertionError>()),
          );
        },
      );

      test(
        'CategoryDistributionResult empty, equality, hashCode, and toString',
        () {
          final emptyResult = CategoryDistributionResult.empty('USD');
          expect(emptyResult.currencyCode, 'USD');
          expect(emptyResult.isEmpty, isTrue);
          expect(emptyResult.items, isEmpty);
          expect(emptyResult.totalMonthlyEquivalent.amountMinorUnits, 0);

          final item = CategoryDistributionItem(
            categoryId: 'cat-1',
            categoryName: 'Entertainment',
            colorValue: 0xFF112233,
            totalMonthlyEquivalent: const Money(
              amountMinorUnits: 5000,
              currencyCode: 'USD',
            ),
            percentage: 100.0,
            subscriptionsCount: 1,
          );

          final res1 = CategoryDistributionResult(
            currencyCode: 'USD',
            totalMonthlyEquivalent: const Money(
              amountMinorUnits: 5000,
              currencyCode: 'USD',
            ),
            items: [item],
          );

          final res2 = CategoryDistributionResult(
            currencyCode: 'USD',
            totalMonthlyEquivalent: const Money(
              amountMinorUnits: 5000,
              currencyCode: 'USD',
            ),
            items: [item],
          );

          expect(res1, equals(res2));
          expect(res1.hashCode, equals(res2.hashCode));
          expect(res1.isEmpty, isFalse);
          expect(res1.toString(), contains('CategoryDistributionResult(USD'));
        },
      );
    },
  );
}
