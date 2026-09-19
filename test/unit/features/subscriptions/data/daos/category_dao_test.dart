import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/features/subscriptions/data/daos/category_dao.dart';
import 'package:sub_tracker/features/subscriptions/data/daos/subscription_dao.dart';

void main() {
  late AppDatabase db;
  late CategoryDao categoryDao;
  late SubscriptionDao subscriptionDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    categoryDao = db.categoryDao;
    subscriptionDao = db.subscriptionDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryDao CRUD & Streams (C-12)', () {
    test('getAllCategories returns seeded system category initially', () async {
      final categories = await categoryDao.getAllCategories();
      expect(categories.length, equals(1));
      expect(categories.first.id, equals(kSystemUncategorizedId));
      expect(categories.first.isSystem, isTrue);
    });

    test(
      'insertCategory inserts custom category and getCategoryById finds it',
      () async {
        await categoryDao.insertCategory(
          CategoriesCompanion.insert(
            id: 'cat_entertainment',
            name: 'ترفيه',
            colorValue: 0xFFFF0000,
            createdAt: DateTime.now().toUtc(),
          ),
        );

        final found = await categoryDao.getCategoryById('cat_entertainment');
        expect(found, isNotNull);
        expect(found!.name, equals('ترفيه'));
        expect(found.isSystem, isFalse);

        final foundByName = await categoryDao.getCategoryByName('ترفيه');
        expect(foundByName, isNotNull);
        expect(foundByName!.id, equals('cat_entertainment'));
      },
    );

    test('updateCategory modifies category attributes', () async {
      await categoryDao.insertCategory(
        CategoriesCompanion.insert(
          id: 'cat_work',
          name: 'عمل',
          colorValue: 0xFF00FF00,
          createdAt: DateTime.now().toUtc(),
        ),
      );

      await categoryDao.updateCategory(
        CategoriesCompanion(
          id: const Value('cat_work'),
          name: const Value('عمل ومشاريع'),
          colorValue: const Value(0xFF0000FF),
        ),
      );

      final updated = await categoryDao.getCategoryById('cat_work');
      expect(updated!.name, equals('عمل ومشاريع'));
      expect(updated.colorValue, equals(0xFF0000FF));
    });

    test('deleteCategory deletes empty custom category', () async {
      await categoryDao.insertCategory(
        CategoriesCompanion.insert(
          id: 'cat_temporary',
          name: 'مؤقت',
          colorValue: 0xFF123456,
          createdAt: DateTime.now().toUtc(),
        ),
      );

      final rowsDeleted = await categoryDao.deleteCategory('cat_temporary');
      expect(rowsDeleted, equals(1));

      final check = await categoryDao.getCategoryById('cat_temporary');
      expect(check, isNull);
    });

    test('watchAllCategories emits updates reactively', () async {
      final stream = categoryDao.watchAllCategories();
      expect(await stream.first, hasLength(1));

      await categoryDao.insertCategory(
        CategoriesCompanion.insert(
          id: 'cat_stream_test',
          name: 'تصنيف تفاعلي',
          colorValue: 0xFF555555,
          createdAt: DateTime.now().toUtc(),
        ),
      );

      expect(await stream.first, hasLength(2));
    });
  });

  group('CategoryDao Transactions & Rollback (C-12 / EC-40)', () {
    test(
      'safeDeleteCategoryWithReassignment atomically reassigns subscriptions and deletes category',
      () async {
        // 1. Arrange: insert target category and an active subscription linked to it
        await categoryDao.insertCategory(
          CategoriesCompanion.insert(
            id: 'cat_to_delete',
            name: 'فئة سيتم حذفها',
            colorValue: 0xFFAAAAAA,
            createdAt: DateTime.now().toUtc(),
          ),
        );

        await subscriptionDao.insertSubscription(
          SubscriptionsCompanion.insert(
            id: 'sub_reassign_test',
            name: 'اشتراك اختبار إعادة التعيين',
            priceMinorUnits: 1500,
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: DateTime.now().toUtc(),
            nextDueDate: DateTime.now().toUtc(),
            originalAnchorDay: 15,
            categoryId: 'cat_to_delete',
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );

        // Verify subscription belongs to cat_to_delete
        var sub = await subscriptionDao.getSubscriptionById(
          'sub_reassign_test',
        );
        expect(sub!.categoryId, equals('cat_to_delete'));

        // 2. Act: safeDeleteCategoryWithReassignment to system uncategorized category
        await categoryDao.safeDeleteCategoryWithReassignment(
          categoryIdToDelete: 'cat_to_delete',
          fallbackCategoryId: kSystemUncategorizedId,
        );

        // 3. Assert: category deleted, subscription reassigned to system uncategorized
        final deletedCat = await categoryDao.getCategoryById('cat_to_delete');
        expect(deletedCat, isNull);

        sub = await subscriptionDao.getSubscriptionById('sub_reassign_test');
        expect(sub!.categoryId, equals(kSystemUncategorizedId));
      },
    );

    test(
      'safeDeleteCategoryWithReassignment rolls back atomically if deletion fails',
      () async {
        // 1. Arrange: insert target category and subscription
        await categoryDao.insertCategory(
          CategoriesCompanion.insert(
            id: 'cat_rollback',
            name: 'فئة التراجع',
            colorValue: 0xFFBBBBBB,
            createdAt: DateTime.now().toUtc(),
          ),
        );

        await subscriptionDao.insertSubscription(
          SubscriptionsCompanion.insert(
            id: 'sub_rollback',
            name: 'اشتراك التراجع',
            priceMinorUnits: 2000,
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: DateTime.now().toUtc(),
            nextDueDate: DateTime.now().toUtc(),
            originalAnchorDay: 20,
            categoryId: 'cat_rollback',
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );

        // 2. Act: simulate failure by attempting to reassign to a non-existent fallback category
        // Foreign key constraint on subscriptions will fail on update
        expect(
          () => categoryDao.safeDeleteCategoryWithReassignment(
            categoryIdToDelete: 'cat_rollback',
            fallbackCategoryId: 'non_existent_category_id',
          ),
          throwsA(isA<SqliteException>()),
        );

        // 3. Assert (Rollback verification):
        // The transaction must have completely rolled back:
        // cat_rollback is NOT deleted, and sub_rollback still points to cat_rollback
        final cat = await categoryDao.getCategoryById('cat_rollback');
        expect(cat, isNotNull);
        expect(cat!.name, equals('فئة التراجع'));

        final sub = await subscriptionDao.getSubscriptionById('sub_rollback');
        expect(sub, isNotNull);
        expect(sub!.categoryId, equals('cat_rollback'));
      },
    );
  });
}
