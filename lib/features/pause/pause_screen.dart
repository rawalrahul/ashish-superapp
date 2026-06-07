import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/database.dart';

/// The result of a single pause interaction, handed back to whoever wired up
/// the screen (so the widget itself stays free of DB/prefs/channel deps and is
/// easy to widget-test).
class PauseResult {
  const PauseResult({
    required this.outcome,
    required this.typedAttempt,
    required this.attemptText,
    required this.waitedSeconds,
  });

  final InterceptOutcome outcome;
  final bool typedAttempt;
  final String? attemptText;
  final int waitedSeconds;
}

/// The interrupt UI shown over a watched AI app.
///
/// - Shows a rotating reflection [prompt].
/// - Optional "write your own attempt" text field.
/// - `Continue` is disabled until the [delaySeconds] countdown hits 0 (and, if
///   [requireText], until something is typed).
/// - `Skip` proceeds immediately (it does NOT block the app).
/// - Back press records a back-out.
///
/// Exactly one [PauseResult] is ever emitted via [onResolved].
class PauseScreen extends StatefulWidget {
  const PauseScreen({
    super.key,
    required this.appName,
    required this.prompt,
    required this.delaySeconds,
    required this.requireText,
    required this.onResolved,
  });

  final String appName;
  final String prompt;
  final int delaySeconds;
  final bool requireText;
  final ValueChanged<PauseResult> onResolved;

  @override
  State<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends State<PauseScreen> {
  late int _remaining;
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.delaySeconds;
    if (_remaining > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _remaining = (_remaining - 1).clamp(0, widget.delaySeconds);
          if (_remaining == 0) _timer?.cancel();
        });
      });
    }
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get _hasText => _controller.text.trim().isNotEmpty;
  bool get _canContinue =>
      _remaining == 0 && (!widget.requireText || _hasText);

  void _resolve(InterceptOutcome outcome) {
    if (_resolved) return;
    _resolved = true;
    _timer?.cancel();
    widget.onResolved(PauseResult(
      outcome: outcome,
      typedAttempt: _hasText,
      attemptText: _hasText ? _controller.text.trim() : null,
      waitedSeconds: widget.delaySeconds - _remaining,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _resolve(InterceptOutcome.backedOut);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  'Before you open ${widget.appName}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.prompt,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: widget.requireText
                        ? 'Write your reflection to continue…'
                        : 'Write your own attempt (optional)…',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _canContinue
                      ? () => _resolve(InterceptOutcome.proceededAfterWait)
                      : null,
                  child: Text(
                    _remaining > 0 ? 'Continue in $_remaining' : 'Continue',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _resolve(InterceptOutcome.skipped),
                  child: const Text('Skip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
