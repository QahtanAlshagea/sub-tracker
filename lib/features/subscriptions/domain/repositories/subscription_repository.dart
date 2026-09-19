import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../value_objects/subscription_status.dart';

/// Abstract repository contract for subscription persistence and retrieval.
/// Pure Dart interface adhering to Clean Architecture and the Dependency Inversion Principle (DIP).
abstract class SubscriptionRepository {
  /// Persists a new [Subscription].
  Future<Result<Subscription>> createSubscription(Subscription subscription);

  /// Updates an existing [Subscription].
  Future<Result<Subscription>> updateSubscription(Subscription subscription);

  /// Retrieves a single [Subscription] by its unique [id].
  Future<Result<Subscription>> getSubscriptionById(String id);

  /// Retrieves a list of subscriptions optionally filtered by [status] and/or [categoryId].
  Future<Result<List<Subscription>>> getAllSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  });

  /// Provides a reactive stream of subscriptions, optionally filtered by [status] and/or [categoryId].
  Stream<Result<List<Subscription>>> watchSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  });

  /// Marks an active subscription as archived (US-10, FR-08).
  Future<Result<void>> archiveSubscription(String id);

  /// Restores an archived subscription to active status (US-11, FR-08).
  Future<Result<void>> unarchiveSubscription(String id);

  /// Soft-deletes a subscription by moving it into the trash (US-12, FR-09).
  Future<Result<void>> moveToTrash(String id);

  /// Restores a soft-deleted subscription from trash back to its previous status (US-14, FR-09).
  Future<Result<void>> restoreFromTrash(String id);

  /// Permanently removes a subscription from persistent storage (US-13, FR-09).
  Future<Result<void>> permanentlyDeleteSubscription(String id);

  /// Permanently deletes all subscriptions currently residing in the trash (US-13).
  Future<Result<void>> emptyTrash();
}
