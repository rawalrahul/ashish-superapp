import 'package:drift/drift.dart';

import 'database.dart';

/// Writes interception outcomes to the event log.
class EventRepository {
  EventRepository(this._db);

  final AppDatabase _db;

  Future<int> record({
    required String packageName,
    required InterceptOutcome outcome,
    required bool typedAttempt,
    String? attemptText,
    required int waitedSeconds,
    DateTime? at,
  }) {
    return _db.into(_db.interceptEvents).insert(
          InterceptEventsCompanion.insert(
            packageName: packageName,
            timestamp: at ?? DateTime.now(),
            outcome: outcome,
            typedAttempt: Value(typedAttempt),
            attemptText: Value(attemptText),
            waitedSeconds: Value(waitedSeconds),
          ),
        );
  }
}
