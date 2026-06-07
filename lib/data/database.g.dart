// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $InterceptEventsTable extends InterceptEvents
    with TableInfo<$InterceptEventsTable, InterceptEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterceptEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<InterceptOutcome, int> outcome =
      GeneratedColumn<int>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<InterceptOutcome>(
        $InterceptEventsTable.$converteroutcome,
      );
  static const VerificationMeta _typedAttemptMeta = const VerificationMeta(
    'typedAttempt',
  );
  @override
  late final GeneratedColumn<bool> typedAttempt = GeneratedColumn<bool>(
    'typed_attempt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("typed_attempt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _attemptTextMeta = const VerificationMeta(
    'attemptText',
  );
  @override
  late final GeneratedColumn<String> attemptText = GeneratedColumn<String>(
    'attempt_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waitedSecondsMeta = const VerificationMeta(
    'waitedSeconds',
  );
  @override
  late final GeneratedColumn<int> waitedSeconds = GeneratedColumn<int>(
    'waited_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    timestamp,
    outcome,
    typedAttempt,
    attemptText,
    waitedSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intercept_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterceptEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('typed_attempt')) {
      context.handle(
        _typedAttemptMeta,
        typedAttempt.isAcceptableOrUnknown(
          data['typed_attempt']!,
          _typedAttemptMeta,
        ),
      );
    }
    if (data.containsKey('attempt_text')) {
      context.handle(
        _attemptTextMeta,
        attemptText.isAcceptableOrUnknown(
          data['attempt_text']!,
          _attemptTextMeta,
        ),
      );
    }
    if (data.containsKey('waited_seconds')) {
      context.handle(
        _waitedSecondsMeta,
        waitedSeconds.isAcceptableOrUnknown(
          data['waited_seconds']!,
          _waitedSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterceptEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterceptEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      outcome: $InterceptEventsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      typedAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}typed_attempt'],
      )!,
      attemptText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_text'],
      ),
      waitedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}waited_seconds'],
      )!,
    );
  }

  @override
  $InterceptEventsTable createAlias(String alias) {
    return $InterceptEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<InterceptOutcome, int, int> $converteroutcome =
      const EnumIndexConverter<InterceptOutcome>(InterceptOutcome.values);
}

class InterceptEvent extends DataClass implements Insertable<InterceptEvent> {
  final int id;
  final String packageName;
  final DateTime timestamp;
  final InterceptOutcome outcome;
  final bool typedAttempt;
  final String? attemptText;
  final int waitedSeconds;
  const InterceptEvent({
    required this.id,
    required this.packageName,
    required this.timestamp,
    required this.outcome,
    required this.typedAttempt,
    this.attemptText,
    required this.waitedSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['timestamp'] = Variable<DateTime>(timestamp);
    {
      map['outcome'] = Variable<int>(
        $InterceptEventsTable.$converteroutcome.toSql(outcome),
      );
    }
    map['typed_attempt'] = Variable<bool>(typedAttempt);
    if (!nullToAbsent || attemptText != null) {
      map['attempt_text'] = Variable<String>(attemptText);
    }
    map['waited_seconds'] = Variable<int>(waitedSeconds);
    return map;
  }

  InterceptEventsCompanion toCompanion(bool nullToAbsent) {
    return InterceptEventsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      timestamp: Value(timestamp),
      outcome: Value(outcome),
      typedAttempt: Value(typedAttempt),
      attemptText: attemptText == null && nullToAbsent
          ? const Value.absent()
          : Value(attemptText),
      waitedSeconds: Value(waitedSeconds),
    );
  }

  factory InterceptEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterceptEvent(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      outcome: $InterceptEventsTable.$converteroutcome.fromJson(
        serializer.fromJson<int>(json['outcome']),
      ),
      typedAttempt: serializer.fromJson<bool>(json['typedAttempt']),
      attemptText: serializer.fromJson<String?>(json['attemptText']),
      waitedSeconds: serializer.fromJson<int>(json['waitedSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'outcome': serializer.toJson<int>(
        $InterceptEventsTable.$converteroutcome.toJson(outcome),
      ),
      'typedAttempt': serializer.toJson<bool>(typedAttempt),
      'attemptText': serializer.toJson<String?>(attemptText),
      'waitedSeconds': serializer.toJson<int>(waitedSeconds),
    };
  }

