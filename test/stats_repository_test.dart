import 'package:flutter_test/flutter_test.dart';
import 'package:pause_reflect/data/database.dart';
import 'package:pause_reflect/data/event_repository.dart';
import 'package:pause_reflect/data/stats_repository.dart';

void main() {
  late AppDatabase db;
  late EventRepository events;
  late StatsRepository stats;

  setUp(() {
    db = AppDatabase.memory();
    events = EventRepository(db);
    stats = StatsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('empty database yields zeroed stats', () async {
    final s = await stats.load();
    expect(s.totalOpens, 0);
    expect(s.typedAttempts, 0);
    expect(s.backedOut, 0);
    expect(s.perApp, isEmpty);
    expect(s.perDay, isEmpty);
  });

  test('aggregates outcomes, typed attempts, and per-app/day counts', () async {
    await events.record(
      packageName: 'com.openai.chatgpt',
      outcome: InterceptOutcome.proceededAfterWait,
      typedAttempt: true,
      attemptText: 'thinking',
      waitedSeconds: 15,
      at: DateTime(2026, 1, 1, 9),
    );
    await events.record(
      packageName: 'com.openai.chatgpt',
      outcome: InterceptOutcome.skipped,
      typedAttempt: false,
      waitedSeconds: 2,
      at: DateTime(2026, 1, 1, 10),
    );
    await events.record(
      packageName: 'com.anthropic.claude',
      outcome: InterceptOutcome.backedOut,
      typedAttempt: false,
      waitedSeconds: 0,
      at: DateTime(2026, 1, 2, 11),
    );

    final s = await stats.load();
    expect(s.totalOpens, 3);
    expect(s.typedAttempts, 1);
    expect(s.proceededAfterWait, 1);
    expect(s.skipped, 1);
    expect(s.backedOut, 1);
    expect(s.perApp['com.openai.chatgpt'], 2);
    expect(s.perApp['com.anthropic.claude'], 1);
    expect(s.perDay['2026-01-01'], 2);
    expect(s.perDay['2026-01-02'], 1);
  });
}
