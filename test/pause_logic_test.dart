import 'package:flutter_test/flutter_test.dart';
import 'package:pause_reflect/domain/pause_logic.dart';

void main() {
  group('PromptRotation', () {
    const prompts = ['a', 'b', 'c'];

    test('promptAt wraps around the list', () {
      expect(PromptRotation.promptAt(prompts, 0), 'a');
      expect(PromptRotation.promptAt(prompts, 2), 'c');
      expect(PromptRotation.promptAt(prompts, 3), 'a');
      expect(PromptRotation.promptAt(prompts, 4), 'b');
    });

    test('promptAt handles empty list', () {
      expect(PromptRotation.promptAt(const [], 5), '');
    });

    test('nextIndex advances and wraps', () {
      expect(PromptRotation.nextIndex(0, 3), 1);
      expect(PromptRotation.nextIndex(2, 3), 0);
      expect(PromptRotation.nextIndex(0, 0), 0);
    });

    test('full rotation visits every prompt once before repeating', () {
      var index = 0;
      final seen = <String>[];
      for (var i = 0; i < prompts.length; i++) {
        seen.add(PromptRotation.promptAt(prompts, index));
        index = PromptRotation.nextIndex(index, prompts.length);
      }
      expect(seen, prompts);
      expect(index, 0); // back to start
    });
  });

  group('GracePolicy', () {
    test('no prior allow means not in grace', () {
      expect(
        GracePolicy.inGrace(
            lastAllowedEpochMs: null, graceMinutes: 5, nowEpochMs: 1000),
        isFalse,
      );
    });

    test('within window is in grace', () {
      final now = DateTime(2026, 1, 1, 12, 2).millisecondsSinceEpoch;
      final allowed = DateTime(2026, 1, 1, 12, 0).millisecondsSinceEpoch;
      expect(
        GracePolicy.inGrace(
            lastAllowedEpochMs: allowed, graceMinutes: 5, nowEpochMs: now),
        isTrue,
      );
    });

    test('after window expires is not in grace', () {
      final now = DateTime(2026, 1, 1, 12, 6).millisecondsSinceEpoch;
      final allowed = DateTime(2026, 1, 1, 12, 0).millisecondsSinceEpoch;
      expect(
        GracePolicy.inGrace(
            lastAllowedEpochMs: allowed, graceMinutes: 5, nowEpochMs: now),
        isFalse,
      );
    });

    test('zero grace minutes never suppresses', () {
      expect(
        GracePolicy.inGrace(
            lastAllowedEpochMs: 1000, graceMinutes: 0, nowEpochMs: 1000),
        isFalse,
      );
    });
  });
}
