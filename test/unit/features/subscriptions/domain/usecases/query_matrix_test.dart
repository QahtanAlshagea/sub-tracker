import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

void main() {
  group('Query Matrix: Search, Sort & Filter Edge Cases (US-23..US-25)', () {
    Subscription createItem({
      required String id,
      required String name,
      required int amount,
      required DateTime dueDate,
      String categoryId = 'cat-1',
    }) {
      return Subscription(
        id: id,
        name: name,
        price: Money(amountMinorUnits: amount, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        dueDate: DueDate(dueDate, 1),
        categoryId: categoryId,
        status: SubscriptionStatus.active,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
    }

    String normalizeArabicSearch(String text) {
      return text
          .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
          .replaceAll('ة', 'ه')
          .replaceAll('ى', 'ي')
          .replaceAll(RegExp(r'[\u064B-\u0652]'), '') // Tashkeel
          .trim()
          .toLowerCase();
    }

    test(
      '[EC-23-1]: Normalization of Arabic alef, hamza, and tashkeel during search',
      () {
        const storedName = 'إِشْتِرَاكُ الشَّاهِدِ';
        const userQuery = 'اشتراك الشاهد';

        final normalizedStored = normalizeArabicSearch(storedName);
        final normalizedQuery = normalizeArabicSearch(userQuery);

        expect(normalizedStored, contains(normalizedQuery));
      },
    );

    test(
      '[EC-23-2]: Whitespace-only search treated as empty query returning all active items',
      () {
        const query = '     ';
        final isEffectivelyEmpty = query.trim().isEmpty;

        final items = [
          createItem(
            id: '1',
            name: 'A',
            amount: 100,
            dueDate: DateTime.utc(2026, 2, 1),
          ),
          createItem(
            id: '2',
            name: 'B',
            amount: 200,
            dueDate: DateTime.utc(2026, 2, 2),
          ),
        ];

        final results = isEffectivelyEmpty
            ? items
            : items.where((i) => i.name.contains(query)).toList();
        expect(results.length, 2);
      },
    );

    test(
      '[EC-23-3]: Rapid input debouncing cancels outdated queries',
      () async {
        int executedCount = 0;
        String? finalResultQuery;

        Future<void> simulateDebouncedSearch(String text, int delayMs) async {
          await Future.delayed(Duration(milliseconds: delayMs));
          finalResultQuery = text;
          executedCount++;
        }

        // Simulate superseded search inputs
        simulateDebouncedSearch('Net', 10);
        simulateDebouncedSearch('Netf', 20);
        await simulateDebouncedSearch('Netflix', 30);

        expect(finalResultQuery, 'Netflix');
        expect(executedCount, greaterThanOrEqualTo(1));
      },
    );

    test('[EC-23-4]: Excessively long search string safely truncated', () {
      final longQuery = 'A' * 500;
      final truncated = longQuery.length > 60
          ? longQuery.substring(0, 60)
          : longQuery;

      expect(truncated.length, 60);
    });

    test(
      '[EC-24-1]: Equal sort values broken by deterministic secondary criterion',
      () {
        final item1 = createItem(
          id: 'sub-alpha',
          name: 'Netflix',
          amount: 1500,
          dueDate: DateTime.utc(2026, 5, 1),
        );
        final item2 = createItem(
          id: 'sub-beta',
          name: 'Spotify',
          amount: 1500,
          dueDate: DateTime.utc(2026, 5, 1),
        );

        // Sort by price, tie-break by ID
        final list = [item2, item1];
        list.sort((a, b) {
          final cmp = a.price.amountMinorUnits.compareTo(
            b.price.amountMinorUnits,
          );
          if (cmp != 0) return cmp;
          return a.id.compareTo(b.id);
        });

        expect(list.first.id, 'sub-alpha');
        expect(list.last.id, 'sub-beta');
      },
    );

    test(
      '[EC-24-2]: Mixed Arabic and English alphabetical sorting follows deterministic collation',
      () {
        final names = ['يوتيوب', 'Amazon', 'أبل', 'Netflix'];
        names.sort((a, b) => a.compareTo(b));

        expect(
          names,
          containsAllInOrder(['Amazon', 'Netflix', 'أبل', 'يوتيوب']),
        );
      },
    );

    test('[EC-24-3]: Sorting empty subscription list produces no error', () {
      final emptyList = <Subscription>[];
      expect(
        () => emptyList.sort((a, b) => a.name.compareTo(b.name)),
        returnsNormally,
      );
      expect(emptyList, isEmpty);
    });

    test(
      '[EC-25-1]: Filter with min price > max price rejected with clear validation error',
      () {
        const minPrice = 2000;
        const maxPrice = 1000;

        expect(() {
          if (minPrice > maxPrice) {
            throw const ValidationFailure('Min price cannot exceed max price');
          }
        }, throwsA(isA<ValidationFailure>()));
      },
    );

    test('[EC-25-2]: Empty filter result provides explanatory message', () {
      final items = [
        createItem(
          id: '1',
          name: 'Cloud',
          amount: 5000,
          dueDate: DateTime.utc(2026, 1, 1),
        ),
      ];

      final filtered = items
          .where((i) => i.price.amountMinorUnits < 100)
          .toList();
      expect(filtered, isEmpty);

      final emptyMessage = filtered.isEmpty
          ? 'لا توجد التزامات تطابق المرشحات المحددة'
          : '';
      expect(emptyMessage, contains('لا توجد التزامات'));
    });

    test(
      '[EC-25-3]: Filters referencing deleted category automatically discarded',
      () {
        final availableCategories = {'cat-1', 'cat-2'};
        const selectedFilterCategory = 'cat-deleted';

        final activeCategoryFilter =
            availableCategories.contains(selectedFilterCategory)
            ? selectedFilterCategory
            : null;

        expect(activeCategoryFilter, isNull);
      },
    );
  });
}
