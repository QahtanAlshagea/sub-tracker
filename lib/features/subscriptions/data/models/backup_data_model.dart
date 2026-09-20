import 'dart:convert';

import '../../domain/entities/backup_data.dart';
import 'category_model.dart';
import 'price_history_model.dart';
import 'subscription_model.dart';

/// Current supported database and backup schema version (V2).
const int kCurrentSchemaVersion = 2;

/// Exception thrown when an imported backup file has a newer schema version than the app supports (EC-30-3).
class BackupSchemaVersionTooNewException implements Exception {
  final int fileVersion;
  final int supportedVersion;

  const BackupSchemaVersionTooNewException({
    required this.fileVersion,
    required this.supportedVersion,
  });

  @override
  String toString() =>
      'Backup schema version ($fileVersion) is newer than supported version ($supportedVersion). Please update the application.';
}

/// Data model for Backup and Restore serialization.
/// Implements ARCHITECTURE.md §3.5 and §3.6.
class BackupDataModel {
  final int schemaVersion;
  final DateTime exportedAt;
  final String appVersion;
  final List<CategoryModel> categories;
  final List<SubscriptionModel> subscriptions;
  final List<PriceHistoryModel> priceHistory;
  final Map<String, dynamic> settings;

  const BackupDataModel({
    required this.schemaVersion,
    required this.exportedAt,
    this.appVersion = '1.0.0',
    required this.categories,
    required this.subscriptions,
    required this.priceHistory,
    this.settings = const <String, dynamic>{},
  });

  /// Creates a [BackupDataModel] from a pure domain [BackupData] entity.
  factory BackupDataModel.fromEntity(BackupData entity) {
    return BackupDataModel(
      schemaVersion: entity.schemaVersion,
      exportedAt: entity.exportedAt,
      appVersion: entity.appVersion,
      categories: entity.categories.map(CategoryModel.fromEntity).toList(),
      subscriptions: entity.subscriptions
          .map(SubscriptionModel.fromEntity)
          .toList(),
      priceHistory: entity.priceHistory
          .map(PriceHistoryModel.fromEntity)
          .toList(),
      settings: Map<String, dynamic>.from(entity.settings),
    );
  }

  /// Converts this model to a pure domain [BackupData] entity.
  BackupData toEntity() {
    return BackupData(
      schemaVersion: schemaVersion,
      exportedAt: exportedAt,
      appVersion: appVersion,
      categories: categories.map((c) => c.toEntity()).toList(),
      subscriptions: subscriptions.map((s) => s.toEntity()).toList(),
      priceHistory: priceHistory.map((p) => p.toEntity()).toList(),
      settings: Map<String, dynamic>.from(settings),
    );
  }

  /// Serializes to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'schema_version': schemaVersion,
      'exported_at': exportedAt.toIso8601String(),
      'app_version': appVersion,
      'categories': categories.map((c) => c.toJson()).toList(),
      'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      'price_history': priceHistory.map((p) => p.toJson()).toList(),
      'settings': settings,
    };
  }

  /// Serializes to a formatted UTF-8 JSON string.
  String toJsonString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  /// Parses and validates a JSON string.
  /// Throws [FormatException] on corrupt or incomplete syntax (EC-30-1).
  /// Throws [BackupSchemaVersionTooNewException] on newer schema version (EC-30-3).
  /// Automatically upgrades older schema version V1 -> V2 (EC-30-2).
  factory BackupDataModel.fromJsonString(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid backup format: root element must be a JSON object.',
      );
    }
    return BackupDataModel.fromJson(decoded);
  }

  /// Deserializes and validates a JSON Map.
  factory BackupDataModel.fromJson(Map<String, dynamic> json) {
    // 1. Validate schema_version presence and type
    if (!json.containsKey('schema_version') || json['schema_version'] is! int) {
      throw const FormatException(
        'Missing or invalid "schema_version" in backup payload.',
      );
    }
    final rawVersion = json['schema_version'] as int;

    // 2. Reject if schema_version is newer than supported (EC-30-3)
    if (rawVersion > kCurrentSchemaVersion) {
      throw BackupSchemaVersionTooNewException(
        fileVersion: rawVersion,
        supportedVersion: kCurrentSchemaVersion,
      );
    }

    if (rawVersion < 1) {
      throw FormatException(
        'Unsupported negative or zero schema_version: $rawVersion',
      );
    }

    // 3. Validate exported_at
    DateTime exportedAt;
    if (json.containsKey('exported_at') && json['exported_at'] is String) {
      try {
        exportedAt = DateTime.parse(json['exported_at'] as String).toUtc();
      } catch (_) {
        exportedAt = DateTime.now().toUtc();
      }
    } else {
      exportedAt = DateTime.now().toUtc();
    }

    final appVersion = (json['app_version'] as String?) ?? '1.0.0';

    // 4. Validate categories array
    if (!json.containsKey('categories') || json['categories'] is! List) {
      throw const FormatException(
        'Missing or invalid "categories" array in backup payload.',
      );
    }
    final categoriesList = (json['categories'] as List).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Category item in backup is not a valid JSON object.',
        );
      }
      return CategoryModel.fromJson(item);
    }).toList();

    // 5. Validate subscriptions array
    if (!json.containsKey('subscriptions') || json['subscriptions'] is! List) {
      throw const FormatException(
        'Missing or invalid "subscriptions" array in backup payload.',
      );
    }

    // 6. Handle V1 -> V2 Migration (EC-30-2)
    // If schema_version == 1, subscriptions may lack 'payment_method_desc', and 'settings' may be absent.
    final subscriptionsList = (json['subscriptions'] as List).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Subscription item in backup is not a valid JSON object.',
        );
      }
      final mutableItem = Map<String, dynamic>.from(item);
      if (rawVersion < 2 && !mutableItem.containsKey('payment_method_desc')) {
        mutableItem['payment_method_desc'] = null;
      }
      return SubscriptionModel.fromJson(mutableItem);
    }).toList();

    // 7. Parse price_history array (optional in older versions, default to empty list)
    final priceHistoryRaw = json['price_history'];
    final List<PriceHistoryModel> priceHistoryList;
    if (priceHistoryRaw is List) {
      priceHistoryList = priceHistoryRaw.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException(
            'PriceHistory item in backup is not a valid JSON object.',
          );
        }
        return PriceHistoryModel.fromJson(item);
      }).toList();
    } else {
      priceHistoryList = const <PriceHistoryModel>[];
    }

    // 8. Parse settings map (EC-30-2 default if missing in V1)
    final settingsRaw = json['settings'];
    final Map<String, dynamic> settingsMap;
    if (settingsRaw is Map<String, dynamic>) {
      settingsMap = Map<String, dynamic>.from(settingsRaw);
    } else {
      // Default settings for V1 upgraded backups
      settingsMap = {
        'id': 'app_settings',
        'theme_mode': 'system',
        'default_currency': 'USD',
        'default_reminder_days': 1,
        'default_reminder_hour': 9,
        'default_reminder_minute': 0,
        'default_sort_order': 'due_date_asc',
        'schema_version': kCurrentSchemaVersion,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
    }

    return BackupDataModel(
      schemaVersion: kCurrentSchemaVersion, // Upgraded to current version
      exportedAt: exportedAt,
      appVersion: appVersion,
      categories: categoriesList,
      subscriptions: subscriptionsList,
      priceHistory: priceHistoryList,
      settings: settingsMap,
    );
  }
}
