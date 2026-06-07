import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pause_reflect/data/database.dart';
import 'package:pause_reflect/features/pause/pause_screen.dart';

PauseResult? lastResult;

Widget _host({
  required int delaySeconds,
  bool requireText = false,
}) {
  return MaterialApp(
    home: PauseScreen(
      appName: 'ChatGPT',
      prompt: 'Why now?',
      delaySeconds: delaySeconds,
      requireText: requireText,
      onResolved: (r) => lastResult = r,
    ),
  );
}

bool _continueEnabled(WidgetTester tester) {
  final btn = tester.widget<FilledButton>(find.byType(FilledButton));
  return btn.onPressed != null;
}

void main() {
  setUp(() => lastResult = null);

  testWidgets('Continue is disabled until the countdown reaches zero',
      (tester) async {
    await tester.pumpWidget(_host(delaySeconds: 2));
    expect(_continueEnabled(tester), isFalse);
    expect(find.text('Continue in 2'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(_continueEnabled(tester), isFalse);

    await tester.pump(const Duration(seconds: 1));
    expect(_continueEnabled(tester), isTrue);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Continue records proceededAfterWait with elapsed seconds',
      (tester) async {
    await tester.pumpWidget(_host(delaySeconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(lastResult, isNotNull);
    expect(lastResult!.outcome, InterceptOutcome.proceededAfterWait);
    expect(lastResult!.waitedSeconds, 2);
    expect(lastResult!.typedAttempt, isFalse);
  });

  testWidgets('Skip proceeds immediately even during the countdown',
      (tester) async {
    await tester.pumpWidget(_host(delaySeconds: 10));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Skip'));
    await tester.pump();

    expect(lastResult!.outcome, InterceptOutcome.skipped);
    expect(lastResult!.waitedSeconds, 1);
  });

  testWidgets('typed text flips typedAttempt and is captured', (tester) async {
    await tester.pumpWidget(_host(delaySeconds: 0));
    await tester.enterText(find.byType(TextField), '  my reflection  ');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(lastResult!.typedAttempt, isTrue);
    expect(lastResult!.attemptText, 'my reflection');
  });

  testWidgets('requireText keeps Continue disabled until text entered',
      (tester) async {
    await tester.pumpWidget(_host(delaySeconds: 0, requireText: true));
    expect(_continueEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField), 'done');
    await tester.pump();
    expect(_continueEnabled(tester), isTrue);
  });

  testWidgets('back press records a back-out', (tester) async {
    await tester.pumpWidget(_host(delaySeconds: 0));
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(lastResult, isNotNull);
    expect(lastResult!.outcome, InterceptOutcome.backedOut);
  });
}
