import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../failures/subscription_failures.dart';

/// Pure domain duplicate subscription detector.
/// Implements FR-19, US-36, BR-10, EC-36-1 and EC-01-4.
/// Pure Dart — zero dependencies on Flutter or persistence.
class DuplicateDetector {
  const DuplicateDetector._();

  /// Checks if [candidate] matches any existing active subscription (FR-19, US-36, EC-36-1).
  /// Excludes archived and trashed subscriptions per BR-10.
  /// Ignores the subscription itself if [candidate.id] already exists (updating scenario).
  static Result<void> checkDuplicate({
    required Subscription candidate,
    required Iterable<Subscription> existingSubscriptions,
  }) {
    final candidateNormName = normalizeName(candidate.name);

    for (final existing in existingSubscriptions) {
      // Ignore comparing with itself during updates
      if (existing.id == candidate.id) {
        continue;
      }

      // BR-10: Exclude archived and trashed subscriptions from duplication checks
      if (!existing.status.isActive) {
        continue;
      }

      // Check normalized name
      if (normalizeName(existing.name) != candidateNormName) {
        continue;
      }

      // Check billing cycle equivalence
      if (existing.cycle != candidate.cycle) {
        continue;
      }

      // Check calendar due date equivalence (year, month, day)
      final existingDue = existing.nextDueDate;
      final candidateDue = candidate.nextDueDate;
      final sameCalendarDay =
          existingDue.year == candidateDue.year &&
          existingDue.month == candidateDue.month &&
          existingDue.day == candidateDue.day;

      if (sameCalendarDay) {
        return const Error(DuplicateSubscriptionFailure());
      }
    }

    return const Success(null);
  }

  /// Normalizes subscription name for accurate collision checking (EC-01-4).
  /// Trims, collapses whitespace, folds case, strips Arabic diacritics, and normalizes Alefs.
  static String normalizeName(String name) {
    var text = name.trim().toLowerCase();

    // Collapse multiple spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Strip Arabic diacritics (Harakat / Tashkeel)
    // Range: \u064B (Fathatan) to \u0652 (Sukun), plus \u0670 (Superscript Alef)
    text = text.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');

    // Normalize Arabic Alefs: أ, إ, آ, ٱ -> ا
    text = text.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Normalize Arabic Taa Marbuta: ة -> ه
    text = text.replaceAll('ة', 'ه');

    // Normalize Arabic Yaa: ى -> ي
    text = text.replaceAll('ى', 'ي');

    return text;
  }
}
