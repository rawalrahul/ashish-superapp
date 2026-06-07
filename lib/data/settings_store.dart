import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/pause_logic.dart';

/// Persists settings + grace timestamps in `shared_preferences`.
///
/// This is the ONLY shared state with the native AccessibilityService. On
/// Android these land in the `FlutterSharedPreferences` file with keys prefixed
/// `flutter.` — the Kotlin service reads the same keys (see
/// `AppInterceptAccessibilityService.kt`). Keep key names and value types in
/// sync with that file.
///
/// Correction over the original plan: the watched package list is stored as a
/// single JSON string (not `setStringList`) because the plugin's list encoding
/// is awkward to parse from Kotlin.
class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  // Keys (without the platform `flutter.` prefix that the plugin adds).
  static const kWatchedPackagesJson = 'watchedPackagesJson';
  static const kDelaySeconds = 'delaySeconds';
  static const kGraceMinutes = 'graceMinutes';
  static const kRequireText = 'requireTextBeforeContinue';
  static const kPromptIndex = 'promptIndex';
  static const kPromptsJson = 'promptsJson';
  static String graceKey(String pkg) => 'grace_$pkg';

  static const defaultDelaySeconds = 15;
  static const defaultGraceMinutes = 5;

  // --- Watched packages -----------------------------------------------------

  List<String> get watchedPackages {
    final raw = _prefs.getString(kWatchedPackagesJson);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.cast<String>();
  }

  Future<void> setWatchedPackages(List<String> packages) {
    return _prefs.setString(kWatchedPackagesJson, jsonEncode(packages));
  }

  // --- Tunables -------------------------------------------------------------

  int get delaySeconds => _prefs.getInt(kDelaySeconds) ?? defaultDelaySeconds;
  Future<void> setDelaySeconds(int v) => _prefs.setInt(kDelaySeconds, v);

  int get graceMinutes => _prefs.getInt(kGraceMinutes) ?? defaultGraceMinutes;
  Future<void> setGraceMinutes(int v) => _prefs.setInt(kGraceMinutes, v);

  bool get requireTextBeforeContinue =>
      _prefs.getBool(kRequireText) ?? false;
  Future<void> setRequireTextBeforeContinue(bool v) =>
      _prefs.setBool(kRequireText, v);

  // --- Prompts --------------------------------------------------------------

  int get promptIndex => _prefs.getInt(kPromptIndex) ?? 0;
  Future<void> setPromptIndex(int v) => _prefs.setInt(kPromptIndex, v);

  /// User-editable prompt copy; null until the user customizes them.
  List<String>? get customPrompts {
    final raw = _prefs.getString(kPromptsJson);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded.cast<String>();
  }

  Future<void> setPrompts(List<String> prompts) =>
      _prefs.setString(kPromptsJson, jsonEncode(prompts));

  /// Effective prompt list: user copy if present, else the bundled asset.
  Future<List<String>> effectivePrompts() async {
    final custom = customPrompts;
    if (custom != null && custom.isNotEmpty) return custom;
    final raw = await rootBundle.loadString('assets/prompts.json');
    final decoded = jsonDecode(raw) as List;
    return decoded.cast<String>();
  }

  /// Returns the current prompt and advances the stored index.
  Future<String> nextPrompt() async {
    final prompts = await effectivePrompts();
    final current = PromptRotation.promptAt(prompts, promptIndex);
    await setPromptIndex(PromptRotation.nextIndex(promptIndex, prompts.length));
    return current;
  }

  // --- Grace ----------------------------------------------------------------

  Future<void> markAllowed(String pkg, {DateTime? at}) {
    final ts = (at ?? DateTime.now()).millisecondsSinceEpoch;
    return _prefs.setInt(graceKey(pkg), ts);
  }

  bool inGrace(String pkg, {DateTime? now}) {
    return GracePolicy.inGrace(
      lastAllowedEpochMs: _prefs.getInt(graceKey(pkg)),
      graceMinutes: graceMinutes,
      nowEpochMs: (now ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }
}
