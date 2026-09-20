import 'dart:io';
import 'package:drift/native.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/failures/subscription_failures.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/value_objects/subscription_status.dart';
import '../datasources/subscription_local_data_source.dart';
import '../models/subscription_model.dart';

/// Implementation of [SubscriptionRepository] adhering strictly to Clean Architecture.
///
/// Orchestrates [SubscriptionLocalDataSource] and encapsulates all low-level SQLite/Drift
/// database operations, guaranteeing that no exception escapes outside the data layer.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource _localDataSource;

  const SubscriptionRepositoryImpl(this._localDataSource);

  @override
  Future<Result<Subscription>> createSubscription(
    Subscription subscription,
  ) async {
    try {
      final model = SubscriptionModel.fromEntity(subscription);
      final created = await _localDataSource.createSubscription(model);
      return Result.success(created.toEntity());
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067 ||
          e.message.toLowerCase().contains('unique') ||
          e.message.contains('idx_subscriptions_dup_check')) {
        return const Result.failure(DuplicateSubscriptionFailure());
      }
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Subscription>> updateSubscription(
    Subscription subscription,
  ) async {
    try {
      final existing = await _localDataSource.getSubscriptionById(
        subscription.id,
      );
      if (existing == null) {
        return Result.failure(SubscriptionNotFoundFailure(subscription.id));
      }

      final model = SubscriptionModel.fromEntity(subscription);
      final updated = await _localDataSource.updateSubscription(model);
      return Result.success(updated.toEntity());
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067 ||
          e.message.toLowerCase().contains('unique') ||
          e.message.contains('idx_subscriptions_dup_check')) {
        return const Result.failure(DuplicateSubscriptionFailure());
      }
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Subscription>> getSubscriptionById(String id) async {
    try {
      final model = await _localDataSource.getSubscriptionById(id);
      if (model == null) {
        return Result.failure(SubscriptionNotFoundFailure(id));
      }
      return Result.success(model.toEntity());
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Subscription>>> getAllSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) async {
    try {
      final list = await _localDataSource.getAllSubscriptions(
        status: status?.name,
        categoryId: categoryId,
      );
      final entities = list.map((m) => m.toEntity()).toList();
      return Result.success(entities);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<Result<List<Subscription>>> watchSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) async* {
    try {
      await for (final list in _localDataSource.watchSubscriptions(
        status: status?.name,
        categoryId: categoryId,
      )) {
        yield Result.success(list.map((m) => m.toEntity()).toList());
      }
    } on SqliteException catch (e) {
      yield Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      yield const Result.failure(StorageFullFailure());
    } catch (e) {
      yield Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> archiveSubscription(String id) async {
    try {
      final existing = await _localDataSource.getSubscriptionById(id);
      if (existing == null) {
        return Result.failure(SubscriptionNotFoundFailure(id));
      }

      await _localDataSource.archiveSubscription(id);
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> unarchiveSubscription(String id) async {
    try {
      final existing = await _localDataSource.getSubscriptionById(id);
      if (existing == null) {
        return Result.failure(SubscriptionNotFoundFailure(id));
      }

      await _localDataSource.unarchiveSubscription(id);
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> moveToTrash(String id) async {
    try {
      final existing = await _localDataSource.getSubscriptionById(id);
      if (existing == null) {
        return Result.failure(SubscriptionNotFoundFailure(id));
      }

      await _localDataSource.moveToTrash(id);
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> restoreFromTrash(String id) async {
    try {
      final existing = await _localDataSource.getSubscriptionById(id);
      if (existing == null) {
        return Result.failure(SubscriptionNotFoundFailure(id));
      }

      await _localDataSource.restoreFromTrash(id);
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> permanentlyDeleteSubscription(String id) async {
    try {
      final existing = await _localDataSource.getSubscriptionById(id);
      if (existing == null) {
        return Result.failure(SubscriptionNotFoundFailure(id));
      }

      await _localDataSource.permanentlyDeleteSubscription(id);
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> emptyTrash() async {
    try {
      await _localDataSource.emptyTrash();
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }
}