  InterceptEvent copyWith({
    int? id,
    String? packageName,
    DateTime? timestamp,
    InterceptOutcome? outcome,
    bool? typedAttempt,
    Value<String?> attemptText = const Value.absent(),
    int? waitedSeconds,
  }) => InterceptEvent(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    timestamp: timestamp ?? this.timestamp,
    outcome: outcome ?? this.outcome,
    typedAttempt: typedAttempt ?? this.typedAttempt,
    attemptText: attemptText.present ? attemptText.value : this.attemptText,
    waitedSeconds: waitedSeconds ?? this.waitedSeconds,
  );
  InterceptEvent copyWithCompanion(InterceptEventsCompanion data) {
    return InterceptEvent(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      typedAttempt: data.typedAttempt.present
          ? data.typedAttempt.value
          : this.typedAttempt,
      attemptText: data.attemptText.present
          ? data.attemptText.value
          : this.attemptText,
      waitedSeconds: data.waitedSeconds.present
          ? data.waitedSeconds.value
          : this.waitedSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterceptEvent(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('timestamp: $timestamp, ')
          ..write('outcome: $outcome, ')
          ..write('typedAttempt: $typedAttempt, ')
          ..write('attemptText: $attemptText, ')
          ..write('waitedSeconds: $waitedSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    timestamp,
    outcome,
    typedAttempt,
    attemptText,
    waitedSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterceptEvent &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.timestamp == this.timestamp &&
          other.outcome == this.outcome &&
          other.typedAttempt == this.typedAttempt &&
          other.attemptText == this.attemptText &&
          other.waitedSeconds == this.waitedSeconds);
}

class InterceptEventsCompanion extends UpdateCompanion<InterceptEvent> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<DateTime> timestamp;
  final Value<InterceptOutcome> outcome;
  final Value<bool> typedAttempt;
  final Value<String?> attemptText;
  final Value<int> waitedSeconds;
  const InterceptEventsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.outcome = const Value.absent(),
    this.typedAttempt = const Value.absent(),
    this.attemptText = const Value.absent(),
    this.waitedSeconds = const Value.absent(),
  });
  InterceptEventsCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required DateTime timestamp,
    required InterceptOutcome outcome,
    this.typedAttempt = const Value.absent(),
    this.attemptText = const Value.absent(),
    this.waitedSeconds = const Value.absent(),
  }) : packageName = Value(packageName),
       timestamp = Value(timestamp),
       outcome = Value(outcome);
  static Insertable<InterceptEvent> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<DateTime>? timestamp,
    Expression<int>? outcome,
    Expression<bool>? typedAttempt,
    Expression<String>? attemptText,
    Expression<int>? waitedSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (timestamp != null) 'timestamp': timestamp,
      if (outcome != null) 'outcome': outcome,
      if (typedAttempt != null) 'typed_attempt': typedAttempt,
      if (attemptText != null) 'attempt_text': attemptText,
      if (waitedSeconds != null) 'waited_seconds': waitedSeconds,
    });
  }

  InterceptEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<DateTime>? timestamp,
    Value<InterceptOutcome>? outcome,
    Value<bool>? typedAttempt,
    Value<String?>? attemptText,
    Value<int>? waitedSeconds,
  }) {
    return InterceptEventsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      timestamp: timestamp ?? this.timestamp,
      outcome: outcome ?? this.outcome,
      typedAttempt: typedAttempt ?? this.typedAttempt,
      attemptText: attemptText ?? this.attemptText,
      waitedSeconds: waitedSeconds ?? this.waitedSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<int>(
        $InterceptEventsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (typedAttempt.present) {
      map['typed_attempt'] = Variable<bool>(typedAttempt.value);
    }
    if (attemptText.present) {
      map['attempt_text'] = Variable<String>(attemptText.value);
    }
    if (waitedSeconds.present) {
      map['waited_seconds'] = Variable<int>(waitedSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterceptEventsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('timestamp: $timestamp, ')
          ..write('outcome: $outcome, ')
          ..write('typedAttempt: $typedAttempt, ')
          ..write('attemptText: $attemptText, ')
          ..write('waitedSeconds: $waitedSeconds')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InterceptEventsTable interceptEvents = $InterceptEventsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [interceptEvents];
}

typedef $$InterceptEventsTableCreateCompanionBuilder =
    InterceptEventsCompanion Function({
      Value<int> id,
      required String packageName,
      required DateTime timestamp,
      required InterceptOutcome outcome,
      Value<bool> typedAttempt,
      Value<String?> attemptText,
      Value<int> waitedSeconds,
    });
typedef $$InterceptEventsTableUpdateCompanionBuilder =
    InterceptEventsCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<DateTime> timestamp,
      Value<InterceptOutcome> outcome,
      Value<bool> typedAttempt,
      Value<String?> attemptText,
      Value<int> waitedSeconds,
    });

class $$InterceptEventsTableFilterComposer
    extends Composer<_$AppDatabase, $InterceptEventsTable> {
  $$InterceptEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<InterceptOutcome, InterceptOutcome, int>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get typedAttempt => $composableBuilder(
    column: $table.typedAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptText => $composableBuilder(
    column: $table.attemptText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waitedSeconds => $composableBuilder(
    column: $table.waitedSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InterceptEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $InterceptEventsTable> {
  $$InterceptEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get typedAttempt => $composableBuilder(
    column: $table.typedAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptText => $composableBuilder(
    column: $table.attemptText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waitedSeconds => $composableBuilder(
    column: $table.waitedSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InterceptEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterceptEventsTable> {
  $$InterceptEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InterceptOutcome, int> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<bool> get typedAttempt => $composableBuilder(
    column: $table.typedAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attemptText => $composableBuilder(
    column: $table.attemptText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get waitedSeconds => $composableBuilder(
    column: $table.waitedSeconds,
    builder: (column) => column,
  );
}

class $$InterceptEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InterceptEventsTable,
          InterceptEvent,
          $$InterceptEventsTableFilterComposer,
          $$InterceptEventsTableOrderingComposer,
          $$InterceptEventsTableAnnotationComposer,
          $$InterceptEventsTableCreateCompanionBuilder,
          $$InterceptEventsTableUpdateCompanionBuilder,
          (
            InterceptEvent,
            BaseReferences<
              _$AppDatabase,
              $InterceptEventsTable,
              InterceptEvent
            >,
          ),
          InterceptEvent,
          PrefetchHooks Function()
        > {
  $$InterceptEventsTableTableManager(
    _$AppDatabase db,
    $InterceptEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterceptEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InterceptEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterceptEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<InterceptOutcome> outcome = const Value.absent(),
                Value<bool> typedAttempt = const Value.absent(),
                Value<String?> attemptText = const Value.absent(),
                Value<int> waitedSeconds = const Value.absent(),
              }) => InterceptEventsCompanion(
                id: id,
                packageName: packageName,
                timestamp: timestamp,
                outcome: outcome,
                typedAttempt: typedAttempt,
                attemptText: attemptText,
                waitedSeconds: waitedSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required DateTime timestamp,
                required InterceptOutcome outcome,
                Value<bool> typedAttempt = const Value.absent(),
                Value<String?> attemptText = const Value.absent(),
                Value<int> waitedSeconds = const Value.absent(),
              }) => InterceptEventsCompanion.insert(
                id: id,
                packageName: packageName,
                timestamp: timestamp,
                outcome: outcome,
                typedAttempt: typedAttempt,
                attemptText: attemptText,
                waitedSeconds: waitedSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InterceptEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InterceptEventsTable,
      InterceptEvent,
      $$InterceptEventsTableFilterComposer,
      $$InterceptEventsTableOrderingComposer,
      $$InterceptEventsTableAnnotationComposer,
      $$InterceptEventsTableCreateCompanionBuilder,
      $$InterceptEventsTableUpdateCompanionBuilder,
      (
        InterceptEvent,
        BaseReferences<_$AppDatabase, $InterceptEventsTable, InterceptEvent>,
      ),
      InterceptEvent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InterceptEventsTableTableManager get interceptEvents =>
      $$InterceptEventsTableTableManager(_db, _db.interceptEvents);
}
