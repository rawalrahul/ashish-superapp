import 'package:flutter/services.dart';

/// Dart side of the `pause/native` MethodChannel handled by `MainActivity.kt`.
///
/// Only the things that genuinely need native code live here (opening system
/// settings screens, checking the a11y toggle, package visibility). Config and
/// grace state are written directly through `SettingsStore` (shared prefs).
class NativeBridge {
  NativeBridge([MethodChannel? channel])
      : _channel = channel ?? const MethodChannel('pause/native');

  final MethodChannel _channel;

  /// Opens the system Accessibility settings so the user can enable the service.
  Future<void> openA11ySettings() => _channel.invokeMethod('openA11ySettings');

  /// Opens the "display over other apps" permission screen for this app.
  Future<void> openOverlaySettings() =>
      _channel.invokeMethod('openOverlaySettings');

  /// Whether our AccessibilityService is currently enabled.
  Future<bool> isA11yEnabled() async {
    final result = await _channel.invokeMethod<bool>('isA11yEnabled');
    return result ?? false;
  }

  /// Of [packages], returns those actually installed on the device.
  Future<List<String>> queryInstalledAiApps(List<String> packages) async {
    final result = await _channel.invokeMethod<List<Object?>>(
      'queryInstalledAiApps',
      {'packages': packages},
    );
    return result?.cast<String>() ?? const [];
  }
}
