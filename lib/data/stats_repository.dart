import 'package:drift/drift.dart';

import 'database.dart';

/// Aggregated dashboard numbers derived from the [InterceptEvents] log.
class Stats {
  const Stats({
    required this.totalOpens,
    required this.typedAttempts,
    required this.backedOut,
    required this.proceededAfterWait,
    required this.skipped,
    required this.perApp,
    required this.perDay,
  });

  final int totalOpens;
  final int typedAttempts;
  final int backedOut;
  final int proceededAfterWait;
  final int skipped;

  /// packageName -> number of interceptions.
  final Map<String, int> perApp;

  /// 'YYYY-MM-DD' -> number of interceptions.
  final Map<String, int> perDay;

  static const empty = Stats(
    totalOpens: 0,
    typedAttempts: 0,
    backedOut: 0,
    proceededAfterWait: 0,
    skipped: 0,
    perApp: {},
    perDay: {},
  );
}

/// Computes [Stats] using SQL aggregate queries (no full-table load).
class StatsRepository {
  StatsRepository(this._db);

  final AppDatabase _db;

  Future<int> _count([Expression<bool>? filter]) async {
    final t = _db.interceptEvents;
    final c = t.id.count();
    final q = _db.selectOnly(t)..addColumns([c]);
    if (filter != null) q.where(filter);
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }

  Future<Stats> load() async {
    final t = _db.interceptEvents;

    final total = await _count();
    final typed = await _count(t.typedAttempt.equals(true));
    final backedOut =
        await _count(t.outcome.equalsValue(InterceptOutcome.backedOut));
    final proceeded =
        await _count(t.outcome.equalsValue(InterceptOutcome.proceededAfterWait));
    final skipped =
        await _count(t.outcome.equalsValue(InterceptOutcome.skipped));

    final c = t.id.count();

    final perApp = <String, int>{};
    final perAppQuery = _db.selectOnly(t)
      ..addColumns([t.packageName, c])
      ..groupBy([t.packageName]);
    for (final row in await perAppQuery.get()) {
      perApp[row.read(t.packageName)!] = row.read(c) ?? 0;
    }

    final day = t.timestamp.date; // 'YYYY-MM-DD'
    final perDay = <String, int>{};
    final perDayQuery = _db.selectOnly(t)
      ..addColumns([day, c])
      ..groupBy([day]);
    for (final row in await perDayQuery.get()) {
      perDay[row.read(day)!] = row.read(c) ?? 0;
    }

    return Stats(
      totalOpens: total,
      typedAttempts: typed,
      backedOut: backedOut,
      proceededAfterWait: proceeded,
      skipped: skipped,
      perApp: perApp,
      perDay: perDay,
    );
  }
}
