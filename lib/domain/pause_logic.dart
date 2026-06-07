// Pure, dependency-free logic so it can be unit-tested without a device,
// prefs, or a database.

/// Rotating reflection prompts: which prompt to show and what the next index is.
class PromptRotation {
  const PromptRotation._();

  /// The prompt to display for [index] (wraps around). Empty if no prompts.
  static String promptAt(List<String> prompts, int index) {
    if (prompts.isEmpty) return '';
    final i = index % prompts.length;
    return prompts[i < 0 ? i + prompts.length : i];
  }

  /// The index to persist for the next interception.
  static int nextIndex(int index, int length) {
    if (length <= 0) return 0;
    return (index + 1) % length;
  }
}

/// Grace window: after the user proceeds into an app, suppress re-prompts for
/// [graceMinutes] so they can actually use it.
class GracePolicy {
  const GracePolicy._();

  static bool inGrace({
    required int? lastAllowedEpochMs,
    required int graceMinutes,
    required int nowEpochMs,
  }) {
    if (lastAllowedEpochMs == null) return false;
    if (graceMinutes <= 0) return false;
    return nowEpochMs - lastAllowedEpochMs < graceMinutes * 60 * 1000;
  }
}
