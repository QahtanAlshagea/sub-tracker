---
name: local-persistence-clean-architecture
description: Enforces strict Clean Architecture isolation for local SQLite/Drift persistence in Sub Tracker. Load this skill for any task touching tables, DAOs, data sources, repository implementations, transactions, migrations, backup/restore, or database error handling.
scope: lib/features/**/data/**, lib/core/database/**
---

# SKILL — Local Persistence under Clean Architecture

## 1. When to load this skill

Load unconditionally when the task mentions any of: Drift, SQLite, table, column, index, DAO, query, insert, update, delete, transaction, migration, schema version, backup, export, import, database error, lock, corruption, or "where do I put this data code".

## 2. Canonical directory layout

```
lib/
├── core/
│   ├── database/
│   │   ├── app_database.dart          # Drift database class + schema version only
│   │   └── migrations/
│   │       └── migration_v1_to_v2.dart
│   └── error/
│       └── failures.dart              # domain-visible failure types
└── features/subscriptions/
    ├── domain/                        # PURE DART — no imports from data/ or flutter/
    │   ├── entities/subscription.dart
    │   ├── value_objects/{money.dart, billing_cycle.dart, due_date.dart}
    │   ├── repositories/subscription_repository.dart      # ABSTRACT ONLY
    │   └── usecases/{add_subscription.dart, ...}
    ├── data/
    │   ├── tables/{subscriptions_table.dart, categories_table.dart, price_history_table.dart}
    │   ├── daos/{subscription_dao.dart, category_dao.dart, price_history_dao.dart}
    │   ├── models/subscription_model.dart                 # mapping + serialization
    │   ├── datasources/subscription_local_data_source.dart
    │   └── repositories/subscription_repository_impl.dart # implements the domain contract
    └── presentation/
```

**Rule:** one responsibility per file. A file that both defines a table and runs a query is a defect, not a shortcut.

## 3. Single Responsibility contract (SRP)

| Component | Allowed to do | Forbidden to do |
|---|---|---|
| **Table** | Declare columns, types, constraints, indexes, primary keys | Contain queries, business logic, mapping, or validation |
| **DAO** | Execute typed queries and transactions against its own table(s) | Know about domain entities, throw domain failures, contain UI or formatting logic |
| **Model** | Map row ↔ entity, handle JSON for backup | Contain business rules or query code |
| **DataSource** | Orchestrate one or more DAOs behind a narrow, intention-revealing API | Be imported by the domain layer, or return raw Drift row types to callers outside `data/` |
| **RepositoryImpl** | Implement the abstract domain contract, map models to entities, convert exceptions to `Failure` | Leak Drift types, expose `Future<T>` that throws low-level exceptions |

## 4. Dependency Inversion contract (DIP)

1. UseCases depend **only** on `domain/repositories/*.dart` abstractions.
2. `RepositoryImpl` is the only class that knows a database exists.
3. Wiring happens at the composition root (`lib/core/di/`), nowhere else.
4. A UseCase importing `drift`, a DAO, or a `RepositoryImpl` is an automatic rejection in code review.
5. Replacing SQLite with any other engine in the future must require changes **only** inside `data/` — zero edits in `domain/` and `presentation/`.

**Verification command (run before every PR):**
```bash
grep -rnE "import .*(flutter|drift|sqflite|dart:io|dart:ui)" lib/**/domain/ && echo "DOMAIN PURITY VIOLATION" || echo "domain clean"
```

## 5. Error translation contract

The data layer catches **everything** and converts. No exception crosses the repository boundary.

| Low-level cause | Domain failure | User-facing behaviour |
|---|---|---|
| `SqliteException` generic | `DatabaseFailure` | Clear error state with retry |
| Row not found | `NotFoundFailure` | "This record no longer exists" + return to list |
| Unique constraint violated | `DuplicateFailure` | Non-blocking duplicate warning (`EC-24`) |
| Database locked / busy timeout | `DatabaseLockFailure` | Exponential retry, then message (`EC-27`) |
| Disk full / write failure | `StorageFullFailure` | Pre-flight message, no partial file (`EC-26`) |
| Malformed or corrupt DB file | `CorruptedDataFailure` | Recovery screen: restore backup / start fresh (`EC-28`) |
| Schema version mismatch | `MigrationFailure` | Auto-upgrade, or refuse newer schema (`EC-30`) |
| Invalid backup JSON | `ValidationFailure` | Reject import, existing data untouched (`EC-29`) |

**Required shape:**
```dart
// data/repositories/subscription_repository_impl.dart
@override
Future<Either<Failure, Subscription>> add(Subscription subscription) async {
  try {
    final model = SubscriptionModel.fromEntity(subscription);
    final saved = await _localDataSource.insert(model);
    return Right(saved.toEntity());
  } on UniqueConstraintException {
    return const Left(DuplicateFailure());
  } on SqliteException catch (e) {
    return Left(DatabaseFailure(code: e.extendedResultCode));
  } on FileSystemException {
    return const Left(StorageFullFailure());
  }
}
```
Never `catch (e) { rethrow; }`. Never `print`. Never return `null` to signal failure.

## 6. Transaction rules

1. Any operation touching more than one row or more than one table runs inside a single `transaction`.
2. Bulk archive, bulk delete, bulk category change, purge, and import are **all-or-nothing** (`EC-40`).
3. A transaction never contains UI work, user prompts, or network calls.
4. Long transactions are chunked in batches with progress reporting, but each batch stays atomic.
5. Write operations are idempotent where the requirement allows, so an interrupted retry cannot duplicate data (`EC-21`).

## 7. Migration rules

1. `schemaVersion` increments by exactly one per released change; never mutate a shipped migration.
2. Every migration has a test that seeds the previous schema, migrates, and asserts zero data loss.
3. Destructive column changes require a copy-and-swap strategy, never a silent drop.
4. The backup file records its schema version; importing an older file upgrades it, importing a newer one is refused with a clear message.

## 8. Performance rules

1. Index every column used for sorting or filtering: `due_date`, `category_id`, `status`.
2. Never run a query inside a loop; use a single `WHERE ... IN` or a join.
3. Lists are paginated or streamed; never load 1000 rows into memory to display 20.
4. Target: any single local operation < 100 ms (`NFR-01`); assert this in an integration test.

## 9. Testing requirements for this layer

1. DAO tests run against an **in-memory** database (`NativeDatabase.memory()`), never the real device file.
2. Every failure branch in §5 has a test that forces the exception and asserts the mapped `Failure`.
3. Transaction rollback is tested by injecting a failure mid-operation and asserting the database is unchanged.
4. Migration tests cover every supported previous version.
5. Coverage floor for `data/`: 70%.

## 10. Rejection checklist (the agent refuses if any is true)

- [ ] Business logic found inside a DAO or a table file.
- [ ] Drift types exposed outside `data/`.
- [ ] `domain/` importing anything from `data/` or Flutter.
- [ ] Multi-row operation without a transaction.
- [ ] A raw exception escaping the repository.
- [ ] A new table or column without a migration and a migration test.
- [ ] Implementation delivered without its test contract.
