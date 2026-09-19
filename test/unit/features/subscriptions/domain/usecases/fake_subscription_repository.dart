import 'dart:async';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

/// In-memory fake implementation of [SubscriptionRepository] for pure domain unit testing.
class FakeSubscriptionRepository implements SubscriptionRepository {
  final Map<String, Subscription> items = {};
  final StreamController<Result<List<Subscription>>> _streamController =
      StreamController<Result<List<Subscription>>>.broadcast();

  Failure? injectedFailure;

  void emitCurrent() {
    if (injectedFailure != null) {
      _streamController.add(Error(injectedFailure!));
    } else {
      _streamController.add(Success(items.values.toList()));
    }
  }

  @override
  Future<Result<Subscription>> createSubscription(
    Subscription subscription,
  ) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    items[subscription.id] = subscription;
    emitCurrent();
    return Success(subscription);
  }

  @override
  Future<Result<Subscription>> updateSubscription(
    Subscription subscription,
  ) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    if (!items.containsKey(subscription.id)) {
      return Error(SubscriptionNotFoundFailure(subscription.id));
    }
    items[subscription.id] = subscription;
    emitCurrent();
    return Success(subscription);
  }

  @override
  Future<Result<Subscription>> getSubscriptionById(String id) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    final sub = items[id];
    if (sub == null) {
      return Error(SubscriptionNotFoundFailure(id));
    }
    return Success(sub);
  }

  @override
  Future<Result<List<Subscription>>> getAllSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    var result = items.values.toList();
    if (status != null) {
      result = result.where((s) => s.status == status).toList();
    }
    if (categoryId != null) {
      result = result.where((s) => s.categoryId == categoryId).toList();
    }
    return Success(result);
  }

  @override
  Stream<Result<List<Subscription>>> watchSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) {
    return _streamController.stream.map((res) {
      if (res.isFailure) return res;
      var list = res.dataOrNull ?? [];
      if (status != null) {
        list = list.where((s) => s.status == status).toList();
      }
      if (categoryId != null) {
        list = list.where((s) => s.categoryId == categoryId).toList();
      }
      return Success(list);
    });
  }

  @override
  Future<Result<void>> archiveSubscription(String id) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    final sub = items[id];
    if (sub == null) return Error(SubscriptionNotFoundFailure(id));
    items[id] = sub.archive();
    emitCurrent();
    return const Success(null);
  }

  @override
  Future<Result<void>> unarchiveSubscription(String id) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    final sub = items[id];
    if (sub == null) return Error(SubscriptionNotFoundFailure(id));
    items[id] = sub.unarchive();
    emitCurrent();
    return const Success(null);
  }

  @override
  Future<Result<void>> moveToTrash(String id) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    final sub = items[id];
    if (sub == null) return Error(SubscriptionNotFoundFailure(id));
    items[id] = sub.moveToTrash();
    emitCurrent();
    return const Success(null);
  }

  @override
  Future<Result<void>> restoreFromTrash(String id) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    final sub = items[id];
    if (sub == null) return Error(SubscriptionNotFoundFailure(id));
    items[id] = sub.restoreFromTrash();
    emitCurrent();
    return const Success(null);
  }

  @override
  Future<Result<void>> permanentlyDeleteSubscription(String id) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    if (!items.containsKey(id)) {
      return Error(SubscriptionNotFoundFailure(id));
    }
    items.remove(id);
    emitCurrent();
    return const Success(null);
  }

  @override
  Future<Result<void>> emptyTrash() async {
    if (injectedFailure != null) return Error(injectedFailure!);
    items.removeWhere((_, sub) => sub.isInTrash);
    emitCurrent();
    return const Success(null);
  }

  void dispose() {
    _streamController.close();
  }
}
