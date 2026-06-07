import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// What the user did when the pause screen appeared.
enum InterceptOutcome {
  /// Waited out the delay and tapped Continue.
  proceededAfterWait,

  /// Tapped Skip (proceeded immediately, before the delay finished).
  skipped,

  /// Pressed back / left without proceeding into the AI app.
  backedOut,
}

/// Append-only log of every interception. This table is the single source of
/// truth; all dashboard numbers are aggregate queries over it.
class InterceptEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get outcome => intEnum<InterceptOutcome>()();
  BoolColumn get typedAttempt => boolean().withDefault(const Constant(false))();
  TextColumn get attemptText => text().nullable()();
  IntColumn get waitedSeconds => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [InterceptEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests and previews.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

/// Opens the on-device database file lazily (app runtime only).
LazyDatabase openAppDatabaseConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pause_reflect.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
