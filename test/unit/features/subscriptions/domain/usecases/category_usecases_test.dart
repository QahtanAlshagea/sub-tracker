import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/usecase/usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/create_category_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/delete_category_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/update_category_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/watch_categories_usecase.dart';

import 'fake_category_repository.dart';

void main() {
  late FakeCategoryRepository repository;

  setUp(() {
    repository = FakeCategoryRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  Category createSampleCategory({
    String id = 'cat-1',
    String name = 'Entertainment',
    int colorValue = 0xFF4F46E5,
    bool isSystem = false,
  }) {
    return Category(
      id: id,
      name: name,
      colorValue: colorValue,
      isSystem: isSystem,
      createdAt: DateTime.utc(2026, 1, 1),
    );
  }

  group('CreateCategoryUseCase Tests (US-21, FR-12, BR-05)', () {
    late CreateCategoryUseCase useCase;

    setUp(() {
      useCase = CreateCategoryUseCase(repository);
    });

    test(
      'US-21: successfully creates and persists valid custom category',
      () async {
        final category = createSampleCategory();
        final result = await useCase(category);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(category));
        expect(repository.categories.containsKey(category.id), isTrue);
      },
    );

    test('BR-05 / [EC-21-2]: fails when category name is empty', () async {
      final category = createSampleCategory(name: '   ');
      final result = await useCase(category);

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(CategoryValidationFailure.emptyName()),
      );
      expect(repository.categories.isEmpty, isTrue);
    });

    test(
      'US-21: fails when category with duplicate normalized name exists',
      () async {
        final existing = createSampleCategory(id: 'cat-exist', name: 'Work');
        repository.categories[existing.id] = existing;

        final duplicate = createSampleCategory(id: 'cat-new', name: '  work  ');
        final result = await useCase(duplicate);

        expect(result.isFailure, isTrue);
        expect(repository.categories.containsKey('cat-new'), isFalse);
      },
    );
  });

  group('UpdateCategoryUseCase Tests (US-21, FR-12, EC-21-3)', () {
    late UpdateCategoryUseCase useCase;

    setUp(() {
      useCase = UpdateCategoryUseCase(repository);
    });

    test('US-21: successfully updates custom category', () async {
      final category = createSampleCategory(name: 'Media');
      repository.categories[category.id] = category;

      final updated = category.copyWith(name: 'Streaming Media');
      final result = await useCase(updated);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.name, equals('Streaming Media'));
    });

    test('EC-21-3: rejects modifying system category', () async {
      final systemCat = Category.systemUncategorized();
      repository.categories[systemCat.id] = systemCat;

      final modified = systemCat.copyWith(name: 'Modified Uncategorized');
      final result = await useCase(modified);

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(CategoryValidationFailure.cannotModifySystemCategory()),
      );
    });

    test('US-21: fails when updating non-existent category', () async {
      final category = createSampleCategory(id: 'cat-ghost');
      final result = await useCase(category);

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(const CategoryNotFoundFailure('cat-ghost')),
      );
    });
  });

  group('GetCategoriesUseCase & WatchCategoriesUseCase Tests (FR-12)', () {
    test('GetCategoriesUseCase returns all registered categories', () async {
      final useCase = GetCategoriesUseCase(repository);
      repository.categories['cat-1'] = createSampleCategory(id: 'cat-1');
      repository.categories['cat-2'] = createSampleCategory(id: 'cat-2');

      final result = await useCase(const NoParams());
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.length, equals(2));
    });

    test('WatchCategoriesUseCase emits stream of categories', () async {
      final useCase = WatchCategoriesUseCase(repository);
      final stream = useCase(const NoParams());

      expectLater(
        stream.map((r) => r.dataOrNull?.length ?? 0),
        emitsInOrder([1]),
      );

      await repository.createCategory(createSampleCategory());
    });
  });

  group('DeleteCategoryUseCase Tests (US-22, FR-12, EC-21-3, EC-22-1..3)', () {
    late DeleteCategoryUseCase useCase;

    setUp(() {
      useCase = DeleteCategoryUseCase(repository);
    });

    test(
      'US-22: successfully deletes category and reassigns to fallback',
      () async {
        final catToDelete = createSampleCategory(
          id: 'cat-delete',
          name: 'Gaming',
        );
        final fallbackCat = Category.systemUncategorized();
        repository.categories[catToDelete.id] = catToDelete;
        repository.categories[fallbackCat.id] = fallbackCat;

        final result = await useCase(
          DeleteCategoryParams(
            categoryId: catToDelete.id,
            fallbackCategoryId: fallbackCat.id,
          ),
        );

        expect(result.isSuccess, isTrue);
        expect(repository.categories.containsKey(catToDelete.id), isFalse);
      },
    );

    test('EC-21-3 / [EC-22-3]: rejects deleting system category', () async {
      final systemCat = Category.systemUncategorized();
      final fallbackCat = createSampleCategory(id: 'cat-user');
      repository.categories[systemCat.id] = systemCat;
      repository.categories[fallbackCat.id] = fallbackCat;

      final result = await useCase(
        DeleteCategoryParams(
          categoryId: systemCat.id,
          fallbackCategoryId: fallbackCat.id,
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(CategoryValidationFailure.cannotModifySystemCategory()),
      );
      expect(repository.categories.containsKey(systemCat.id), isTrue);
    });

    test(
      'EC-22-2: rejects deleting category when fallback is identical to target',
      () async {
        final cat = createSampleCategory(id: 'cat-same');
        repository.categories[cat.id] = cat;

        final result = await useCase(
          DeleteCategoryParams(
            categoryId: 'cat-same',
            fallbackCategoryId: 'cat-same',
          ),
        );

        expect(result.isFailure, isTrue);
      },
    );

    test('EC-22-1: fails when fallback category does not exist', () async {
      final cat = createSampleCategory(id: 'cat-target');
      repository.categories[cat.id] = cat;

      final result = await useCase(
        const DeleteCategoryParams(
          categoryId: 'cat-target',
          fallbackCategoryId: 'cat-ghost',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(const CategoryNotFoundFailure('cat-ghost')),
      );
    });
  });
}
