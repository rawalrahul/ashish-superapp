import 'package:flutter/services.dart';

/// Dart side of the `pause/intercept` channel handled by `InterceptActivity.kt`
/// (the cached pause engine). Used to learn which app triggered the pause and to
/// dismiss the intercept Activity afterwards.
class InterceptChannel {
  InterceptChannel([MethodChannel? channel])
      : _channel = channel ?? const MethodChannel('pause/intercept');

  final MethodChannel _channel;

  /// Package name of the app the user was opening.
  Future<String?> getTarget() => _channel.invokeMethod<String>('getTarget');

  /// Finish the intercept Activity. [goHome] true sends the user to the
  /// launcher (back-out); false returns them to the AI app (proceed/skip).
  Future<void> exit({required bool goHome}) =>
      _channel.invokeMethod('exit', {'goHome': goHome});
}
