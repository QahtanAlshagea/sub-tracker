// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 24,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<String> iconCode = GeneratedColumn<String>(
    'icon_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    iconCode,
    isSystem,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_code'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  /// Unique identifier (UUID v4).
  final String id;

  /// Normalized category name (1 to 24 chars). Unique across all categories.
  final String name;

  /// 32-bit ARGB color value integer (e.g. 0xFF4F46E5).
  final int colorValue;

  /// Optional icon code identifier.
  final String? iconCode;

  /// Whether this is the immutable system category («غير مصنّف»).
  final bool isSystem;

  /// Creation timestamp in UTC.
  final DateTime createdAt;
  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconCode,
    required this.isSystem,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    if (!nullToAbsent || iconCode != null) {
      map['icon_code'] = Variable<String>(iconCode);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      iconCode: iconCode == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCode),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconCode: serializer.fromJson<String?>(json['iconCode']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconCode': serializer.toJson<String?>(iconCode),
      'isSystem': serializer.toJson<bool>(isSystem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    Value<String?> iconCode = const Value.absent(),
    bool? isSystem,
    DateTime? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    iconCode: iconCode.present ? iconCode.value : this.iconCode,
    isSystem: isSystem ?? this.isSystem,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCode: $iconCode, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorValue, iconCode, isSystem, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.iconCode == this.iconCode &&
          other.isSystem == this.isSystem &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<String?> iconCode;
  final Value<bool> isSystem;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int colorValue,
    this.iconCode = const Value.absent(),
    this.isSystem = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorValue = Value(colorValue),
       createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<String>? iconCode,
    Expression<bool>? isSystem,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (iconCode != null) 'icon_code': iconCode,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? colorValue,
    Value<String?>? iconCode,
    Value<bool>? isSystem,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<String>(iconCode.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCode: $iconCode, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMinorUnitsMeta = const VerificationMeta(
    'priceMinorUnits',
  );
  @override
  late final GeneratedColumn<int> priceMinorUnits = GeneratedColumn<int>(
    'price_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleTypeMeta = const VerificationMeta(
    'cycleType',
  );
  @override
  late final GeneratedColumn<String> cycleType = GeneratedColumn<String>(
    'cycle_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customCycleDaysMeta = const VerificationMeta(
    'customCycleDays',
  );
  @override
  late final GeneratedColumn<int> customCycleDays = GeneratedColumn<int>(
    'custom_cycle_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalAnchorDayMeta = const VerificationMeta(
    'originalAnchorDay',
  );
  @override
  late final GeneratedColumn<int> originalAnchorDay = GeneratedColumn<int>(
    'original_anchor_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _isTrialMeta = const VerificationMeta(
    'isTrial',
  );
  @override
  late final GeneratedColumn<bool> isTrial = GeneratedColumn<bool>(
    'is_trial',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_trial" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _renewalUrlMeta = const VerificationMeta(
    'renewalUrl',
  );
  @override
  late final GeneratedColumn<String> renewalUrl = GeneratedColumn<String>(
    'renewal_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodDescMeta = const VerificationMeta(
    'paymentMethodDesc',
  );
  @override
  late final GeneratedColumn<String> paymentMethodDesc =
      GeneratedColumn<String>(
        'payment_method_desc',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderLeadDaysMeta = const VerificationMeta(
    'reminderLeadDays',
  );
  @override
  late final GeneratedColumn<int> reminderLeadDays = GeneratedColumn<int>(
    'reminder_lead_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _reminderTimeHourMeta = const VerificationMeta(
    'reminderTimeHour',
  );
  @override
  late final GeneratedColumn<int> reminderTimeHour = GeneratedColumn<int>(
    'reminder_time_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9),
  );
  static const VerificationMeta _reminderTimeMinuteMeta =
      const VerificationMeta('reminderTimeMinute');
  @override
  late final GeneratedColumn<int> reminderTimeMinute = GeneratedColumn<int>(
    'reminder_time_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    priceMinorUnits,
    currencyCode,
    cycleType,
    customCycleDays,
    startDate,
    nextDueDate,
    originalAnchorDay,
    categoryId,
    status,
    isTrial,
    notes,
    renewalUrl,
    paymentMethodDesc,
    reminderEnabled,
    reminderLeadDays,
    reminderTimeHour,
    reminderTimeMinute,
    createdAt,
    updatedAt,
    deletedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subscription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_minor_units')) {
      context.handle(
        _priceMinorUnitsMeta,
        priceMinorUnits.isAcceptableOrUnknown(
          data['price_minor_units']!,
          _priceMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priceMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('cycle_type')) {
      context.handle(
        _cycleTypeMeta,
        cycleType.isAcceptableOrUnknown(data['cycle_type']!, _cycleTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleTypeMeta);
    }
    if (data.containsKey('custom_cycle_days')) {
      context.handle(
        _customCycleDaysMeta,
        customCycleDays.isAcceptableOrUnknown(
          data['custom_cycle_days']!,
          _customCycleDaysMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('original_anchor_day')) {
      context.handle(
        _originalAnchorDayMeta,
        originalAnchorDay.isAcceptableOrUnknown(
          data['original_anchor_day']!,
          _originalAnchorDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalAnchorDayMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_trial')) {
      context.handle(
        _isTrialMeta,
        isTrial.isAcceptableOrUnknown(data['is_trial']!, _isTrialMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('renewal_url')) {
      context.handle(
        _renewalUrlMeta,
        renewalUrl.isAcceptableOrUnknown(data['renewal_url']!, _renewalUrlMeta),
      );
    }
    if (data.containsKey('payment_method_desc')) {
      context.handle(
        _paymentMethodDescMeta,
        paymentMethodDesc.isAcceptableOrUnknown(
          data['payment_method_desc']!,
          _paymentMethodDescMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_lead_days')) {
      context.handle(
        _reminderLeadDaysMeta,
        reminderLeadDays.isAcceptableOrUnknown(
          data['reminder_lead_days']!,
          _reminderLeadDaysMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time_hour')) {
      context.handle(
        _reminderTimeHourMeta,
        reminderTimeHour.isAcceptableOrUnknown(
          data['reminder_time_hour']!,
          _reminderTimeHourMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time_minute')) {
      context.handle(
        _reminderTimeMinuteMeta,
        reminderTimeMinute.isAcceptableOrUnknown(
          data['reminder_time_minute']!,
          _reminderTimeMinuteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      priceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      cycleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_type'],
      )!,
      customCycleDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_cycle_days'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      )!,
      originalAnchorDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_anchor_day'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isTrial: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_trial'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      renewalUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}renewal_url'],
      ),
      paymentMethodDesc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_desc'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderLeadDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_lead_days'],
      )!,
      reminderTimeHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_time_hour'],
      )!,
      reminderTimeMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_time_minute'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  /// Unique identifier (UUID v4).
  final String id;

  /// Normalized subscription name (1 to 60 chars).
  final String name;

  /// Amount in integer minor units (non-negative).
  final int priceMinorUnits;

  /// 3-letter ISO 4217 uppercase currency code.
  final String currencyCode;

  /// Recurrence cycle type ('monthly', 'yearly', 'weekly', 'custom').
  final String cycleType;

  /// Custom recurrence interval in days (1 to 3650, null if not custom).
  final int? customCycleDays;

  /// Initial start date in UTC.
  final DateTime startDate;

  /// Next calculated due date in UTC.
  final DateTime nextDueDate;

  /// Original anchor day of month (1 to 31) for preserving day across months.
  final int originalAnchorDay;

  /// Foreign key referencing Categories(id) with RESTRICT on delete.
  final String categoryId;

  /// Lifecycle status ('active', 'archived', 'in_trash').
  final String status;

  /// Flag indicating if the subscription is currently a free trial.
  final bool isTrial;

  /// Optional notes (max 500 characters).
  final String? notes;

  /// Optional renewal/management URL.
  final String? renewalUrl;

  /// Optional payment method description (max 50 characters).
  final String? paymentMethodDesc;

  /// Whether local reminders are enabled.
  final bool reminderEnabled;

  /// Days before due date to notify (0 to 30).
  final int reminderLeadDays;

  /// Notification trigger hour (0 to 23).
  final int reminderTimeHour;

  /// Notification trigger minute (0 to 59).
  final int reminderTimeMinute;

  /// Record creation timestamp in UTC.
  final DateTime createdAt;

  /// Record last update timestamp in UTC.
  final DateTime updatedAt;

  /// Soft deletion timestamp in UTC (null if not in trash).
  final DateTime? deletedAt;

  /// Archival timestamp in UTC (null if not archived).
  final DateTime? archivedAt;
  const Subscription({
    required this.id,
    required this.name,
    required this.priceMinorUnits,
    required this.currencyCode,
    required this.cycleType,
    this.customCycleDays,
    required this.startDate,
    required this.nextDueDate,
    required this.originalAnchorDay,
    required this.categoryId,
    required this.status,
    required this.isTrial,
    this.notes,
    this.renewalUrl,
    this.paymentMethodDesc,
    required this.reminderEnabled,
    required this.reminderLeadDays,
    required this.reminderTimeHour,
    required this.reminderTimeMinute,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['price_minor_units'] = Variable<int>(priceMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['cycle_type'] = Variable<String>(cycleType);
    if (!nullToAbsent || customCycleDays != null) {
      map['custom_cycle_days'] = Variable<int>(customCycleDays);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    map['original_anchor_day'] = Variable<int>(originalAnchorDay);
    map['category_id'] = Variable<String>(categoryId);
    map['status'] = Variable<String>(status);
    map['is_trial'] = Variable<bool>(isTrial);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || renewalUrl != null) {
      map['renewal_url'] = Variable<String>(renewalUrl);
    }
    if (!nullToAbsent || paymentMethodDesc != null) {
      map['payment_method_desc'] = Variable<String>(paymentMethodDesc);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_lead_days'] = Variable<int>(reminderLeadDays);
    map['reminder_time_hour'] = Variable<int>(reminderTimeHour);
    map['reminder_time_minute'] = Variable<int>(reminderTimeMinute);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      name: Value(name),
      priceMinorUnits: Value(priceMinorUnits),
      currencyCode: Value(currencyCode),
      cycleType: Value(cycleType),
      customCycleDays: customCycleDays == null && nullToAbsent
          ? const Value.absent()
          : Value(customCycleDays),
      startDate: Value(startDate),
      nextDueDate: Value(nextDueDate),
      originalAnchorDay: Value(originalAnchorDay),
      categoryId: Value(categoryId),
      status: Value(status),
      isTrial: Value(isTrial),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      renewalUrl: renewalUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(renewalUrl),
      paymentMethodDesc: paymentMethodDesc == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodDesc),
      reminderEnabled: Value(reminderEnabled),
      reminderLeadDays: Value(reminderLeadDays),
      reminderTimeHour: Value(reminderTimeHour),
      reminderTimeMinute: Value(reminderTimeMinute),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Subscription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      priceMinorUnits: serializer.fromJson<int>(json['priceMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      cycleType: serializer.fromJson<String>(json['cycleType']),
      customCycleDays: serializer.fromJson<int?>(json['customCycleDays']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      originalAnchorDay: serializer.fromJson<int>(json['originalAnchorDay']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      status: serializer.fromJson<String>(json['status']),
      isTrial: serializer.fromJson<bool>(json['isTrial']),
      notes: serializer.fromJson<String?>(json['notes']),
      renewalUrl: serializer.fromJson<String?>(json['renewalUrl']),
      paymentMethodDesc: serializer.fromJson<String?>(
        json['paymentMethodDesc'],
      ),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderLeadDays: serializer.fromJson<int>(json['reminderLeadDays']),
      reminderTimeHour: serializer.fromJson<int>(json['reminderTimeHour']),
      reminderTimeMinute: serializer.fromJson<int>(json['reminderTimeMinute']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'priceMinorUnits': serializer.toJson<int>(priceMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'cycleType': serializer.toJson<String>(cycleType),
      'customCycleDays': serializer.toJson<int?>(customCycleDays),
      'startDate': serializer.toJson<DateTime>(startDate),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'originalAnchorDay': serializer.toJson<int>(originalAnchorDay),
      'categoryId': serializer.toJson<String>(categoryId),
      'status': serializer.toJson<String>(status),
      'isTrial': serializer.toJson<bool>(isTrial),
      'notes': serializer.toJson<String?>(notes),
      'renewalUrl': serializer.toJson<String?>(renewalUrl),
      'paymentMethodDesc': serializer.toJson<String?>(paymentMethodDesc),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderLeadDays': serializer.toJson<int>(reminderLeadDays),
      'reminderTimeHour': serializer.toJson<int>(reminderTimeHour),
      'reminderTimeMinute': serializer.toJson<int>(reminderTimeMinute),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Subscription copyWith({
    String? id,
    String? name,
    int? priceMinorUnits,
    String? currencyCode,
    String? cycleType,
    Value<int?> customCycleDays = const Value.absent(),
    DateTime? startDate,
    DateTime? nextDueDate,
    int? originalAnchorDay,
    String? categoryId,
    String? status,
    bool? isTrial,
    Value<String?> notes = const Value.absent(),
    Value<String?> renewalUrl = const Value.absent(),
    Value<String?> paymentMethodDesc = const Value.absent(),
    bool? reminderEnabled,
    int? reminderLeadDays,
    int? reminderTimeHour,
    int? reminderTimeMinute,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Subscription(
    id: id ?? this.id,
    name: name ?? this.name,
    priceMinorUnits: priceMinorUnits ?? this.priceMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    cycleType: cycleType ?? this.cycleType,
    customCycleDays: customCycleDays.present
        ? customCycleDays.value
        : this.customCycleDays,
    startDate: startDate ?? this.startDate,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    originalAnchorDay: originalAnchorDay ?? this.originalAnchorDay,
    categoryId: categoryId ?? this.categoryId,
    status: status ?? this.status,
    isTrial: isTrial ?? this.isTrial,
    notes: notes.present ? notes.value : this.notes,
    renewalUrl: renewalUrl.present ? renewalUrl.value : this.renewalUrl,
    paymentMethodDesc: paymentMethodDesc.present
        ? paymentMethodDesc.value
        : this.paymentMethodDesc,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
    reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
    reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      priceMinorUnits: data.priceMinorUnits.present
          ? data.priceMinorUnits.value
          : this.priceMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      cycleType: data.cycleType.present ? data.cycleType.value : this.cycleType,
      customCycleDays: data.customCycleDays.present
          ? data.customCycleDays.value
          : this.customCycleDays,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      originalAnchorDay: data.originalAnchorDay.present
          ? data.originalAnchorDay.value
          : this.originalAnchorDay,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      status: data.status.present ? data.status.value : this.status,
      isTrial: data.isTrial.present ? data.isTrial.value : this.isTrial,
      notes: data.notes.present ? data.notes.value : this.notes,
      renewalUrl: data.renewalUrl.present
          ? data.renewalUrl.value
          : this.renewalUrl,
      paymentMethodDesc: data.paymentMethodDesc.present
          ? data.paymentMethodDesc.value
          : this.paymentMethodDesc,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderLeadDays: data.reminderLeadDays.present
          ? data.reminderLeadDays.value
          : this.reminderLeadDays,
      reminderTimeHour: data.reminderTimeHour.present
          ? data.reminderTimeHour.value
          : this.reminderTimeHour,
      reminderTimeMinute: data.reminderTimeMinute.present
          ? data.reminderTimeMinute.value
          : this.reminderTimeMinute,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('priceMinorUnits: $priceMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('cycleType: $cycleType, ')
          ..write('customCycleDays: $customCycleDays, ')
          ..write('startDate: $startDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('originalAnchorDay: $originalAnchorDay, ')
          ..write('categoryId: $categoryId, ')
          ..write('status: $status, ')
          ..write('isTrial: $isTrial, ')
          ..write('notes: $notes, ')
          ..write('renewalUrl: $renewalUrl, ')
          ..write('paymentMethodDesc: $paymentMethodDesc, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderLeadDays: $reminderLeadDays, ')
          ..write('reminderTimeHour: $reminderTimeHour, ')
          ..write('reminderTimeMinute: $reminderTimeMinute, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    priceMinorUnits,
    currencyCode,
    cycleType,
    customCycleDays,
    startDate,
    nextDueDate,
    originalAnchorDay,
    categoryId,
    status,
    isTrial,
    notes,
    renewalUrl,
    paymentMethodDesc,
    reminderEnabled,
    reminderLeadDays,
    reminderTimeHour,
    reminderTimeMinute,
    createdAt,
    updatedAt,
    deletedAt,
    archivedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.name == this.name &&
          other.priceMinorUnits == this.priceMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.cycleType == this.cycleType &&
          other.customCycleDays == this.customCycleDays &&
          other.startDate == this.startDate &&
          other.nextDueDate == this.nextDueDate &&
          other.originalAnchorDay == this.originalAnchorDay &&
          other.categoryId == this.categoryId &&
          other.status == this.status &&
          other.isTrial == this.isTrial &&
          other.notes == this.notes &&
          other.renewalUrl == this.renewalUrl &&
          other.paymentMethodDesc == this.paymentMethodDesc &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderLeadDays == this.reminderLeadDays &&
          other.reminderTimeHour == this.reminderTimeHour &&
          other.reminderTimeMinute == this.reminderTimeMinute &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.archivedAt == this.archivedAt);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> priceMinorUnits;
  final Value<String> currencyCode;
  final Value<String> cycleType;
  final Value<int?> customCycleDays;
  final Value<DateTime> startDate;
  final Value<DateTime> nextDueDate;
  final Value<int> originalAnchorDay;
  final Value<String> categoryId;
  final Value<String> status;
  final Value<bool> isTrial;
  final Value<String?> notes;
  final Value<String?> renewalUrl;
  final Value<String?> paymentMethodDesc;
  final Value<bool> reminderEnabled;
  final Value<int> reminderLeadDays;
  final Value<int> reminderTimeHour;
  final Value<int> reminderTimeMinute;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.priceMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.cycleType = const Value.absent(),
    this.customCycleDays = const Value.absent(),
    this.startDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.originalAnchorDay = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.status = const Value.absent(),
    this.isTrial = const Value.absent(),
    this.notes = const Value.absent(),
    this.renewalUrl = const Value.absent(),
    this.paymentMethodDesc = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderLeadDays = const Value.absent(),
    this.reminderTimeHour = const Value.absent(),
    this.reminderTimeMinute = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    required String id,
    required String name,
    required int priceMinorUnits,
    required String currencyCode,
    required String cycleType,
    this.customCycleDays = const Value.absent(),
    required DateTime startDate,
    required DateTime nextDueDate,
    required int originalAnchorDay,
    required String categoryId,
    this.status = const Value.absent(),
    this.isTrial = const Value.absent(),
    this.notes = const Value.absent(),
    this.renewalUrl = const Value.absent(),
    this.paymentMethodDesc = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderLeadDays = const Value.absent(),
    this.reminderTimeHour = const Value.absent(),
    this.reminderTimeMinute = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       priceMinorUnits = Value(priceMinorUnits),
       currencyCode = Value(currencyCode),
       cycleType = Value(cycleType),
       startDate = Value(startDate),
       nextDueDate = Value(nextDueDate),
       originalAnchorDay = Value(originalAnchorDay),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Subscription> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? priceMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? cycleType,
    Expression<int>? customCycleDays,
    Expression<DateTime>? startDate,
    Expression<DateTime>? nextDueDate,
    Expression<int>? originalAnchorDay,
    Expression<String>? categoryId,
    Expression<String>? status,
    Expression<bool>? isTrial,
    Expression<String>? notes,
    Expression<String>? renewalUrl,
    Expression<String>? paymentMethodDesc,
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderLeadDays,
    Expression<int>? reminderTimeHour,
    Expression<int>? reminderTimeMinute,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (priceMinorUnits != null) 'price_minor_units': priceMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (cycleType != null) 'cycle_type': cycleType,
      if (customCycleDays != null) 'custom_cycle_days': customCycleDays,
      if (startDate != null) 'start_date': startDate,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (originalAnchorDay != null) 'original_anchor_day': originalAnchorDay,
      if (categoryId != null) 'category_id': categoryId,
      if (status != null) 'status': status,
      if (isTrial != null) 'is_trial': isTrial,
      if (notes != null) 'notes': notes,
      if (renewalUrl != null) 'renewal_url': renewalUrl,
      if (paymentMethodDesc != null) 'payment_method_desc': paymentMethodDesc,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderLeadDays != null) 'reminder_lead_days': reminderLeadDays,
      if (reminderTimeHour != null) 'reminder_time_hour': reminderTimeHour,
      if (reminderTimeMinute != null)
        'reminder_time_minute': reminderTimeMinute,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? priceMinorUnits,
    Value<String>? currencyCode,
    Value<String>? cycleType,
    Value<int?>? customCycleDays,
    Value<DateTime>? startDate,
    Value<DateTime>? nextDueDate,
    Value<int>? originalAnchorDay,
    Value<String>? categoryId,
    Value<String>? status,
    Value<bool>? isTrial,
    Value<String?>? notes,
    Value<String?>? renewalUrl,
    Value<String?>? paymentMethodDesc,
    Value<bool>? reminderEnabled,
    Value<int>? reminderLeadDays,
    Value<int>? reminderTimeHour,
    Value<int>? reminderTimeMinute,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      priceMinorUnits: priceMinorUnits ?? this.priceMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      cycleType: cycleType ?? this.cycleType,
      customCycleDays: customCycleDays ?? this.customCycleDays,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      originalAnchorDay: originalAnchorDay ?? this.originalAnchorDay,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      isTrial: isTrial ?? this.isTrial,
      notes: notes ?? this.notes,
      renewalUrl: renewalUrl ?? this.renewalUrl,
      paymentMethodDesc: paymentMethodDesc ?? this.paymentMethodDesc,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priceMinorUnits.present) {
      map['price_minor_units'] = Variable<int>(priceMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (cycleType.present) {
      map['cycle_type'] = Variable<String>(cycleType.value);
    }
    if (customCycleDays.present) {
      map['custom_cycle_days'] = Variable<int>(customCycleDays.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (originalAnchorDay.present) {
      map['original_anchor_day'] = Variable<int>(originalAnchorDay.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isTrial.present) {
      map['is_trial'] = Variable<bool>(isTrial.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (renewalUrl.present) {
      map['renewal_url'] = Variable<String>(renewalUrl.value);
    }
    if (paymentMethodDesc.present) {
      map['payment_method_desc'] = Variable<String>(paymentMethodDesc.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderLeadDays.present) {
      map['reminder_lead_days'] = Variable<int>(reminderLeadDays.value);
    }
    if (reminderTimeHour.present) {
      map['reminder_time_hour'] = Variable<int>(reminderTimeHour.value);
    }
    if (reminderTimeMinute.present) {
      map['reminder_time_minute'] = Variable<int>(reminderTimeMinute.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('priceMinorUnits: $priceMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('cycleType: $cycleType, ')
          ..write('customCycleDays: $customCycleDays, ')
          ..write('startDate: $startDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('originalAnchorDay: $originalAnchorDay, ')
          ..write('categoryId: $categoryId, ')
          ..write('status: $status, ')
          ..write('isTrial: $isTrial, ')
          ..write('notes: $notes, ')
          ..write('renewalUrl: $renewalUrl, ')
          ..write('paymentMethodDesc: $paymentMethodDesc, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderLeadDays: $reminderLeadDays, ')
          ..write('reminderTimeHour: $reminderTimeHour, ')
          ..write('reminderTimeMinute: $reminderTimeMinute, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PriceHistoryTable extends PriceHistory
    with TableInfo<$PriceHistoryTable, PriceHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subscriptionIdMeta = const VerificationMeta(
    'subscriptionId',
  );
  @override
  late final GeneratedColumn<String> subscriptionId = GeneratedColumn<String>(
    'subscription_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscriptions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _oldPriceMinorUnitsMeta =
      const VerificationMeta('oldPriceMinorUnits');
  @override
  late final GeneratedColumn<int> oldPriceMinorUnits = GeneratedColumn<int>(
    'old_price_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newPriceMinorUnitsMeta =
      const VerificationMeta('newPriceMinorUnits');
  @override
  late final GeneratedColumn<int> newPriceMinorUnits = GeneratedColumn<int>(
    'new_price_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subscriptionId,
    oldPriceMinorUnits,
    newPriceMinorUnits,
    currencyCode,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subscription_id')) {
      context.handle(
        _subscriptionIdMeta,
        subscriptionId.isAcceptableOrUnknown(
          data['subscription_id']!,
          _subscriptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriptionIdMeta);
    }
    if (data.containsKey('old_price_minor_units')) {
      context.handle(
        _oldPriceMinorUnitsMeta,
        oldPriceMinorUnits.isAcceptableOrUnknown(
          data['old_price_minor_units']!,
          _oldPriceMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oldPriceMinorUnitsMeta);
    }
    if (data.containsKey('new_price_minor_units')) {
      context.handle(
        _newPriceMinorUnitsMeta,
        newPriceMinorUnits.isAcceptableOrUnknown(
          data['new_price_minor_units']!,
          _newPriceMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newPriceMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PriceHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subscriptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_id'],
      )!,
      oldPriceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}old_price_minor_units'],
      )!,
      newPriceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_price_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
    );
  }

  @override
  $PriceHistoryTable createAlias(String alias) {
    return $PriceHistoryTable(attachedDatabase, alias);
  }
}

class PriceHistoryData extends DataClass
    implements Insertable<PriceHistoryData> {
  /// Unique identifier (UUID v4).
  final String id;

  /// Foreign key referencing Subscriptions(id) with CASCADE on delete.
  final String subscriptionId;

  /// Previous amount in integer minor units (non-negative).
  final int oldPriceMinorUnits;

  /// New amount in integer minor units (non-negative).
  final int newPriceMinorUnits;

  /// 3-letter ISO 4217 uppercase currency code.
  final String currencyCode;

  /// Effective timestamp of price change in UTC.
  final DateTime changedAt;
  const PriceHistoryData({
    required this.id,
    required this.subscriptionId,
    required this.oldPriceMinorUnits,
    required this.newPriceMinorUnits,
    required this.currencyCode,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subscription_id'] = Variable<String>(subscriptionId);
    map['old_price_minor_units'] = Variable<int>(oldPriceMinorUnits);
    map['new_price_minor_units'] = Variable<int>(newPriceMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['changed_at'] = Variable<DateTime>(changedAt);
    return map;
  }

  PriceHistoryCompanion toCompanion(bool nullToAbsent) {
    return PriceHistoryCompanion(
      id: Value(id),
      subscriptionId: Value(subscriptionId),
      oldPriceMinorUnits: Value(oldPriceMinorUnits),
      newPriceMinorUnits: Value(newPriceMinorUnits),
      currencyCode: Value(currencyCode),
      changedAt: Value(changedAt),
    );
  }

  factory PriceHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceHistoryData(
      id: serializer.fromJson<String>(json['id']),
      subscriptionId: serializer.fromJson<String>(json['subscriptionId']),
      oldPriceMinorUnits: serializer.fromJson<int>(json['oldPriceMinorUnits']),
      newPriceMinorUnits: serializer.fromJson<int>(json['newPriceMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subscriptionId': serializer.toJson<String>(subscriptionId),
      'oldPriceMinorUnits': serializer.toJson<int>(oldPriceMinorUnits),
      'newPriceMinorUnits': serializer.toJson<int>(newPriceMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  PriceHistoryData copyWith({
    String? id,
    String? subscriptionId,
    int? oldPriceMinorUnits,
    int? newPriceMinorUnits,
    String? currencyCode,
    DateTime? changedAt,
  }) => PriceHistoryData(
    id: id ?? this.id,
    subscriptionId: subscriptionId ?? this.subscriptionId,
    oldPriceMinorUnits: oldPriceMinorUnits ?? this.oldPriceMinorUnits,
    newPriceMinorUnits: newPriceMinorUnits ?? this.newPriceMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    changedAt: changedAt ?? this.changedAt,
  );
  PriceHistoryData copyWithCompanion(PriceHistoryCompanion data) {
    return PriceHistoryData(
      id: data.id.present ? data.id.value : this.id,
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
      oldPriceMinorUnits: data.oldPriceMinorUnits.present
          ? data.oldPriceMinorUnits.value
          : this.oldPriceMinorUnits,
      newPriceMinorUnits: data.newPriceMinorUnits.present
          ? data.newPriceMinorUnits.value
          : this.newPriceMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceHistoryData(')
          ..write('id: $id, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('oldPriceMinorUnits: $oldPriceMinorUnits, ')
          ..write('newPriceMinorUnits: $newPriceMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subscriptionId,
    oldPriceMinorUnits,
    newPriceMinorUnits,
    currencyCode,
    changedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceHistoryData &&
          other.id == this.id &&
          other.subscriptionId == this.subscriptionId &&
          other.oldPriceMinorUnits == this.oldPriceMinorUnits &&
          other.newPriceMinorUnits == this.newPriceMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.changedAt == this.changedAt);
}

class PriceHistoryCompanion extends UpdateCompanion<PriceHistoryData> {
  final Value<String> id;
  final Value<String> subscriptionId;
  final Value<int> oldPriceMinorUnits;
  final Value<int> newPriceMinorUnits;
  final Value<String> currencyCode;
  final Value<DateTime> changedAt;
  final Value<int> rowid;
  const PriceHistoryCompanion({
    this.id = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.oldPriceMinorUnits = const Value.absent(),
    this.newPriceMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PriceHistoryCompanion.insert({
    required String id,
    required String subscriptionId,
    required int oldPriceMinorUnits,
    required int newPriceMinorUnits,
    required String currencyCode,
    required DateTime changedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subscriptionId = Value(subscriptionId),
       oldPriceMinorUnits = Value(oldPriceMinorUnits),
       newPriceMinorUnits = Value(newPriceMinorUnits),
       currencyCode = Value(currencyCode),
       changedAt = Value(changedAt);
  static Insertable<PriceHistoryData> custom({
    Expression<String>? id,
    Expression<String>? subscriptionId,
    Expression<int>? oldPriceMinorUnits,
    Expression<int>? newPriceMinorUnits,
    Expression<String>? currencyCode,
    Expression<DateTime>? changedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (oldPriceMinorUnits != null)
        'old_price_minor_units': oldPriceMinorUnits,
      if (newPriceMinorUnits != null)
        'new_price_minor_units': newPriceMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (changedAt != null) 'changed_at': changedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PriceHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? subscriptionId,
    Value<int>? oldPriceMinorUnits,
    Value<int>? newPriceMinorUnits,
    Value<String>? currencyCode,
    Value<DateTime>? changedAt,
    Value<int>? rowid,
  }) {
    return PriceHistoryCompanion(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      oldPriceMinorUnits: oldPriceMinorUnits ?? this.oldPriceMinorUnits,
      newPriceMinorUnits: newPriceMinorUnits ?? this.newPriceMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      changedAt: changedAt ?? this.changedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<String>(subscriptionId.value);
    }
    if (oldPriceMinorUnits.present) {
      map['old_price_minor_units'] = Variable<int>(oldPriceMinorUnits.value);
    }
    if (newPriceMinorUnits.present) {
      map['new_price_minor_units'] = Variable<int>(newPriceMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceHistoryCompanion(')
          ..write('id: $id, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('oldPriceMinorUnits: $oldPriceMinorUnits, ')
          ..write('newPriceMinorUnits: $newPriceMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('changedAt: $changedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('app_settings'),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _defaultCurrencyMeta = const VerificationMeta(
    'defaultCurrency',
  );
  @override
  late final GeneratedColumn<String> defaultCurrency = GeneratedColumn<String>(
    'default_currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _defaultReminderDaysMeta =
      const VerificationMeta('defaultReminderDays');
  @override
  late final GeneratedColumn<int> defaultReminderDays = GeneratedColumn<int>(
    'default_reminder_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _defaultReminderHourMeta =
      const VerificationMeta('defaultReminderHour');
  @override
  late final GeneratedColumn<int> defaultReminderHour = GeneratedColumn<int>(
    'default_reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9),
  );
  static const VerificationMeta _defaultReminderMinuteMeta =
      const VerificationMeta('defaultReminderMinute');
  @override
  late final GeneratedColumn<int> defaultReminderMinute = GeneratedColumn<int>(
    'default_reminder_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _defaultSortOrderMeta = const VerificationMeta(
    'defaultSortOrder',
  );
  @override
  late final GeneratedColumn<String> defaultSortOrder = GeneratedColumn<String>(
    'default_sort_order',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('due_date_asc'),
  );
  static const VerificationMeta _lastBackupAtMeta = const VerificationMeta(
    'lastBackupAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastBackupAt = GeneratedColumn<DateTime>(
    'last_backup_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    defaultCurrency,
    defaultReminderDays,
    defaultReminderHour,
    defaultReminderMinute,
    defaultSortOrder,
    lastBackupAt,
    schemaVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('default_currency')) {
      context.handle(
        _defaultCurrencyMeta,
        defaultCurrency.isAcceptableOrUnknown(
          data['default_currency']!,
          _defaultCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('default_reminder_days')) {
      context.handle(
        _defaultReminderDaysMeta,
        defaultReminderDays.isAcceptableOrUnknown(
          data['default_reminder_days']!,
          _defaultReminderDaysMeta,
        ),
      );
    }
    if (data.containsKey('default_reminder_hour')) {
      context.handle(
        _defaultReminderHourMeta,
        defaultReminderHour.isAcceptableOrUnknown(
          data['default_reminder_hour']!,
          _defaultReminderHourMeta,
        ),
      );
    }
    if (data.containsKey('default_reminder_minute')) {
      context.handle(
        _defaultReminderMinuteMeta,
        defaultReminderMinute.isAcceptableOrUnknown(
          data['default_reminder_minute']!,
          _defaultReminderMinuteMeta,
        ),
      );
    }
    if (data.containsKey('default_sort_order')) {
      context.handle(
        _defaultSortOrderMeta,
        defaultSortOrder.isAcceptableOrUnknown(
          data['default_sort_order']!,
          _defaultSortOrderMeta,
        ),
      );
    }
    if (data.containsKey('last_backup_at')) {
      context.handle(
        _lastBackupAtMeta,
        lastBackupAt.isAcceptableOrUnknown(
          data['last_backup_at']!,
          _lastBackupAtMeta,
        ),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      defaultCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_currency'],
      )!,
      defaultReminderDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_reminder_days'],
      )!,
      defaultReminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_reminder_hour'],
      )!,
      defaultReminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_reminder_minute'],
      )!,
      defaultSortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_sort_order'],
      )!,
      lastBackupAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_backup_at'],
      ),
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  /// Singleton record key, always 'app_settings'.
  final String id;

  /// UI theme mode ('system', 'light', 'dark').
  final String themeMode;

  /// Default ISO 4217 currency code for new subscriptions.
  final String defaultCurrency;

  /// Default reminder lead time in days (0 to 30).
  final int defaultReminderDays;

  /// Default reminder trigger hour (0 to 23).
  final int defaultReminderHour;

  /// Default reminder trigger minute (0 to 59).
  final int defaultReminderMinute;

  /// Default subscription sort ordering identifier.
  final String defaultSortOrder;

  /// Timestamp of the last successful backup export, or null if never exported.
  final DateTime? lastBackupAt;

  /// Recorded schema version for consistency verification.
  final int schemaVersion;

  /// Timestamp of the last settings update in UTC.
  final DateTime updatedAt;
  const Setting({
    required this.id,
    required this.themeMode,
    required this.defaultCurrency,
    required this.defaultReminderDays,
    required this.defaultReminderHour,
    required this.defaultReminderMinute,
    required this.defaultSortOrder,
    this.lastBackupAt,
    required this.schemaVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['default_currency'] = Variable<String>(defaultCurrency);
    map['default_reminder_days'] = Variable<int>(defaultReminderDays);
    map['default_reminder_hour'] = Variable<int>(defaultReminderHour);
    map['default_reminder_minute'] = Variable<int>(defaultReminderMinute);
    map['default_sort_order'] = Variable<String>(defaultSortOrder);
    if (!nullToAbsent || lastBackupAt != null) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt);
    }
    map['schema_version'] = Variable<int>(schemaVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      defaultCurrency: Value(defaultCurrency),
      defaultReminderDays: Value(defaultReminderDays),
      defaultReminderHour: Value(defaultReminderHour),
      defaultReminderMinute: Value(defaultReminderMinute),
      defaultSortOrder: Value(defaultSortOrder),
      lastBackupAt: lastBackupAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupAt),
      schemaVersion: Value(schemaVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<String>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      defaultCurrency: serializer.fromJson<String>(json['defaultCurrency']),
      defaultReminderDays: serializer.fromJson<int>(
        json['defaultReminderDays'],
      ),
      defaultReminderHour: serializer.fromJson<int>(
        json['defaultReminderHour'],
      ),
      defaultReminderMinute: serializer.fromJson<int>(
        json['defaultReminderMinute'],
      ),
      defaultSortOrder: serializer.fromJson<String>(json['defaultSortOrder']),
      lastBackupAt: serializer.fromJson<DateTime?>(json['lastBackupAt']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'defaultCurrency': serializer.toJson<String>(defaultCurrency),
      'defaultReminderDays': serializer.toJson<int>(defaultReminderDays),
      'defaultReminderHour': serializer.toJson<int>(defaultReminderHour),
      'defaultReminderMinute': serializer.toJson<int>(defaultReminderMinute),
      'defaultSortOrder': serializer.toJson<String>(defaultSortOrder),
      'lastBackupAt': serializer.toJson<DateTime?>(lastBackupAt),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith({
    String? id,
    String? themeMode,
    String? defaultCurrency,
    int? defaultReminderDays,
    int? defaultReminderHour,
    int? defaultReminderMinute,
    String? defaultSortOrder,
    Value<DateTime?> lastBackupAt = const Value.absent(),
    int? schemaVersion,
    DateTime? updatedAt,
  }) => Setting(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    defaultReminderDays: defaultReminderDays ?? this.defaultReminderDays,
    defaultReminderHour: defaultReminderHour ?? this.defaultReminderHour,
    defaultReminderMinute: defaultReminderMinute ?? this.defaultReminderMinute,
    defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
    lastBackupAt: lastBackupAt.present ? lastBackupAt.value : this.lastBackupAt,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      defaultCurrency: data.defaultCurrency.present
          ? data.defaultCurrency.value
          : this.defaultCurrency,
      defaultReminderDays: data.defaultReminderDays.present
          ? data.defaultReminderDays.value
          : this.defaultReminderDays,
      defaultReminderHour: data.defaultReminderHour.present
          ? data.defaultReminderHour.value
          : this.defaultReminderHour,
      defaultReminderMinute: data.defaultReminderMinute.present
          ? data.defaultReminderMinute.value
          : this.defaultReminderMinute,
      defaultSortOrder: data.defaultSortOrder.present
          ? data.defaultSortOrder.value
          : this.defaultSortOrder,
      lastBackupAt: data.lastBackupAt.present
          ? data.lastBackupAt.value
          : this.lastBackupAt,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('defaultReminderDays: $defaultReminderDays, ')
          ..write('defaultReminderHour: $defaultReminderHour, ')
          ..write('defaultReminderMinute: $defaultReminderMinute, ')
          ..write('defaultSortOrder: $defaultSortOrder, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    defaultCurrency,
    defaultReminderDays,
    defaultReminderHour,
    defaultReminderMinute,
    defaultSortOrder,
    lastBackupAt,
    schemaVersion,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.defaultCurrency == this.defaultCurrency &&
          other.defaultReminderDays == this.defaultReminderDays &&
          other.defaultReminderHour == this.defaultReminderHour &&
          other.defaultReminderMinute == this.defaultReminderMinute &&
          other.defaultSortOrder == this.defaultSortOrder &&
          other.lastBackupAt == this.lastBackupAt &&
          other.schemaVersion == this.schemaVersion &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> id;
  final Value<String> themeMode;
  final Value<String> defaultCurrency;
  final Value<int> defaultReminderDays;
  final Value<int> defaultReminderHour;
  final Value<int> defaultReminderMinute;
  final Value<String> defaultSortOrder;
  final Value<DateTime?> lastBackupAt;
  final Value<int> schemaVersion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.defaultCurrency = const Value.absent(),
    this.defaultReminderDays = const Value.absent(),
    this.defaultReminderHour = const Value.absent(),
    this.defaultReminderMinute = const Value.absent(),
    this.defaultSortOrder = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.defaultCurrency = const Value.absent(),
    this.defaultReminderDays = const Value.absent(),
    this.defaultReminderHour = const Value.absent(),
    this.defaultReminderMinute = const Value.absent(),
    this.defaultSortOrder = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<Setting> custom({
    Expression<String>? id,
    Expression<String>? themeMode,
    Expression<String>? defaultCurrency,
    Expression<int>? defaultReminderDays,
    Expression<int>? defaultReminderHour,
    Expression<int>? defaultReminderMinute,
    Expression<String>? defaultSortOrder,
    Expression<DateTime>? lastBackupAt,
    Expression<int>? schemaVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (defaultCurrency != null) 'default_currency': defaultCurrency,
      if (defaultReminderDays != null)
        'default_reminder_days': defaultReminderDays,
      if (defaultReminderHour != null)
        'default_reminder_hour': defaultReminderHour,
      if (defaultReminderMinute != null)
        'default_reminder_minute': defaultReminderMinute,
      if (defaultSortOrder != null) 'default_sort_order': defaultSortOrder,
      if (lastBackupAt != null) 'last_backup_at': lastBackupAt,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? themeMode,
    Value<String>? defaultCurrency,
    Value<int>? defaultReminderDays,
    Value<int>? defaultReminderHour,
    Value<int>? defaultReminderMinute,
    Value<String>? defaultSortOrder,
    Value<DateTime?>? lastBackupAt,
    Value<int>? schemaVersion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultReminderDays: defaultReminderDays ?? this.defaultReminderDays,
      defaultReminderHour: defaultReminderHour ?? this.defaultReminderHour,
      defaultReminderMinute:
          defaultReminderMinute ?? this.defaultReminderMinute,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (defaultCurrency.present) {
      map['default_currency'] = Variable<String>(defaultCurrency.value);
    }
    if (defaultReminderDays.present) {
      map['default_reminder_days'] = Variable<int>(defaultReminderDays.value);
    }
    if (defaultReminderHour.present) {
      map['default_reminder_hour'] = Variable<int>(defaultReminderHour.value);
    }
    if (defaultReminderMinute.present) {
      map['default_reminder_minute'] = Variable<int>(
        defaultReminderMinute.value,
      );
    }
    if (defaultSortOrder.present) {
      map['default_sort_order'] = Variable<String>(defaultSortOrder.value);
    }
    if (lastBackupAt.present) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('defaultReminderDays: $defaultReminderDays, ')
          ..write('defaultReminderHour: $defaultReminderHour, ')
          ..write('defaultReminderMinute: $defaultReminderMinute, ')
          ..write('defaultSortOrder: $defaultSortOrder, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $PriceHistoryTable priceHistory = $PriceHistoryTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index idxCategoriesName = Index(
    'idx_categories_name',
    'CREATE UNIQUE INDEX idx_categories_name ON categories (name)',
  );
  late final Index idxSubscriptionsDueDate = Index(
    'idx_subscriptions_due_date',
    'CREATE INDEX idx_subscriptions_due_date ON subscriptions (next_due_date)',
  );
  late final Index idxSubscriptionsCategoryId = Index(
    'idx_subscriptions_category_id',
    'CREATE INDEX idx_subscriptions_category_id ON subscriptions (category_id)',
  );
  late final Index idxSubscriptionsStatus = Index(
    'idx_subscriptions_status',
    'CREATE INDEX idx_subscriptions_status ON subscriptions (status)',
  );
  late final Index idxSubscriptionsDupCheck = Index(
    'idx_subscriptions_dup_check',
    'CREATE INDEX idx_subscriptions_dup_check ON subscriptions (name, cycle_type, next_due_date)',
  );
  late final Index idxPriceHistorySub = Index(
    'idx_price_history_sub',
    'CREATE INDEX idx_price_history_sub ON price_history (subscription_id, changed_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    subscriptions,
    priceHistory,
    settings,
    idxCategoriesName,
    idxSubscriptionsDueDate,
    idxSubscriptionsCategoryId,
    idxSubscriptionsStatus,
    idxSubscriptionsDupCheck,
    idxPriceHistorySub,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subscriptions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('price_history', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required int colorValue,
      Value<String?> iconCode,
      Value<bool> isSystem,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> colorValue,
      Value<String?> iconCode,
      Value<bool> isSystem,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubscriptionsTable, List<Subscription>>
  _subscriptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subscriptions,
    aliasName: 'categories__id__subscriptions__category_id',
  );

  $$SubscriptionsTableProcessedTableManager get subscriptionsRefs {
    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subscriptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subscriptionsRefs(
    Expression<bool> Function($$SubscriptionsTableFilterComposer f) f,
  ) {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> subscriptionsRefs<T extends Object>(
    Expression<T> Function($$SubscriptionsTableAnnotationComposer a) f,
  ) {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool subscriptionsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String?> iconCode = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                iconCode: iconCode,
                isSystem: isSystem,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int colorValue,
                Value<String?> iconCode = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                iconCode: iconCode,
                isSystem: isSystem,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subscriptionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subscriptionsRefs) db.subscriptions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subscriptionsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Subscription
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._subscriptionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).subscriptionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool subscriptionsRefs})
    >;
typedef $$SubscriptionsTableCreateCompanionBuilder =
    SubscriptionsCompanion Function({
      required String id,
      required String name,
      required int priceMinorUnits,
      required String currencyCode,
      required String cycleType,
      Value<int?> customCycleDays,
      required DateTime startDate,
      required DateTime nextDueDate,
      required int originalAnchorDay,
      required String categoryId,
      Value<String> status,
      Value<bool> isTrial,
      Value<String?> notes,
      Value<String?> renewalUrl,
      Value<String?> paymentMethodDesc,
      Value<bool> reminderEnabled,
      Value<int> reminderLeadDays,
      Value<int> reminderTimeHour,
      Value<int> reminderTimeMinute,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$SubscriptionsTableUpdateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> priceMinorUnits,
      Value<String> currencyCode,
      Value<String> cycleType,
      Value<int?> customCycleDays,
      Value<DateTime> startDate,
      Value<DateTime> nextDueDate,
      Value<int> originalAnchorDay,
      Value<String> categoryId,
      Value<String> status,
      Value<bool> isTrial,
      Value<String?> notes,
      Value<String?> renewalUrl,
      Value<String?> paymentMethodDesc,
      Value<bool> reminderEnabled,
      Value<int> reminderLeadDays,
      Value<int> reminderTimeHour,
      Value<int> reminderTimeMinute,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$SubscriptionsTableReferences
    extends BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription> {
  $$SubscriptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('subscriptions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PriceHistoryTable, List<PriceHistoryData>>
  _priceHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.priceHistory,
    aliasName: 'subscriptions__id__price_history__subscription_id',
  );

  $$PriceHistoryTableProcessedTableManager get priceHistoryRefs {
    final manager = $$PriceHistoryTableTableManager(
      $_db,
      $_db.priceHistory,
    ).filter((f) => f.subscriptionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_priceHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceMinorUnits => $composableBuilder(
    column: $table.priceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleType => $composableBuilder(
    column: $table.cycleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customCycleDays => $composableBuilder(
    column: $table.customCycleDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAnchorDay => $composableBuilder(
    column: $table.originalAnchorDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTrial => $composableBuilder(
    column: $table.isTrial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get renewalUrl => $composableBuilder(
    column: $table.renewalUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethodDesc => $composableBuilder(
    column: $table.paymentMethodDesc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderLeadDays => $composableBuilder(
    column: $table.reminderLeadDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimeHour => $composableBuilder(
    column: $table.reminderTimeHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimeMinute => $composableBuilder(
    column: $table.reminderTimeMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> priceHistoryRefs(
    Expression<bool> Function($$PriceHistoryTableFilterComposer f) f,
  ) {
    final $$PriceHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.priceHistory,
      getReferencedColumn: (t) => t.subscriptionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PriceHistoryTableFilterComposer(
            $db: $db,
            $table: $db.priceHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceMinorUnits => $composableBuilder(
    column: $table.priceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleType => $composableBuilder(
    column: $table.cycleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customCycleDays => $composableBuilder(
    column: $table.customCycleDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAnchorDay => $composableBuilder(
    column: $table.originalAnchorDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTrial => $composableBuilder(
    column: $table.isTrial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get renewalUrl => $composableBuilder(
    column: $table.renewalUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethodDesc => $composableBuilder(
    column: $table.paymentMethodDesc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderLeadDays => $composableBuilder(
    column: $table.reminderLeadDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimeHour => $composableBuilder(
    column: $table.reminderTimeHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimeMinute => $composableBuilder(
    column: $table.reminderTimeMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get priceMinorUnits => $composableBuilder(
    column: $table.priceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cycleType =>
      $composableBuilder(column: $table.cycleType, builder: (column) => column);

  GeneratedColumn<int> get customCycleDays => $composableBuilder(
    column: $table.customCycleDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAnchorDay => $composableBuilder(
    column: $table.originalAnchorDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isTrial =>
      $composableBuilder(column: $table.isTrial, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get renewalUrl => $composableBuilder(
    column: $table.renewalUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethodDesc => $composableBuilder(
    column: $table.paymentMethodDesc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderLeadDays => $composableBuilder(
    column: $table.reminderLeadDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTimeHour => $composableBuilder(
    column: $table.reminderTimeHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTimeMinute => $composableBuilder(
    column: $table.reminderTimeMinute,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> priceHistoryRefs<T extends Object>(
    Expression<T> Function($$PriceHistoryTableAnnotationComposer a) f,
  ) {
    final $$PriceHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.priceHistory,
      getReferencedColumn: (t) => t.subscriptionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PriceHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.priceHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionsTable,
          Subscription,
          $$SubscriptionsTableFilterComposer,
          $$SubscriptionsTableOrderingComposer,
          $$SubscriptionsTableAnnotationComposer,
          $$SubscriptionsTableCreateCompanionBuilder,
          $$SubscriptionsTableUpdateCompanionBuilder,
          (Subscription, $$SubscriptionsTableReferences),
          Subscription,
          PrefetchHooks Function({bool categoryId, bool priceHistoryRefs})
        > {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> priceMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> cycleType = const Value.absent(),
                Value<int?> customCycleDays = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> nextDueDate = const Value.absent(),
                Value<int> originalAnchorDay = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isTrial = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> renewalUrl = const Value.absent(),
                Value<String?> paymentMethodDesc = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderLeadDays = const Value.absent(),
                Value<int> reminderTimeHour = const Value.absent(),
                Value<int> reminderTimeMinute = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionsCompanion(
                id: id,
                name: name,
                priceMinorUnits: priceMinorUnits,
                currencyCode: currencyCode,
                cycleType: cycleType,
                customCycleDays: customCycleDays,
                startDate: startDate,
                nextDueDate: nextDueDate,
                originalAnchorDay: originalAnchorDay,
                categoryId: categoryId,
                status: status,
                isTrial: isTrial,
                notes: notes,
                renewalUrl: renewalUrl,
                paymentMethodDesc: paymentMethodDesc,
                reminderEnabled: reminderEnabled,
                reminderLeadDays: reminderLeadDays,
                reminderTimeHour: reminderTimeHour,
                reminderTimeMinute: reminderTimeMinute,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int priceMinorUnits,
                required String currencyCode,
                required String cycleType,
                Value<int?> customCycleDays = const Value.absent(),
                required DateTime startDate,
                required DateTime nextDueDate,
                required int originalAnchorDay,
                required String categoryId,
                Value<String> status = const Value.absent(),
                Value<bool> isTrial = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> renewalUrl = const Value.absent(),
                Value<String?> paymentMethodDesc = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderLeadDays = const Value.absent(),
                Value<int> reminderTimeHour = const Value.absent(),
                Value<int> reminderTimeMinute = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionsCompanion.insert(
                id: id,
                name: name,
                priceMinorUnits: priceMinorUnits,
                currencyCode: currencyCode,
                cycleType: cycleType,
                customCycleDays: customCycleDays,
                startDate: startDate,
                nextDueDate: nextDueDate,
                originalAnchorDay: originalAnchorDay,
                categoryId: categoryId,
                status: status,
                isTrial: isTrial,
                notes: notes,
                renewalUrl: renewalUrl,
                paymentMethodDesc: paymentMethodDesc,
                reminderEnabled: reminderEnabled,
                reminderLeadDays: reminderLeadDays,
                reminderTimeHour: reminderTimeHour,
                reminderTimeMinute: reminderTimeMinute,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubscriptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, priceHistoryRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (priceHistoryRefs) db.priceHistory,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$SubscriptionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$SubscriptionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (priceHistoryRefs)
                        await $_getPrefetchedData<
                          Subscription,
                          $SubscriptionsTable,
                          PriceHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$SubscriptionsTableReferences
                              ._priceHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubscriptionsTableReferences(
                                db,
                                table,
                                p0,
                              ).priceHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subscriptionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionsTable,
      Subscription,
      $$SubscriptionsTableFilterComposer,
      $$SubscriptionsTableOrderingComposer,
      $$SubscriptionsTableAnnotationComposer,
      $$SubscriptionsTableCreateCompanionBuilder,
      $$SubscriptionsTableUpdateCompanionBuilder,
      (Subscription, $$SubscriptionsTableReferences),
      Subscription,
      PrefetchHooks Function({bool categoryId, bool priceHistoryRefs})
    >;
typedef $$PriceHistoryTableCreateCompanionBuilder =
    PriceHistoryCompanion Function({
      required String id,
      required String subscriptionId,
      required int oldPriceMinorUnits,
      required int newPriceMinorUnits,
      required String currencyCode,
      required DateTime changedAt,
      Value<int> rowid,
    });
typedef $$PriceHistoryTableUpdateCompanionBuilder =
    PriceHistoryCompanion Function({
      Value<String> id,
      Value<String> subscriptionId,
      Value<int> oldPriceMinorUnits,
      Value<int> newPriceMinorUnits,
      Value<String> currencyCode,
      Value<DateTime> changedAt,
      Value<int> rowid,
    });

final class $$PriceHistoryTableReferences
    extends
        BaseReferences<_$AppDatabase, $PriceHistoryTable, PriceHistoryData> {
  $$PriceHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubscriptionsTable _subscriptionIdTable(_$AppDatabase db) => db
      .subscriptions
      .createAlias('price_history__subscription_id__subscriptions__id');

  $$SubscriptionsTableProcessedTableManager get subscriptionId {
    final $_column = $_itemColumn<String>('subscription_id')!;

    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subscriptionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PriceHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PriceHistoryTable> {
  $$PriceHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oldPriceMinorUnits => $composableBuilder(
    column: $table.oldPriceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newPriceMinorUnits => $composableBuilder(
    column: $table.newPriceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SubscriptionsTableFilterComposer get subscriptionId {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PriceHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceHistoryTable> {
  $$PriceHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oldPriceMinorUnits => $composableBuilder(
    column: $table.oldPriceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newPriceMinorUnits => $composableBuilder(
    column: $table.newPriceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubscriptionsTableOrderingComposer get subscriptionId {
    final $$SubscriptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableOrderingComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PriceHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceHistoryTable> {
  $$PriceHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get oldPriceMinorUnits => $composableBuilder(
    column: $table.oldPriceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newPriceMinorUnits => $composableBuilder(
    column: $table.newPriceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  $$SubscriptionsTableAnnotationComposer get subscriptionId {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PriceHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceHistoryTable,
          PriceHistoryData,
          $$PriceHistoryTableFilterComposer,
          $$PriceHistoryTableOrderingComposer,
          $$PriceHistoryTableAnnotationComposer,
          $$PriceHistoryTableCreateCompanionBuilder,
          $$PriceHistoryTableUpdateCompanionBuilder,
          (PriceHistoryData, $$PriceHistoryTableReferences),
          PriceHistoryData,
          PrefetchHooks Function({bool subscriptionId})
        > {
  $$PriceHistoryTableTableManager(_$AppDatabase db, $PriceHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subscriptionId = const Value.absent(),
                Value<int> oldPriceMinorUnits = const Value.absent(),
                Value<int> newPriceMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PriceHistoryCompanion(
                id: id,
                subscriptionId: subscriptionId,
                oldPriceMinorUnits: oldPriceMinorUnits,
                newPriceMinorUnits: newPriceMinorUnits,
                currencyCode: currencyCode,
                changedAt: changedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subscriptionId,
                required int oldPriceMinorUnits,
                required int newPriceMinorUnits,
                required String currencyCode,
                required DateTime changedAt,
                Value<int> rowid = const Value.absent(),
              }) => PriceHistoryCompanion.insert(
                id: id,
                subscriptionId: subscriptionId,
                oldPriceMinorUnits: oldPriceMinorUnits,
                newPriceMinorUnits: newPriceMinorUnits,
                currencyCode: currencyCode,
                changedAt: changedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PriceHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subscriptionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (subscriptionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subscriptionId,
                                referencedTable: $$PriceHistoryTableReferences
                                    ._subscriptionIdTable(db),
                                referencedColumn: $$PriceHistoryTableReferences
                                    ._subscriptionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PriceHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceHistoryTable,
      PriceHistoryData,
      $$PriceHistoryTableFilterComposer,
      $$PriceHistoryTableOrderingComposer,
      $$PriceHistoryTableAnnotationComposer,
      $$PriceHistoryTableCreateCompanionBuilder,
      $$PriceHistoryTableUpdateCompanionBuilder,
      (PriceHistoryData, $$PriceHistoryTableReferences),
      PriceHistoryData,
      PrefetchHooks Function({bool subscriptionId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> id,
      Value<String> themeMode,
      Value<String> defaultCurrency,
      Value<int> defaultReminderDays,
      Value<int> defaultReminderHour,
      Value<int> defaultReminderMinute,
      Value<String> defaultSortOrder,
      Value<DateTime?> lastBackupAt,
      Value<int> schemaVersion,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> id,
      Value<String> themeMode,
      Value<String> defaultCurrency,
      Value<int> defaultReminderDays,
      Value<int> defaultReminderHour,
      Value<int> defaultReminderMinute,
      Value<String> defaultSortOrder,
      Value<DateTime?> lastBackupAt,
      Value<int> schemaVersion,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultReminderDays => $composableBuilder(
    column: $table.defaultReminderDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultReminderHour => $composableBuilder(
    column: $table.defaultReminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultReminderMinute => $composableBuilder(
    column: $table.defaultReminderMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultSortOrder => $composableBuilder(
    column: $table.defaultSortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultReminderDays => $composableBuilder(
    column: $table.defaultReminderDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultReminderHour => $composableBuilder(
    column: $table.defaultReminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultReminderMinute => $composableBuilder(
    column: $table.defaultReminderMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultSortOrder => $composableBuilder(
    column: $table.defaultSortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultReminderDays => $composableBuilder(
    column: $table.defaultReminderDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultReminderHour => $composableBuilder(
    column: $table.defaultReminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultReminderMinute => $composableBuilder(
    column: $table.defaultReminderMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultSortOrder => $composableBuilder(
    column: $table.defaultSortOrder,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> defaultCurrency = const Value.absent(),
                Value<int> defaultReminderDays = const Value.absent(),
                Value<int> defaultReminderHour = const Value.absent(),
                Value<int> defaultReminderMinute = const Value.absent(),
                Value<String> defaultSortOrder = const Value.absent(),
                Value<DateTime?> lastBackupAt = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                themeMode: themeMode,
                defaultCurrency: defaultCurrency,
                defaultReminderDays: defaultReminderDays,
                defaultReminderHour: defaultReminderHour,
                defaultReminderMinute: defaultReminderMinute,
                defaultSortOrder: defaultSortOrder,
                lastBackupAt: lastBackupAt,
                schemaVersion: schemaVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> defaultCurrency = const Value.absent(),
                Value<int> defaultReminderDays = const Value.absent(),
                Value<int> defaultReminderHour = const Value.absent(),
                Value<int> defaultReminderMinute = const Value.absent(),
                Value<String> defaultSortOrder = const Value.absent(),
                Value<DateTime?> lastBackupAt = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                defaultCurrency: defaultCurrency,
                defaultReminderDays: defaultReminderDays,
                defaultReminderHour: defaultReminderHour,
                defaultReminderMinute: defaultReminderMinute,
                defaultSortOrder: defaultSortOrder,
                lastBackupAt: lastBackupAt,
                schemaVersion: schemaVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$PriceHistoryTableTableManager get priceHistory =>
      $$PriceHistoryTableTableManager(_db, _db.priceHistory);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
